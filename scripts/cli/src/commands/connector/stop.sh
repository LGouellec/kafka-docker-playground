get_connect_url_and_security

connector="${args[--connector]}"
verbose="${args[--verbose]}"

tag=$(docker ps --format '{{.Image}}' | egrep 'confluentinc/cp-.*-connect-base:' | awk -F':' '{print $2}')
if [ $? != 0 ] || [ "$tag" == "" ]
then
    logerror "Could not find current CP version from docker ps"
    exit 1
fi

if ! version_gt $tag "7.4.99"; then
    logerror "❌ stop connector is available since CP 7.5 only"
    exit 1
fi

if [[ ! -n "$connector" ]]
then
    connector=$(playground get-connector-list)
    if [ "$connector" == "" ]
    then
        logerror "💤 No connector is running !"
        exit 1
    fi
fi

items=($connector)
length=${#items[@]}
if ((length > 1))
then
    log "✨ --connector flag was not provided, applying command to all connectors"
fi
for connector in ${items[@]}
do
    log "🛑 Stopping connector $connector"
    if [[ -n "$verbose" ]]
    then
        log "🐞 curl command used"
        echo "curl $security -s -X PUT -H "Content-Type: application/json" "$connect_url/connectors/$connector/stop""
    fi
    curl $security -s -X PUT -H "Content-Type: application/json" "$connect_url/connectors/$connector/stop" | jq .

    sleep 1
    playground connector status --connector $connector
done