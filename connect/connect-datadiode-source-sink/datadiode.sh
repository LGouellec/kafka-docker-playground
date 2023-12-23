#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh

PLAYGROUND_ENVIRONMENT=${PLAYGROUND_ENVIRONMENT:-"plaintext"}
playground start-environment --environment "${PLAYGROUND_ENVIRONMENT}" --docker-compose-override-file "${PWD}/docker-compose.plaintext.yml"

log "Creating DataDiode Source connector"
playground connector create-or-update --connector datadiode-source --environment "${PLAYGROUND_ENVIRONMENT}" << EOF
{
     "tasks.max": "1",
     "connector.class": "io.confluent.connect.diode.source.DataDiodeSourceConnector",
     "kafka.topic.prefix": "dest_",
     "key.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
     "value.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
     "header.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
     "diode.port": "3456",
     "diode.encryption.password": "supersecretpassword",
     "diode.encryption.salt": "secretsalt",
     "confluent.license": "",
     "confluent.topic.bootstrap.servers": "broker:9092",
     "confluent.topic.replication.factor": "1",
     "errors.tolerance": "all",
     "errors.log.enable": "true",
     "errors.log.include.messages": "true"
}
EOF

log "Creating DataDiode Sink connector"
playground connector create-or-update --connector datadiode-sink --environment "${PLAYGROUND_ENVIRONMENT}" << EOF
{
     "connector.class": "io.confluent.connect.diode.sink.DataDiodeSinkConnector",
     "tasks.max": "1",
     "topics": "diode",
     "key.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
     "value.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
     "header.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
     "diode.host": "connect",
     "diode.port": "3456",
     "diode.encryption.password": "supersecretpassword",
     "diode.encryption.salt": "secretsalt",
     "confluent.license": "",
     "confluent.topic.bootstrap.servers": "broker:9092",
     "confluent.topic.replication.factor": "1"
}
EOF

sleep 10

log "Send message to diode topic"
playground topic produce -t diode --nb-messages 10 << 'EOF'
This is a message 1
This is a message 2
This is a message 3
This is a message 4
This is a message 5
This is a message 6
This is a message 7
This is a message 8
This is a message 9
This is a message 10
EOF

sleep 5

log "Verifying topic dest_diode"
playground topic consume --topic dest_diode --min-expected-messages 10 --timeout 60