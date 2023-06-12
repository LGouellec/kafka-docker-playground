topic="${args[--topic]}"
nb_messages="${args[--nb-messages]}"
nb_partitions="${args[--nb-partitions]}"
schema="${args[--input]}"
key="${args[--key]}"

tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
schema_file=$tmp_dir/value_schema

if [ "$schema" = "-" ]
then
    # stdin
    schema_content=$(cat "$schema")
    echo "$schema_content" > $schema_file
else
    if [[ $schema == @* ]]
    then
        # this is a schema file
        argument_schema_file=$(echo "$schema" | cut -d "@" -f 2)
        cp $argument_schema_file $schema_file
    elif [ -f $schema ]
    then
        cp $schema $schema_file
    else
        schema_content=$schema
        echo "$schema_content" > $schema_file
    fi
fi

environment=`get_environment_used`

if [ "$environment" == "error" ]
then
  logerror "File containing restart command /tmp/playground-command does not exist!"
  exit 1 
fi

ret=$(get_sr_url_and_security)

sr_url=$(echo "$ret" | cut -d "@" -f 1)
sr_security=$(echo "$ret" | cut -d "@" -f 2)

bootstrap_server="broker:9092"
container="connect"
sr_url_cli="http://schema-registry:8081"
security=""
if [[ "$environment" == *"ssl"* ]]
then
    sr_url_cli="https://schema-registry:8081"
    security="--property schema.registry.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks --property schema.registry.ssl.truststore.password=confluent --property schema.registry.ssl.keystore.location=/etc/kafka/secrets/kafka.client.keystore.jks --property schema.registry.ssl.keystore.password=confluent --producer.config /etc/kafka/secrets/client_without_interceptors.config"
elif [[ "$environment" == "rbac-sasl-plain" ]]
then
    sr_url_cli="http://schema-registry:8081"
    security="--property basic.auth.credentials.source=USER_INFO --property schema.registry.basic.auth.user.info=clientAvroCli:clientAvroCli --producer.config /etc/kafka/secrets/client_without_interceptors.config"
elif [[ "$environment" == "kerberos" ]]
then
    container="client"
    sr_url_cli="http://schema-registry:8081"
    security="--producer.config /etc/kafka/producer.properties"

    docker exec -i client kinit -k -t /var/lib/secret/kafka-connect.key connect
elif [[ "$environment" == "environment" ]]
then
  if [ -f /tmp/delta_configs/env.delta ]
  then
      source /tmp/delta_configs/env.delta
  else
      logerror "ERROR: /tmp/delta_configs/env.delta has not been generated"
      exit 1
  fi
  if [ ! -f /tmp/delta_configs/ak-tools-ccloud.delta ]
  then
      logerror "ERROR: /tmp/delta_configs/ak-tools-ccloud.delta has not been generated"
      exit 1
  fi
  DIR_CLI="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  dir1=$(echo ${DIR_CLI%/*})
  root_folder=$(echo ${dir1%/*})
  IGNORE_CHECK_FOR_DOCKER_COMPOSE=true
  source $root_folder/scripts/utils.sh
fi

if grep -q "proto3" $schema_file
then
    log "🔮 schema was identified as protobuf"
    schema_type=protobuf
elif grep -q "\$schema" $schema_file
then
    log "🔮 schema was identified as json schema"
    schema_type=json-schema
elif grep -q "_meta" $schema_file
then
    log "🔮 schema was identified as json"
    schema_type=json
elif grep -q "CREATE TABLE" $schema_file
then
    log "🔮 schema was identified as sql"
    schema_type=sql
elif grep -q "\"type\"\s*:\s*\"record\"" $schema_file
then
    log "🔮 schema was identified as avro"
    schema_type=avro
else
    log "📢 no known schema could be identified, payload will be sent as raw data"
    schema_type=raw
fi

case "${schema_type}" in
    json|sql)
        # https://github.com/MaterializeInc/datagen
        set +e
        docker run --rm -i -v $schema_file:/app/schema.$schema_type materialize/datagen -s schema.$schema_type -n $nb_messages --dry-run > $tmp_dir/result.log
        
        nb=$(grep -c "Payload: " $tmp_dir/result.log)
        if [ $nb -eq 0 ]
        then
            logerror "❌ materialize/datagen failed to produce $schema_type "
            cat $tmp_dir/result.log
            exit 1
        fi
        set -e
        cat $tmp_dir/result.log | grep "Payload: " | awk '{print $2}' > $tmp_dir/out.json
        #--record-size 104
    ;;

    avro)
        docker run --rm -v $tmp_dir:/tmp/ vdesabou/avro-tools random /tmp/out.avro --schema-file /tmp/value_schema --count $nb_messages > /dev/null 2>&1
        docker run --rm -v $tmp_dir:/tmp/ vdesabou/avro-tools tojson /tmp/out.avro > $tmp_dir/out.json
    ;;
    json-schema)
        docker run --rm -v $tmp_dir:/tmp/ -e NB_MESSAGES=$nb_messages vdesabou/json-schema-faker > $tmp_dir/out.json
    ;;
    protobuf)
        # https://github.com/JasonkayZK/mock-protobuf.js
        docker run --rm -v $tmp_dir:/tmp/ -v $schema_file:/app/schema.proto -e NB_MESSAGES=$nb_messages vdesabou/protobuf-faker  > $tmp_dir/out.json
    ;;
    raw)
        if jq -e . >/dev/null 2>&1 <<< "$(cat "$schema_file")"
        then
            log "💫 payload is single json, it will be sent as one record"
            jq -c . "$schema_file" > $tmp_dir/minified.json
            for((i=0;i<$nb_messages;i++))
            do
                cat $tmp_dir/minified.json >> $tmp_dir/out.json
            done
        else
            log "💫 payload is not single json, one record per line will be sent"
            input_file=$schema_file
            output_file=$tmp_dir/out.json

            lines_count=0
            stop=0
            while [ $stop != 1 ]
            do
                while IFS= read -r line
                do
                    echo "$line" >> "$output_file"
                    lines_count=$((lines_count+1))
                    if [ $lines_count -ge $nb_messages ]
                    then
                        stop=1
                        break
                    fi
                done < "$input_file"
            done
        fi
    ;;
    *)
        logerror "❌ schema_type name not valid ! Should be one of raw, json, avro, json-schema or protobuf"
        exit 1
    ;;
esac

nb_generated_messages=$(wc -l < $tmp_dir/out.json)
nb_generated_messages=${nb_generated_messages// /}

if [ "$nb_generated_messages" == "0" ]
then
    logerror "❌ records could not be generated!"
    exit 1
fi

if (( nb_generated_messages < 10 ))
then
    log "✨ $nb_generated_messages records were generated"
    cat $tmp_dir/out.json
else
    log "✨ $nb_generated_messages records were generated (only showing first 10)"
    head -n 10 "$tmp_dir/out.json"
fi

playground topic get-number-records --topic $topic > $tmp_dir/result.log 2>$tmp_dir/result.log
set +e
grep "does not exist" $tmp_dir/result.log > /dev/null 2>&1
if [ $? == 0 ]
then
    logwarn "topic $topic does not exist !"
    if [[ "$environment" == "environment" ]]
    then
        if [ "$nb_partitions" != "" ]
        then
            log "⛅ creating topic in confluent cloud with $nb_partitions partitions"
            playground topic create --topic $topic --nb-partitions $nb_partitions
        else
            log "⛅ creating topic in confluent cloud"
            playground topic create --topic $topic
        fi
    fi
else
    if [ "$nb_partitions" != "" ]
    then
        log "--nb-partitions is set, re-creating topic with $nb_partitions partitions"
        playground topic delete --topic $topic
        playground topic create --topic $topic --nb-partitions $nb_partitions
    else
        log "💯 Get number of records in topic $topic"
        tail -1 $tmp_dir/result.log
    fi
fi

if [[ -n "$key" ]]
then
    log "🗝️ key is set $key"
    while read line
    do
        echo "$key|$line" >> $tmp_dir/tempfile
    done < $tmp_dir/out.json

    mv $tmp_dir/tempfile $tmp_dir/out.json

    cat $tmp_dir/out.json
fi

set -e
log "📤 producing $nb_generated_messages records to topic $topic"
case "${schema_type}" in
    json|sql|raw)
        if [[ "$environment" == "environment" ]]
        then
            if [[ -n "$key" ]]
            then
                cat $tmp_dir/out.json | docker run -i --rm -v /tmp/delta_configs/ak-tools-ccloud.delta:/tmp/configuration/ccloud.properties -e BOOTSTRAP_SERVERS="$BOOTSTRAP_SERVERS" ${CP_CONNECT_IMAGE}:${CONNECT_TAG} kafka-console-producer --broker-list $BOOTSTRAP_SERVERS --topic $topic --producer.config /tmp/configuration/ccloud.properties $security --property parse.key=true --property key.separator="|"
            else
                cat $tmp_dir/out.json | docker run -i --rm -v /tmp/delta_configs/ak-tools-ccloud.delta:/tmp/configuration/ccloud.properties -e BOOTSTRAP_SERVERS="$BOOTSTRAP_SERVERS" ${CP_CONNECT_IMAGE}:${CONNECT_TAG} kafka-console-producer --broker-list $BOOTSTRAP_SERVERS --topic $topic --producer.config /tmp/configuration/ccloud.properties $security
            fi
        else
            if [[ -n "$key" ]]
            then
                cat $tmp_dir/out.json | docker exec -i $container kafka-console-producer --broker-list $bootstrap_server --topic $topic $security --property parse.key=true --property key.separator="|"
            else
                cat $tmp_dir/out.json | docker exec -i $container kafka-console-producer --broker-list $bootstrap_server --topic $topic $security
            fi
        fi
    ;;
    *)
        if [[ "$environment" == "environment" ]]
        then
            if [[ -n "$key" ]]
            then
                cat $tmp_dir/out.json | docker run -i --rm -e SCHEMA_REGISTRY_LOG4J_OPTS="-Dlog4j.configuration=file:/etc/kafka/tools-log4j.properties" -e schema_type=$schema_type -e BOOTSTRAP_SERVERS="$BOOTSTRAP_SERVERS" -e SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO="$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" -e SCHEMA_REGISTRY_URL="$SCHEMA_REGISTRY_URL" ${CP_CONNECT_IMAGE}:${CONNECT_TAG} kafka-$schema_type-console-producer --broker-list $BOOTSTRAP_SERVERS --producer-property ssl.endpoint.identification.algorithm=https --producer-property sasl.mechanism=PLAIN --producer-property security.protocol=SASL_SSL --producer-property sasl.jaas.config="$SASL_JAAS_CONFIG" --property basic.auth.credentials.source=USER_INFO --property schema.registry.basic.auth.user.info="$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" --property schema.registry.url=$SCHEMA_REGISTRY_URL --topic $topic $security --property value.schema="$(cat $schema_file)" --property parse.key=true --property key.separator="|" --property key.serializer=org.apache.kafka.common.serialization.StringSerializer
            else
                cat $tmp_dir/out.json | docker run -i --rm -e SCHEMA_REGISTRY_LOG4J_OPTS="-Dlog4j.configuration=file:/etc/kafka/tools-log4j.properties" -e schema_type=$schema_type -e BOOTSTRAP_SERVERS="$BOOTSTRAP_SERVERS" -e SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO="$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" -e SCHEMA_REGISTRY_URL="$SCHEMA_REGISTRY_URL" ${CP_CONNECT_IMAGE}:${CONNECT_TAG} kafka-$schema_type-console-producer --broker-list $BOOTSTRAP_SERVERS --producer-property ssl.endpoint.identification.algorithm=https --producer-property sasl.mechanism=PLAIN --producer-property security.protocol=SASL_SSL --producer-property sasl.jaas.config="$SASL_JAAS_CONFIG" --property basic.auth.credentials.source=USER_INFO --property schema.registry.basic.auth.user.info="$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" --property schema.registry.url=$SCHEMA_REGISTRY_URL --topic $topic $security --property value.schema="$(cat $schema_file)"
            fi
        else
            if [[ -n "$key" ]]
            then
                cat $tmp_dir/out.json | docker exec -e SCHEMA_REGISTRY_LOG4J_OPTS="-Dlog4j.configuration=file:/etc/kafka/tools-log4j.properties" -i $container kafka-$schema_type-console-producer --broker-list $bootstrap_server --property schema.registry.url=$sr_url_cli --topic $topic $security --property value.schema="$(cat $schema_file)" --property parse.key=true --property key.separator="|" --property key.serializer=org.apache.kafka.common.serialization.StringSerializer
            else
                cat $tmp_dir/out.json | docker exec -e SCHEMA_REGISTRY_LOG4J_OPTS="-Dlog4j.configuration=file:/etc/kafka/tools-log4j.properties" -i $container kafka-$schema_type-console-producer --broker-list $bootstrap_server --property schema.registry.url=$sr_url_cli --topic $topic $security --property value.schema="$(cat $schema_file)"
            fi
        fi
    ;;
esac

playground topic get-number-records --topic $topic