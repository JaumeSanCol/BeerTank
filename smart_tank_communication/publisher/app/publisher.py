import paho.mqtt.client as mqtt
from random import randrange
import time

# MQTT broker details
BROKER_IP   = "95.94.45.83"
BROKER_PORT = 1883
BROKER_USER = "pi"
BROKER_PASSWORD = "vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n"

topics = ["temperature", "water-level"]
topic="response-token"

# Create a new MQTT client instance
client = mqtt.Client()

# Connect to the MQTT broker
client.username_pw_set(BROKER_USER, BROKER_PASSWORD)
client.connect(BROKER_IP, BROKER_PORT)

# Publish messages in a loop
try:
    while True:
            # message = f"{topic}: {randrange(10)}"
            message= "3333:1"
            result = client.publish(topic, message)
            status = result[0]
            if status == 0:
                print(f"Sent '{message}' to topic '{topic}'")
            else:
                print(f"Failed to send message to topic {topic}")  # Publish a message every 1 second
            time.sleep(1)
except KeyboardInterrupt:
    print("Publisher stopped")
    client.disconnect()

