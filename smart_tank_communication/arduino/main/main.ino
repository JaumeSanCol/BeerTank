#include "bt_mqtt.h"
#include "bt_https.h"
#include "config.h"

#include <WiFi.h>
#include <PubSubClient.h>
#include "Arduino.h"


WiFiClient wifiClient;
PubSubClient client(wifiClient);
WiFiClientSecure httpsclient;

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);  // LED_BUILTIN == Connected to WIFI
  while (!Serial)
    ;

  connectToWiFi();
  setupMQTT(client);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    reconnectToWiFi();
    reconnectMQTT(client);
  } else if (!client.connected()) {
    reconnectMQTT(client);
  } else {
    client.loop();

    float x = static_cast<float>(rand() % 100);

    // PUBLISH VALUES
    publishValues(client, TOPIC_LEVEL, String(x));

    // validateToken(httpsclient, 1);
  }
}