import config
import cloud
from datetime import datetime

# Connect to the broker
def connectMQTT(client):
    client.username_pw_set(config.BROKER_USER, config.BROKER_PASSWORD)
    client.connect(config.BROKER_IP, config.BROKER_PORT)
    client.subscribe(config.TOPIC_TOKEN)

# Publish topics
def publish(client,message,topic):
    try:
        result = client.publish(topic, message)
        status = result[0]
        if status == 0:
            print(f"Sent '{message}' to topic '{topic}'")
        else:
            print(f"Failed to send message to topic {topic}")  # Publish a message every 1 second
    except KeyboardInterrupt:
        print("Error while publishing: ",topic)
        
# Subscribe to the topics
def subscribe(client):
    for topic in config.SUBS:
        client.subscribe(topic)
        
# Callback function when a message is received
def on_message(client, userdata, message):
    print(f"Received message '{message.payload.decode()}' on topic '{message.topic}'")
    if message.topic==config.TOPIC_TOKEN:
        token=int(message.payload.decode())
        vali=cloud.validateToken(token)
        if vali:
            approveToken(client,token)
        else:
            denyToken(client,token)
    else:
        sensorData(message,message.topic)
            
# Sent the approval for the token            
def approveToken(client,token):
    message=token+":1"
    publish(client,message,config.TOPIC_RESPONSE)
    print(f"Sent Token '{token}': Approval'")
    
# Sent the denial for the token    
def denyToken(client,token):
    message=token+":0"
    publish(client,message,config.TOPIC_RESPONSE)
    print(f"Sent Token '{token}': Denial'")
    
def sensorData(message, topic):
    parts = message.split('%')

    id_tank_str = parts[0]
    date_str = parts[1]
    value_str = parts[2]

    # Convert to appropriate types
    id_tank = int(id_tank_str)
    date = datetime.strptime(date_str, "%d/%m/%y %H:%M:%S")
    value = int(value_str)
    
    cloud.storeValue(id_tank,date,value)
    print(f"Value of '{topic}' stored'")


