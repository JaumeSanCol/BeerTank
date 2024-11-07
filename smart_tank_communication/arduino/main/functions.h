#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include <PubSubClient.h>

void connectToWiFi();
void setupMQTT(PubSubClient& client);
void reconnectMQTT(PubSubClient& client);
void publishValues(PubSubClient& client, const char* topic, const String& value);
void readValues(char* topic, byte* payload, unsigned int length);

#endif
