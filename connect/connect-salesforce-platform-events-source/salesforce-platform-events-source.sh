#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh



SALESFORCE_USERNAME=${SALESFORCE_USERNAME:-$1}
SALESFORCE_PASSWORD=${SALESFORCE_PASSWORD:-$2}
SALESFORCE_CONSUMER_KEY=${SALESFORCE_CONSUMER_KEY:-$3}
SALESFORCE_CONSUMER_PASSWORD=${SALESFORCE_CONSUMER_PASSWORD:-$4}
SALESFORCE_SECURITY_TOKEN=${SALESFORCE_SECURITY_TOKEN:-$5}
SALESFORCE_INSTANCE=${SALESFORCE_INSTANCE:-"https://login.salesforce.com"}

if [ -z "$SALESFORCE_USERNAME" ]
then
     logerror "SALESFORCE_USERNAME is not set. Export it as environment variable or pass it as argument"
     exit 1
fi

if [ -z "$SALESFORCE_PASSWORD" ]
then
     logerror "SALESFORCE_PASSWORD is not set. Export it as environment variable or pass it as argument"
     exit 1
fi


if [ -z "$SALESFORCE_CONSUMER_KEY" ]
then
     logerror "SALESFORCE_CONSUMER_KEY is not set. Export it as environment variable or pass it as argument"
     exit 1
fi

if [ -z "$SALESFORCE_CONSUMER_PASSWORD" ]
then
     logerror "SALESFORCE_CONSUMER_PASSWORD is not set. Export it as environment variable or pass it as argument"
     exit 1
fi

if [ -z "$SALESFORCE_SECURITY_TOKEN" ]
then
     logerror "SALESFORCE_SECURITY_TOKEN is not set. Export it as environment variable or pass it as argument"
     exit 1
fi

PLAYGROUND_ENVIRONMENT=${PLAYGROUND_ENVIRONMENT:-"plaintext"}
playground start-environment --environment "${PLAYGROUND_ENVIRONMENT}" --docker-compose-override-file "${PWD}/docker-compose.plaintext.yml"

log "Creating Salesforce Platform Events Source connector"
playground connector create-or-update --connector salesforce-platform-events-source --environment "${PLAYGROUND_ENVIRONMENT}" << EOF
{
     "connector.class": "io.confluent.salesforce.SalesforcePlatformEventSourceConnector",
     "kafka.topic": "sfdc-platform-events",
     "tasks.max": "1",
     "curl.logging": "true",
     "salesforce.platform.event.name" : "MyPlatformEvent__e",
     "salesforce.instance" : "$SALESFORCE_INSTANCE",
     "salesforce.username" : "$SALESFORCE_USERNAME",
     "salesforce.password" : "$SALESFORCE_PASSWORD",
     "salesforce.password.token" : "$SALESFORCE_SECURITY_TOKEN",
     "salesforce.consumer.key" : "$SALESFORCE_CONSUMER_KEY",
     "salesforce.consumer.secret" : "$SALESFORCE_CONSUMER_PASSWORD",
     "salesforce.initial.start" : "latest",
     "connection.max.message.size": "10048576",
     "key.converter": "org.apache.kafka.connect.json.JsonConverter",
     "value.converter": "org.apache.kafka.connect.json.JsonConverter",
     "confluent.license": "",
     "confluent.topic.bootstrap.servers": "broker:9092",
     "confluent.topic.replication.factor": "1"
}
EOF

sleep 5

log "Login with sfdx CLI"
docker exec sfdx-cli sh -c "sfdx sfpowerkit:auth:login -u \"$SALESFORCE_USERNAME\" -p \"$SALESFORCE_PASSWORD\" -r \"$SALESFORCE_INSTANCE\" -s \"$SALESFORCE_SECURITY_TOKEN\""

log "Send Platform Events"
docker exec sfdx-cli sh -c "sfdx apex run --target-org \"$SALESFORCE_USERNAME\" -f \"/tmp/event.apex\""

sleep 10

log "Verify we have received the data in sfdc-platform-events topic"
playground topic consume --topic sfdc-platform-events --min-expected-messages 2 --timeout 60