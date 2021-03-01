package com.github.vdesabou;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.producer.Callback;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.config.SaslConfigs;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import java.util.Properties;
import java.util.concurrent.TimeUnit;
import com.github.vdesabou.Customer;
import com.github.vdesabou.Product;
import com.github.javafaker.Faker;

public class SimpleProducer {

    private static final String TOPIC = "topicrecordnamestrategy";

    public static void main(String[] args) throws InterruptedException {


        Properties props = new Properties();

        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker:9092");

        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 20000);
        props.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, 500);
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);

        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);

        // Schema Registry specific settings
        props.put("schema.registry.url", "http://schema-registry:8081");

        props.put("value.subject.name.strategy", "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy");


        System.out.println("Sending data to `topicrecordnamestrategy` topic. Properties: " + props.toString());

        Faker faker = new Faker();

        String key = "alice";
        Producer<String, Customer> producer = new KafkaProducer<>(props);
        Producer<String, Product> producer2 = new KafkaProducer<>(props);
            long i = 0;

            while (true) {

                Customer customer = Customer.newBuilder()
                .setCount(i)
                .setFirstName(faker.name().firstName())
                .setLastName(faker.name().lastName())
                .setAddress(faker.address().streetAddress())
                .build();



                ProducerRecord<String, Customer> record = new ProducerRecord<>(TOPIC, key, customer);
                System.out.println("Sending " + record.key() + " " + record.value());
                producer.send(record, new Callback() {
                    @Override
                    public void onCompletion(RecordMetadata metadata, Exception exception) {
                        if (exception == null) {
                            System.out.printf("Produced record to topic %s partition [%d] @ offset %d%n", metadata.topic(), metadata.partition(), metadata.offset());
                        } else {
                            exception.printStackTrace();
                        }
                    }
                });

                Product product = Product.newBuilder()
                .setId(i)
                .setName(faker.name().firstName())
                .build();

                ProducerRecord<String, Product> record2 = new ProducerRecord<>(TOPIC, key, product);
                System.out.println("Sending " + record2.key() + " " + record2.value());
                producer2.send(record2, new Callback() {
                    @Override
                    public void onCompletion(RecordMetadata metadata, Exception exception) {
                        if (exception == null) {
                            System.out.printf("Produced record to topic %s partition [%d] @ offset %d%n", metadata.topic(), metadata.partition(), metadata.offset());
                        } else {
                            exception.printStackTrace();
                        }
                    }
                });

                producer.flush();
                i++;
                TimeUnit.MILLISECONDS.sleep(5000);
            }
    }
}

