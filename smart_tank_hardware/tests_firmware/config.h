#ifndef CONFIG_H
#define CONFIG_H

// WiFi Configuration
extern const char* ssid;
extern const char* pass;

// Configuration of the broker MQTT
extern const char* BROKER_IP;
extern const int BROKER_PORT;
extern const char* BROKER_USER;
extern const char* BROKER_PASSWORD;
extern const char* ARDUINO_ID;

// Topics MQTT
extern const char* TOPIC_TEMP;
extern const char* TOPIC_LEVEL;

// API endpoint
extern const char* server ; 
extern const int httpsPort ; 


#endif
