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
        client.subscribe(TOPIC_RESPONSE);
    } else {
        Serial.print("Failed to connect, return code: ");
        Serial.println(client.state());
    }
    client.setCallback(readValues);
}


void reconnectMQTT(PubSubClient& client) {
    Serial.println("Connection with broker lost: Reconnecting...");
    while (!client.connected()) {
        if (client.connect(ARDUINO_ID, BROKER_USER, BROKER_PASSWORD)) {
            Serial.println("Reconnected to MQTT broker");
            client.subscribe(TOPIC_RESPONSE);
        } else {
            Serial.print("Failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void publishValues(PubSubClient& client, const char* topic, String date, const String& value) {
    // String message = String(topic) + ": " + value;
    String tank_id=ARDUINO_ID;
    String message = tank_id + "%" + date + "%" + value;
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
    int receivedToken = message.substring(0, message.indexOf('%')).toInt();
    int response = message.substring(message.indexOf('%') + 1).toInt();
    //Serial.println(receivedToken);
    if (receivedToken == token_to_validate) {
        response_received=true;
        validation_result = (response == 1); // 1 Approved 0 Denied
        Serial.print("Token validation ");
        Serial.println(validation_result ? "Approved" : "Denied");
        token_to_validate=0;
        token_sent=false;
    }
}

void validateToken(PubSubClient& client, int token){
    String message = String(token);
    String topic=TOPIC_TOKEN;
    if (client.publish(TOPIC_TOKEN, message.c_str())) {
        Serial.println("Published: " + message + " to topic: " + topic);
    } else {
        Serial.println("Failed to publish " + topic + " message");
    }
    token_sent=true;
    start_time = millis();
    response_received = false;  
    Serial.print("Validation for token: ");
    Serial.println(token);
    token_to_validate=token;
}
void timerforresponse(){
    if (token_sent && !response_received && millis() - start_time > timeout) {
        Serial.println("Error: No response for validation");
        response_received = true;
        token_to_validate=0;
        token_sent=false;
    }
}
