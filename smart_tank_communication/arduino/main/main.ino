#include "lib/bt_mqtt.h"
#include "lib/bt_https.h"
#include "lib/config.h"

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
    setupMQTT();
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
      
        CLIENT.loop();
        validateToken(1);
        
    }
}
