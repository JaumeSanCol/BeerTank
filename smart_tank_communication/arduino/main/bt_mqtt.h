#ifndef BT_MQTT_H
#define BT_MQTT_H

#include <PubSubClient.h>

void connectToWiFi();
void reconnectToWiFi();
void setupMQTT(PubSubClient& client);
void reconnectMQTT(PubSubClient& client);
void publishValues(PubSubClient& client, const char* topic, const String& value);
void readValues(char* topic, byte* payload, unsigned int length);
void validateToken(PubSubClient& client, int token);
void timerforresponse();

#endif
