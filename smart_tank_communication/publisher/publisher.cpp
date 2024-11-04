#include <SPI.h>
#include <WiFiNINA.h>
#include <PubSubClient.h> 
#include <ctime>   

// Broker configurations
const char* BROKER_IP = "95.94.45.83";
const int BROKER_PORT = 1883; 
const char* BROKER_USER = "pi"; 
const char* BROKER_PASSWORD = "vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n"; 
const char* ARDUINO_ID = "test"; 

char ssid[] = "OPPO Reno6 5G"; 
char pass[] = "i5ivve57";      

// Define topics
const char* TOPIC_TEMP = "temperature";
const char* TOPIC_LEVEL = "level";

// Create a client instance
WiFiClient wifiClient;
PubSubClient client(wifiClient);

void setup() 
{
    Serial.begin(9600);
    while (!Serial);
    srand(static_cast<unsigned int>(time(0))); // Initialize random seed

    // Connect to WiFi
    WiFi.begin(ssid, pass);
    while (WiFi.status() != WL_CONNECTED) 
    {
        Serial.print("Connecting to WiFi....");
        delay(1000);
    }
    Serial.println("Connected to WiFi");

    // Set up the MQTT server
    client.setServer(BROKER_IP, BROKER_PORT);

    // Connect to the broker
    if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
        Serial.println("Connected to the broker MQTT on " + String(BROKER_IP));
    } else {
        Serial.print("Failed to connect, return code: ");
        Serial.println(client.state());
    }
}

void publish(float temperature, float level) {
    // Create payload messages
    String tempMessage = "Temperature: " + String(temperature);
    String levelMessage = "Level: " + String(level);

    // Publish temperature
    if (client.publish(TOPIC_TEMP, tempMessage.c_str())) {
        Serial.println("Published: " + tempMessage + " to topic: " + String(TOPIC_TEMP));
    } else {
        Serial.println("Failed to publish temperature message");
    }

    // Publish level
    if (client.publish(TOPIC_LEVEL, levelMessage.c_str())) {
        Serial.println("Published: " + levelMessage + " to topic: " + String(TOPIC_LEVEL));
    } else {
        Serial.println("Failed to publish level message");
    }
}

void loop() { 
    if (!client.connected()) {
        // Reconnect if connection is lost
        client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD);
    }

    client.loop(); // Keep the connection active

    // Generate and publish values
    float x = static_cast<float>(rand() % 100);
    publish(x, x);
    delay(1000); // Wait for 1 second
}
