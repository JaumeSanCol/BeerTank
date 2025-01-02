#pragma once

#include "config.h"

// WiFi Configuration
const char* ssid = "Linkem_4ACACB";  
const char* pass = "jqpyqvre";  

// Configuration of the broker MQTT
const char* BROKER_IP = "95.94.45.83";
const int BROKER_PORT = 1883;
const char* BROKER_USER = "pi";
const char* BROKER_PASSWORD = "vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n";
const char* ARDUINO_ID = "test";

// Topics MQTT
const char* TOPIC_TEMP = "temperature";
const char* TOPIC_LEVEL = "water-level";

// HTTPS
// API endpoint
const char* server = "sci-cloudapp.onrender.com"; 
const int httpsPort = 443; 


