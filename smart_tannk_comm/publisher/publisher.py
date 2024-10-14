import paho.mqtt.client as mqtt
from random import randrange
import time

# MQTT broker details
broker = "mosquitto"  # IP of the Broker server
port = 1883

topics = ["temperature", "water-level"]

# Create a new MQTT client instance
client = mqtt.Client()

# Connect to the MQTT broker
client.connect(broker, port)

# Publish messages in a loop
try:
    while True:
        for topic in topics:
            message = f"{topic}: {randrange(10)}"
            result = client.publish(topic, message)
            status = result[0]
            if status == 0:
                print(f"Sent '{message}' to topic '{topic}'")
            else:
                print(f"Failed to send message to topic {topic}")
        time.sleep(5)  # Publish a message every 5 seconds
except KeyboardInterrupt:
    print("Publisher stopped")
    client.disconnect()

