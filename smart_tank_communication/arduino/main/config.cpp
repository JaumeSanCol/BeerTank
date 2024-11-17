#include "config.h"

// WiFi Configuration
const char* ssid = "OPPO Reno6 5G";  
const char* pass = "i5ivve57";       

// Configuration of the broker MQTT
const char* BROKER_IP = "95.94.45.83";
const int BROKER_PORT = 1883;
const char* BROKER_USER = "pi";
const char* BROKER_PASSWORD = "vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n";
const char* ARDUINO_ID = "test";

// Topics MQTT
const char* TOPIC_TEMP = "temperature";
const char* TOPIC_LEVEL = "water-level";
const char* TOPIC_TOKEN = "validate-token";
const char* TOPIC_RESPONSE = "response-token";

// Validation of Tokens

const int timeout=5000;
int token_to_validate=0;
bool validation_result = false;
bool token_sent=false; 
bool response_received = false;
int start_time=0;

