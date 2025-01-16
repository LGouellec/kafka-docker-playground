#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh

handle_aws_credentials

PLAYGROUND_ENVIRONMENT=${PLAYGROUND_ENVIRONMENT:-"plaintext"}
playground start-environment --environment "${PLAYGROUND_ENVIRONMENT}" --docker-compose-override-file "${PWD}/docker-compose.plaintext.proxy.yml"

QUEUE_NAME=pg${USER}sqs${TAG}
QUEUE_NAME=${QUEUE_NAME//[-._]/}

QUEUE_URL_RAW=$(aws sqs create-queue --queue-name $QUEUE_NAME | jq .QueueUrl)
AWS_ACCOUNT_NUMBER=$(echo "$QUEUE_URL_RAW" | cut -d "/" -f 4)
# https://docs.amazonaws.cn/sdk-for-net/v3/developer-guide/how-to/sqs/QueueURL.html
# https://{REGION_ENDPOINT}/queue.|api-domain|/{YOUR_ACCOUNT_NUMBER}/{YOUR_QUEUE_NAME}
QUEUE_URL="https://sqs.$AWS_REGION.amazonaws.com/$AWS_ACCOUNT_NUMBER/$QUEUE_NAME"

set +e
log "Delete queue ${QUEUE_URL}"
aws sqs delete-queue --queue-url ${QUEUE_URL}
if [ $? -eq 0 ]
then
     # You must wait 60 seconds after deleting a queue before you can create another with the same name
     log "Sleeping 60 seconds"
     sleep 60
     aws sqs delete-queue --queue-url ${QUEUE_URL}
fi
set -e

log "Create a FIFO queue $QUEUE_NAME"
aws sqs create-queue --queue-name $QUEUE_NAME

function cleanup_cloud_resources {
    set +e
    log "Delete SQS queue ${QUEUE_NAME}"
    check_if_continue
    aws sqs delete-queue --queue-url ${QUEUE_URL}
}
trap cleanup_cloud_resources EXIT

log "Sending messages to $QUEUE_URL"
cd ../../connect/connect-aws-sqs-source
aws sqs send-message-batch --queue-url $QUEUE_URL --entries file://send-message-batch.json
cd -

log "Creating SQS Source connector"
playground connector create-or-update --connector sqs-source  << EOF
{
    "connector.class": "io.confluent.connect.sqs.source.SqsSourceConnector",
    "tasks.max": "1",
    "kafka.topic": "test-sqs-source",
    "sqs.url": "$QUEUE_URL",
    "aws.access.key.id" : "$AWS_ACCESS_KEY_ID",
    "aws.secret.key.id": "$AWS_SECRET_ACCESS_KEY",
    "confluent.license": "",
    "sqs.proxy.url": "http://nginx-proxy:8888",
    "confluent.topic.bootstrap.servers": "broker:9092",
    "confluent.topic.replication.factor": "1",
    "errors.tolerance": "all",
    "errors.log.enable": "true",
    "errors.log.include.messages": "true"
}
EOF

log "Verify we have received the data in test-sqs-source topic"
playground topic consume --topic test-sqs-source --min-expected-messages 2 --timeout 60