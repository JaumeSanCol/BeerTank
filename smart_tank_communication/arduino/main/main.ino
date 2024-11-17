#include <WiFi.h>
#include <PubSubClient.h>
#include "config.h"
#include "bt_mqtt.h"
#include "Arduino.h"


WiFiClient wifiClient;
PubSubClient client(wifiClient);

void setup() {
    Serial.begin(9600);
    pinMode(LED_BUILTIN, OUTPUT);// LED_BUILTIN == Connected to WIFI
    while (!Serial);

    connectToWiFi();
    setupMQTT(client);
}

void loop() { 
    if(WiFi.status() != WL_CONNECTED){
        reconnectToWiFi();
        reconnectMQTT(client);
    }
    else if (!client.connected()) {
        reconnectMQTT(client);
    } else {
      
        client.loop();

        float x = static_cast<float>(rand() % 100); 

        // PUBLISH VALUES
        // publishValues(client, TOPIC_LEVEL, String(x)); // Send data to topic TOPIC_LEVEL

        // // EXAMPLE TO CHECK A TOKEN (WITH MANUAL INSERTION OF THE TOKEN)
        // if (Serial.available() > 0) {
        //     String input = Serial.readStringUntil('\n'); 
        //     input.trim(); 
        //     if (input.length() > 0) {
        
        //         int token=input.toInt();
        //         validateToken(client, token);
        //     }
        // }
        
    }
    timerforresponse();
}
