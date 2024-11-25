#ifndef BT_MQTT_H
#define BT_MQTT_H

#include <PubSubClient.h>

void connectToWiFi();
void reconnectToWiFi();
void setupMQTT(PubSubClient& client);
void reconnectMQTT(PubSubClient& client);
void publishValues(PubSubClient& client, const char* topic,String date, const String& value);


#endif
