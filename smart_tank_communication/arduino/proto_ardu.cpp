#include <WiFi.h>            // Change to WiFi library for ESP32
#include <PubSubClient.h>

// Wi-Fi credentials
const char* ssid = "OPPO Reno6 5G";
const char* password = "i5ivve57";

// MQTT Broker IP address (Raspberry Pi)
const char* mqtt_server = "IP_Raspberry_Pi";

// MQTT connection variables
WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(115200);      // Set baud rate to 115200 for ESP32
  
  // Connect to the Wi-Fi network
  setup_wifi();
  
  // Configure MQTT server
  client.setServer(mqtt_server, 1883);
  
  // Try to connect to the MQTT server
  while (!client.connected()) {
    Serial.print("Connecting to MQTT broker...");
    if (client.connect("ESP32Client")) {  // Change client name if needed
      Serial.println("connected!");
    } else {
      Serial.print("failed with state ");
      Serial.print(client.state());
      delay(2000);
    }
  }
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  
  // Wait until connected to Wi-Fi
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("Connected to Wi-Fi");
  Serial.println(WiFi.localIP());
}

void loop() {
  // Ensure connection to the MQTT broker
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Example: publish a message to the "test/arduino" topic
  String message = "Hello from ESP32!";
  client.publish("test/arduino", message.c_str());
  
  delay(5000); // Publish message every 5 seconds
}

void reconnect() {
  // Try to reconnect to the MQTT broker
  while (!client.connected()) {
    Serial.print("Attempting to reconnect...");
    if (client.connect("ESP32Client")) {  // Change client name if needed
      Serial.println("connected!");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" trying again in 5 seconds");
      delay(5000);
    }
  }
}
