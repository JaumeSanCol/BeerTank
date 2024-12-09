import paho.mqtt.client as mqtt
from random import randrange
import config, bt_mqtt

# Create a new MQTT client instance
client = mqtt.Client()

# Connect the callback function
client.on_message = bt_mqtt.on_message

# Connect to the broker
bt_mqtt.connectMQTT(client)

bt_mqtt.subscribe(client)

# Start the loop to process received messages
client.loop_forever()
