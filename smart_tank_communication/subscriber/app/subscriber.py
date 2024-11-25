import paho.mqtt.client as mqtt
from random import randrange
import time

# MQTT broker details
BROKER_IP   = "95.94.45.83"
BROKER_PORT = 1883
BROKER_USER = "pi"
BROKER_PASSWORD = "vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n"

topics = ["temperature", "water-level"]

# Callback function when a message is received
def on_message(client, userdata, message):
    print(f"Received message '{message.payload.decode()}' on topic '{message.topic}'")

# Create a new MQTT client instance
client = mqtt.Client()


# Connect the callback function
client.on_message = on_message

# Connect to the MQTT broker
client.username_pw_set(BROKER_USER, BROKER_PASSWORD)
client.connect(BROKER_IP, BROKER_PORT)

# Subscribe to the topics
for topic in topics:
    client.subscribe(topic)

# Start the loop to process received messages
client.loop_forever()
