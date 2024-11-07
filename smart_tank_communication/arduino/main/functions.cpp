#include "functions.h"
#include "config.h"
#include <WiFi.h>
#include <PubSubClient.h>

void connectToWiFi() {
    WiFi.begin(ssid, pass);
    while (WiFi.status() != WL_CONNECTED) {
        Serial.print("Connecting to WiFi...");
        delay(1000);
    }
    Serial.println("Connected to WiFi");
}

void setupMQTT(PubSubClient& client) {
    client.setServer(BROKER_IP, BROKER_PORT);
    if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
        Serial.println("Connected to the MQTT broker at " + String(BROKER_IP));
        client.subscribe(TOPIC_TEMP);
    } else {
        Serial.print("Failed to connect, return code: ");
        Serial.println(client.state());
    }
    client.setCallback(readValues);
}

void reconnectMQTT(PubSubClient& client) {
    Serial.println("Connection lost: Reconnecting...");
    while (!client.connected()) {
        if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
            Serial.println("Reconnected to MQTT broker");
            client.subscribe(TOPIC_LEVEL);
        } else {
            Serial.print("Failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void publishValues(PubSubClient& client, const char* topic, const String& value) {
    String message = String(topic) + ": " + value;
    if (client.publish(topic, message.c_str())) {
        Serial.println("Published: " + message + " to topic: " + String(topic));
    } else {
        Serial.println("Failed to publish " + String(topic) + " message");
    }
}

void readValues(char* topic, byte* payload, unsigned int length) {
    String message;
    for (int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    if (show_reading) {
        Serial.print("Received: ");
        Serial.println(message + " on topic: " + topic);
    }
}
