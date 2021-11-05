# KafkaJS client (producer and consumer) (using Confluent Cloud)

## Objective

Quickly test [KafkaJS](https://kafka.js.org) client using Confluent Cloud



## How to run

1. Create `$HOME/.confluent/config`

On the host from which you are running Docker, ensure that you have properly initialized Confluent Cloud CLI and have a valid configuration file at `$HOME/.confluent/config`.

Example:

```bash
$ cat $HOME/.confluent/config
bootstrap.servers=<BROKER ENDPOINT>
ssl.endpoint.identification.algorithm=https
security.protocol=SASL_SSL
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="<API KEY>" password="<API SECRET>";
```

2. Simply run:

```
$ ./start.sh
```
