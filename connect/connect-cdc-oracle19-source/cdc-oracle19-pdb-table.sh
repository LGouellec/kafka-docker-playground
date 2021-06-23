#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh

export ORACLE_IMAGE="oracle/database:19.3.0-ee"

if test -z "$(docker images -q $ORACLE_IMAGE)"
then
    if [ ! -f ${DIR}/LINUX.X64_193000_db_home.zip ]
    then
        logerror "ERROR: ${DIR}/LINUX.X64_193000_db_home.zip is missing. It must be downloaded manually in order to acknowledge user agreement"
        exit 1
    fi
    log "Building $ORACLE_IMAGE docker image..it can take a while...(more than 15 minutes!)"
    OLDDIR=$PWD
    rm -rf ${DIR}/docker-images
    git clone https://github.com/oracle/docker-images.git

    cp ${DIR}/LINUX.X64_193000_db_home.zip ${DIR}/docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/LINUX.X64_193000_db_home.zip
    cd ${DIR}/docker-images/OracleDatabase/SingleInstance/dockerfiles
    ./buildContainerImage.sh -v 19.3.0 -e
    rm -rf ${DIR}/docker-images
    cd ${OLDDIR}
fi

if [ ! -z "$CI" ]
then
     # running with github actions
     aws s3 cp s3://kafka-docker-playground/internal/confluentinc-kafka-connect-oracle-cdc-1.2.0-SNAPSHOT.zip .
     export CONNECTOR_ZIP="$PWD/confluentinc-kafka-connect-oracle-cdc-1.2.0-SNAPSHOT.zip"
fi

if [ -z "$CONNECTOR_ZIP" ]
then
     logerror "CONNECTOR_ZIP environment variable must be set with the path to the confluentinc-kafka-connect-oracle-cdc SNAPSHOT zip file"
     exit 1
fi

if [ ! -f "$CONNECTOR_ZIP" ]
then
     logerror "File set with CONNECTOR_ZIP ($CONNECTOR_ZIP) does not exist !"
     exit 1
fi

${DIR}/../../environment/plaintext/start.sh "${PWD}/docker-compose.plaintext.pdb-table.yml"


# Verify Oracle DB has started within MAX_WAIT seconds
MAX_WAIT=2500
CUR_WAIT=0
log "Waiting up to $MAX_WAIT seconds for Oracle DB to start"
docker container logs oracle > /tmp/out.txt 2>&1
while [[ ! $(cat /tmp/out.txt) =~ "DONE: Executing user defined scripts" ]]; do
sleep 10
docker container logs oracle > /tmp/out.txt 2>&1
CUR_WAIT=$(( CUR_WAIT+10 ))
if [[ "$CUR_WAIT" -gt "$MAX_WAIT" ]]; then
     logerror "ERROR: The logs in oracle container do not show 'DONE: Executing user defined scripts' after $MAX_WAIT seconds. Please troubleshoot with 'docker container ps' and 'docker container logs'.\n"
     exit 1
fi
done
log "Oracle DB has started!"
sleep 60

log "Grant select on CUSTOMERS table"
docker exec -i oracle sqlplus C\#\#MYUSER/mypassword@//localhost:1521/ORCLPDB1 << EOF
     ALTER SESSION SET CONTAINER=ORCLPDB1;
     GRANT select on CUSTOMERS TO C##MYUSER;
EOF

# Create a redo-log-topic. Please make sure you create a topic with the same name you will use for "redo.log.topic.name": "redo-log-topic"
# CC-13104
docker exec connect kafka-topics --create --topic redo-log-topic --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --config cleanup.policy=delete --config retention.ms=120960000
log "redo-log-topic is created"
sleep 5

log "Creating Oracle source connector"
curl -X PUT \
     -H "Content-Type: application/json" \
     --data '{
               "connector.class": "io.confluent.connect.oracle.cdc.OracleCdcSourceConnector",
               "tasks.max":2,
               "key.converter": "io.confluent.connect.avro.AvroConverter",
               "key.converter.schema.registry.url": "http://schema-registry:8081",
               "value.converter": "io.confluent.connect.avro.AvroConverter",
               "value.converter.schema.registry.url": "http://schema-registry:8081",
               "confluent.license": "",
               "confluent.topic.bootstrap.servers": "broker:9092",
               "confluent.topic.replication.factor": "1",
               "oracle.server": "oracle",
               "oracle.port": 1521,
               "oracle.sid": "ORCLCDB",
               "oracle.pdb.name": "ORCLPDB1",
               "oracle.username": "C##MYUSER",
               "oracle.password": "mypassword",
               "start.from":"snapshot",
               "redo.log.topic.name": "redo-log-topic",
               "redo.log.consumer.bootstrap.servers":"broker:9092",
               "table.inclusion.regex": "ORCLPDB1[.].*[.]CUSTOMERS",
               "table.topic.name.template": "${databaseName}.${schemaName}.${tableName}",
               "numeric.mapping": "best_fit",
               "connection.pool.max.size": 20,
               "confluent.topic.replication.factor":1
          }' \
     http://localhost:8083/connectors/cdc-oracle-source-pdb/config | jq .

log "Waiting 60s for connector to read existing data"
sleep 60

log "Running SQL scripts"
for script in ${DIR}/sample-sql-scripts/*
do
     $script "ORCLPDB1"
done

log "Waiting 60s for connector to read new data"
sleep 60

log "Verifying topic ORCLPDB1.C__MYUSER.CUSTOMERS: there should be 10 records"
timeout 60 docker exec connect kafka-avro-console-consumer -bootstrap-server broker:9092 --property schema.registry.url=http://schema-registry:8081 --topic ORCLPDB1.C__MYUSER.CUSTOMERS --from-beginning --max-messages 10 > /tmp/result.log  2>&1
cat /tmp/result.log
log "Check there is 5 snapshots events"
if [ $(grep -c "op_type\":{\"string\":\"R\"}" /tmp/result.log) -ne 5 ]
then
     logerror "Did not get expected results"
     exit 1
fi
log "Check there is 2 insert events"
if [ $(grep -c "op_type\":{\"string\":\"I\"}" /tmp/result.log) -ne 2 ]
then
     logerror "Did not get expected results"
     exit 1
fi
log "Check there is 2 update events"
if [ $(grep -c "op_type\":{\"string\":\"U\"}" /tmp/result.log) -ne 2 ]
then
     logerror "Did not get expected results"
     exit 1
fi
log "Check there is 1 delete events"
if [ $(grep -c "op_type\":{\"string\":\"D\"}" /tmp/result.log) -ne 1 ]
then
     logerror "Did not get expected results"
     exit 1
fi

log "Verifying topic redo-log-topic: there should be 5 records"
timeout 60 docker exec connect kafka-avro-console-consumer -bootstrap-server broker:9092 --property schema.registry.url=http://schema-registry:8081 --topic redo-log-topic --from-beginning --max-messages 5