import json
import logging
import time
from datetime import datetime
from typing import Any, Dict

from kafka import KafkaConsumer, KafkaProducer

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


class KafkaMessageProducer:
    def __init__(self, bootstrap_servers: str, topic: str):
        self.topic = topic
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            value_serializer=lambda x: json.dumps(x).encode("utf-8"),
            retries=5,
        )

    def send_message(self, message: Dict[str, Any]) -> None:
        try:
            # Add timestamp to message
            message["timestamp"] = datetime.now().isoformat()

            # Send the message
            future = self.producer.send(self.topic, value=message)
            # Wait for message to be sent
            future.get(timeout=10)
            logging.info(f"Message sent successfully: {message}")

        except Exception as e:
            logging.error(f"Error sending message: {str(e)}")
            raise

    def close(self):
        self.producer.close()


class KafkaMessageConsumer:
    def __init__(self, bootstrap_servers: str, topic: str, group_id: str):
        self.topic = topic
        self.consumer = KafkaConsumer(
            topic,
            bootstrap_servers=bootstrap_servers,
            auto_offset_reset="earliest",
            enable_auto_commit=True,
            group_id=group_id,
            value_deserializer=lambda x: json.loads(x.decode("utf-8")),
        )

    def consume_messages(self, timeout_ms: int = 1000):
        try:
            while True:
                # Poll for messages
                message_batch = self.consumer.poll(timeout_ms=timeout_ms)

                for topic_partition, messages in message_batch.items():
                    for message in messages:
                        logging.info(f"Received message: {message.value}")
                        # Process message here
                        self.process_message(message.value)

        except KeyboardInterrupt:
            logging.info("Stopping consumer...")
        except Exception as e:
            logging.error(f"Error consuming messages: {str(e)}")
            raise
        finally:
            self.close()

    def process_message(self, message: Dict[str, Any]):
        # Add your message processing logic here
        logging.info(f"Processing message: {message}")

    def close(self):
        self.consumer.close()


def main():
    # Kafka configuration
    BOOTSTRAP_SERVERS = "localhost:30092"
    TOPIC = "test-topic"
    GROUP_ID = "test-group"

    try:
        # Initialize producer
        producer = KafkaMessageProducer(BOOTSTRAP_SERVERS, TOPIC)

        # Send some test messages
        test_messages = [
            {"id": 1, "type": "order", "data": {"product": "laptop", "quantity": 2}},
            {
                "id": 2,
                "type": "user",
                "data": {"name": "John Doe", "email": "john@example.com"},
            },
            {"id": 3, "type": "event", "data": {"name": "login", "user_id": 123}},
        ]

        # Send messages
        for msg in test_messages:
            producer.send_message(msg)
            time.sleep(1)  # Add delay between messages

        # Close producer
        producer.close()

        # Initialize consumer
        consumer = KafkaMessageConsumer(BOOTSTRAP_SERVERS, TOPIC, GROUP_ID)

        # Start consuming messages
        logging.info("Starting to consume messages...")
        consumer.consume_messages()

    except Exception as e:
        logging.error(f"Error in main: {str(e)}")


if __name__ == "__main__":
    main()
