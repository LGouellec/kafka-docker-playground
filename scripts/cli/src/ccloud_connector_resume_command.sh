connector="${args[--connector]}"

if [[ ! -n "$connector" ]]
then
    set +e
    log "✨ --connector flag was not provided, applying command to all ccloud connectors"
    connector=$(playground get-ccloud-connector-list)
    if [ $? -ne 0 ]
    then
        logerror "❌ Could not get list of connectors"
        echo "$connector"
        exit 1
    fi
    if [ "$connector" == "" ]
    then
        logerror "💤 No ccloud connector is running !"
        exit 1
    fi
    set -e
fi

items=($connector)
for connector in ${items[@]}
do
    log "⏯️ Resuming ccloud connector $connector"
    curl -s --request PUT "https://api.confluent.cloud/connect/v1/environments/$environment/clusters/$cluster/connectors/$connector/resume" --header "authorization: Basic $authorization" | jq .

    sleep 3
    playground ccloud-connector status --connector $connector
done
