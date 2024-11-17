#ifndef CONFIG_H
#define CONFIG_H

extern const char* ntpServer;  // You can use other NTP servers
extern const long  utcOffsetInSeconds ;  
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
extern const char* TOPIC_TOKEN;
extern const char* TOPIC_RESPONSE;

// Validation
extern const int timeout;
extern int token_to_validate;
extern bool validation_result; 
extern bool token_sent;
extern bool response_received;
extern int start_time;
#endif
