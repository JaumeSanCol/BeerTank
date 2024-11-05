#include <WiFi.h>          
#include <PubSubClient.h>     // PubSubClient for MQTT

// Broker configurations
const char* BROKER_IP = "95.94.45.83";
const int BROKER_PORT = 1883;
const char* BROKER_USER = "pi";
const char* BROKER_PASSWORD = "vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n";
const char* ARDUINO_ID = "test";

// Prototype Network (simulates the bar network)
char ssid[] = "OPPO Reno6 5G";  
char pass[] = "i5ivve57";       

// Topics
const char* TOPIC_TEMP = "temperature";
const char* TOPIC_LEVEL = "water-level";

const bool show_reading=false;  // Hide or display the readings

// Create WiFi and MQTT clients
WiFiClient wifiClient;
PubSubClient client(wifiClient);

void setup() 
{
    Serial.begin(9600);
    while (!Serial);

    // Connect to WiFi
    WiFi.begin(ssid, pass);
    while (WiFi.status() != WL_CONNECTED) 
    {
        Serial.print("Connecting to WiFi...");
        delay(1000);
    }
    Serial.println("Connected to WiFi");

    // Set up the MQTT server
    client.setServer(BROKER_IP, BROKER_PORT);

    // Connect to the broker
    if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
        Serial.println("Connected to the MQTT broker at " + String(BROKER_IP));
        client.subscribe(TOPIC_TEMP); 
    } else {
        Serial.print("Failed to connect, return code: ");
        Serial.println(client.state());
    }

    // Define the callback
    client.setCallback(readValues);
}

void publishValues(const char* topic, const String& value) {
    // Create payload message
    String message = String(topic) + ": " + value;

    // Publish value
    if (client.publish(topic, message.c_str())) {
        Serial.println("Published: " + message + " to topic: " + String(topic));
    } else {
        Serial.println("Failed to publish " + String(topic) + " message");
    }
}
void readValues(char* topic, byte* payload, unsigned int length) {
    String message;
    for (int i = 0; i < length; i++) {
        message += (char)payload[i]; // Build the message from payload bytes
    }
    if(show_reading){ // Print the received message 
      Serial.print("Received: ");
      Serial.println(message + " on topic: " + topic); 
    }
    
}

void loop() { 
    if (!client.connected()) {
      // Reconnect if connection is lost
      Serial.println("Connection lost: Reconnecting...");
      client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD);
      client.subscribe(TOPIC_LEVEL); 
    }
    else{
      // Keep the connection active
      client.loop();
      
      // Generate and publish values
      float x = static_cast<float>(rand() % 100); // Generate a random number between 0 and 99
      publishValues(TOPIC_LEVEL, String(x));
      delay(1000); // Wait for 1 second
    }
}
