#include "bt_mqtt.h"
#include "bt_https.h"
#include "config.h"

#include <WiFi.h>
#include <PubSubClient.h>
#include "Arduino.h"


WiFiClient wifiClient;
PubSubClient client(wifiClient);

void setup() {
    Serial.begin(9600);
    pinMode(LED_BUILTIN, OUTPUT);// LED_BUILTIN == Connected to WIFI
    while (!Serial);

    connectToWiFi();
    setupMQTT(client);
    loginToCloud();
}

void loop() { 
    if(WiFi.status() != WL_CONNECTED){
        reconnectToWiFi();
        reconnectMQTT(client);
        loginToCloud();
    }
    else if (!client.connected()) {
        reconnectMQTT(client);
      
        client.loop();
        validateToken(1);
        
    }
}
