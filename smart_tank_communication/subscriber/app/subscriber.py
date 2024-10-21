import paho.mqtt.client as mqtt
from random import randrange
import time

# MQTT broker details
broker = "localhost"  # IP of the Broker server
port = 1883

topics = ["temperature", "water-level"]

# Callback function when a message is received
def on_message(client, userdata, message):
    print(f"Received message '{message.payload.decode()}' on topic '{message.topic}'")

# Create a new MQTT client instance
client = mqtt.Client()

# Connect the callback function
client.on_message = on_message

# Connect to the MQTT broker
client.connect(broker, port)

# Subscribe to the topics
for topic in topics:
    client.subscribe(topic)

# Start the loop to process received messages
client.loop_forever()
