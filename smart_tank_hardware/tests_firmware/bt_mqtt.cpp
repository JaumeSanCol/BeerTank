#pragma once

#include "bt_mqtt.h"
#include "config.h"
#include <WiFi.h>
#include <PubSubClient.h>
#include <RTClib.h>

void connectToWiFi() {
    WiFi.begin(ssid, pass);
    while (WiFi.status() != WL_CONNECTED) {
        Serial.println("Connecting to WiFi...");
        delay(1000);
    }
    Serial.println("Connected to WiFi");
    digitalWrite(LED_BUILTIN, HIGH);
}

void reconnectToWiFi(){
    Serial.println("Connection WIFI Lost: Reconnecting...");
    digitalWrite(LED_BUILTIN, LOW);
    connectToWiFi();
}


void setupMQTT(PubSubClient& client) {
    client.setServer(BROKER_IP, BROKER_PORT);
    if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
        Serial.println("Connected to the MQTT broker at " + String(BROKER_IP));
    } else {
        Serial.print("Failed to connect, return code: ");
        Serial.println(client.state());
    }
}


void reconnectMQTT(PubSubClient& client) {
    Serial.println("Connection with broker lost: Reconnecting...");
    while (!client.connected()) {
        if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
            Serial.println("Reconnected to MQTT broker");
        } else {
            Serial.print("Connection to MQTT Failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void publishValues(PubSubClient& client, const char* topic, const String& value) {
    // String message = String(topic) + ": " + value;
    String tank_id=ARDUINO_ID;
    String message = tank_id +  "%" + value;
    if (client.publish(topic, message.c_str())) {
        Serial.println("Published: " + message + " to topic: " + String(topic));
    } else {
        Serial.println("Failed to publish " + String(topic) + " message");
    }
}



