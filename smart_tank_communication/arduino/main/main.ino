#include <WiFi.h>
#include <PubSubClient.h>
#include "config.h"
#include "functions.h"

WiFiClient wifiClient;
PubSubClient client(wifiClient);

void setup() {
    Serial.begin(9600);
    while (!Serial);

    connectToWiFi();
    setupMQTT(client);
}

void loop() { 
    if (!client.connected()) {
        reconnectMQTT(client);
    } else {
        client.loop();
        float x = static_cast<float>(rand() % 100); 
        publishValues(client, TOPIC_LEVEL, String(x)); // Send data to topic TOPIC_LEVEL
        delay(1000);
    }
}
