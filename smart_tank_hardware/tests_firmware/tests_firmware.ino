#pragma once

#include <WiFi.h>
#include <PubSubClient.h>
#include <dht11.h>
#include <string.h>
#include "SPI.h"
#include "MFRC522.h"
#include "Vector.h"
#include "bt_mqtt.h"
#include "bt_https.h"
#include "config.h"
#include "Arduino.h"



#define RST_PIN 9  // RES pin
#define SS_PIN 10  // SDA (SS) pin
#define LED_PIN 6
#define VALVE_PIN 4
#define FLUX_PIN 3
#define DHT11_PIN 5

struct UID {
  String name;
  byte uid[7];
};

// TEMPERATURE
dht11 DHT11; 
unsigned long lastReadTime = 0; // Variabile per tracciare l'ultimo momento di lettura
const unsigned long interval = 5000;

// RFID
MFRC522 mfrc522(SS_PIN, RST_PIN);
Vector<UID> UIDs;
bool isPouring = false;
bool pouringEnded = true;

// FLUX SENSOR
volatile int pulseCount;
float flowRate;
unsigned long flowMilliLitres;
unsigned long totalMilliLitres;
unsigned long oldTime;
float calibrationFactor = 4.5;

//WIFI
WiFiClient wifiClient;
PubSubClient client(wifiClient);
WiFiClientSecure httpsclient;

void setup() {

  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(FLUX_PIN, INPUT_PULLUP);
  pinMode(VALVE_PIN, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  while (!Serial);

  //WIFI
  connectToWiFi();
  setupMQTT(client);

  //RFID
  SPI.begin(); // Inizializza SPI
  mfrc522.PCD_Init(); // Inizializza il modulo MFRC522
  Serial.println("Avvicina un tag NFC al lettore...");

  //TEST POPULATION
  byte sbyte[7] = { 4, 197, 86, 97, 16, 2, 137 };
  byte bbyte[7] = { 4, 127, 179, 222, 16, 1, 137 };
  UID small;
  UID big;
  small.name = "smallcup";
  big.name = "bigcup";
  memcpy(small.uid, sbyte, 7);
  memcpy(big.uid, bbyte, 7);
  UIDs.push_back(small);
  UIDs.push_back(big);
  
  
  pulseCount = 0;
  flowRate = 0;
  flowMilliLitres = 0;
  totalMilliLitres = 0;
  oldTime = 0;
  isPouring = false;
  pouringEnded = true;

  digitalWrite(VALVE_PIN, LOW);
  digitalWrite(LED_PIN, LOW);

  attachInterrupt(digitalPinToInterrupt(FLUX_PIN), PulseCounter, FALLING);

  Serial.println("Setup done!");
}

void loop() {

  // WIFI COMMUNICATION
  /*
  if (WiFi.status() != WL_CONNECTED) {
    reconnectToWiFi();
    reconnectMQTT(client);
    return;

  } else if (!client.connected()) {
    reconnectMQTT(client);
    return;
  }
  */
  
  client.loop();

  // TEMPERATURE AND HUMIDITY

  //ReadTemperature();

  if (!isPouring) {
    
    // Reset del ciclo quando nessuna scheda è inserita nel lettore
    if (!mfrc522.PICC_IsNewCardPresent()) {
      return;
    }

    if (!mfrc522.PICC_ReadCardSerial()) {
      return;
    }

    // Visualizza l'UID sulla porta seriale di Arduino IDE
    MFRC522::PICC_Type PICC_Type = mfrc522.PICC_GetType(mfrc522.uid.sak);
    /*
    if (PICC_Type != MFRC522::PICC_TYPE_MIFARE_UL) {
      Serial.println("Questo tipo di tag non è supportato!");
      mfrc522.PICC_HaltA();
      return;
    }
    */

    // Legge i blocchi del tag
    char tokenID[] = {'e','e','e','e'};
    for (byte block = 0; block < 5; block++) { // Legge solo i primi 4 blocchi
      byte buffer[18];
      byte size = sizeof(buffer);
      MFRC522::StatusCode status = mfrc522.MIFARE_Read(block, buffer, &size);

      if (status == MFRC522::STATUS_OK) {
        String data = "";
        for (byte i = 0; i < 18; i++) {
          // Costruisce una stringa con i caratteri leggibili
          if (isPrintable(buffer[i])) {
            data += (char)buffer[i];
          }
        }

        int index = data.indexOf("en");
        if (index >= 0 && index + 2 < data.length()) {

          for (int i = index+2 ; i< index+2+4; ++i){
            char potentialDigit = data.charAt(i); 
            tokenID[i-(index+2)] = potentialDigit;

            if (isDigit(potentialDigit)) { 
              tokenID[i-(index+2)] = potentialDigit;
            }
          }

        }
      }
    }
  
    bool existsUID = true;  // = CompareUID(mfrc522.uid.uidByte, mfrc522.uid.size);
    if (existsUID) {
      digitalWrite(LED_PIN, HIGH);
      digitalWrite(VALVE_PIN, HIGH);
      Serial.println("VALVE ACTIVATED");

      isPouring = true;
    }

    int result = validateToken(httpsclient, 1);
    Serial.println(result);

    mfrc522.PICC_HaltA(); // Ferma la comunicazione con la carta

    // Stampa solo la cifra trovata, se esiste
    for(int i = 0; i<4; i++){
      Serial.print(tokenID[i]);
      Serial.print(" - ");
    }
    Serial.println();

  }

  if (isPouring) {
    PouringRoutine();
  }

  if (pouringEnded) {
    Serial.println("VALVE CLOSED");
    digitalWrite(LED_PIN, LOW);
    digitalWrite(VALVE_PIN, LOW);
    isPouring = false;
  }

}


void ReadTemperature(){

  unsigned long currentTime = millis();
  if (currentTime - lastReadTime >= interval) {
    lastReadTime = currentTime;
    int chk = DHT11.read(DHT11_PIN);
    Serial.print("Humidity (%): ");
    Serial.println((float)DHT11.humidity, 2);

    Serial.print("Temperature  (C): ");
    Serial.println((float)DHT11.temperature, 2);

    publishValues(client, TOPIC_LEVEL, String(DHT11.temperature));
    // We should send the temperature to the cloud?
  }
}


bool ReadDataBlock(byte block, byte* buffer, byte buffersize){
  MFRC522::StatusCode status;
  status = mfrc522.MIFARE_Read(0, buffer, &buffersize);
  if(status != MFRC522::STATUS_OK){
    Serial.print("MIFARE_read() failed! ");
    Serial.println(mfrc522.GetStatusCodeName(status));
    return false;
  }
  return true;
}


void PouringRoutine(){
  if (pouringEnded) {
    pulseCount = 0;
    flowRate = 0;
    flowMilliLitres = 0;
    totalMilliLitres = 0;
    oldTime = 0;
    pouringEnded = false;
  } 
  if ((millis() - oldTime) > 1000) {
    detachInterrupt(digitalPinToInterrupt(FLUX_PIN));

    flowRate = ((1000.0 / (millis() - oldTime)) * pulseCount) / calibrationFactor;
    oldTime = millis();

    float flowMilliLitresPerSecond = flowRate * 1000 / 60;
    totalMilliLitres += flowMilliLitresPerSecond;

    Serial.print("flow rate: ");
    Serial.print(flowMilliLitresPerSecond);
    Serial.print("mL/sec, ");
    Serial.print(totalMilliLitres);
    Serial.println("mL");

    pulseCount = 0;

    attachInterrupt(digitalPinToInterrupt(FLUX_PIN), PulseCounter, FALLING);
  }
  if (totalMilliLitres > 100) {
    pouringEnded = true;
  }
}

/*

bool CompareUID(byte* buffer, byte buffersize) {
  if (buffersize != 7) {
    Serial.println("Error! UID with differnt size");
    return 0;
  }

  String result = "none";
  for (int j = 0; j < UIDs.size(); j++) {
    bool found = true;
    for (int i = 0; i < buffersize; i++) {
      Serial.print(buffer[i]);
      Serial.print("-");
      Serial.print(UIDs[j].uid[i]);
      Serial.print(":");
      if (buffer[i] != UIDs[j].uid[i]) {
        Serial.println("not equal");
        found = false;
        break;
      }
    }
    if (found) {
      result = UIDs[j].name;
      break;
    }
  }

  if (result == "none") {
    return false;
  } else {
    return true;
  }
}
*/

void PrintBuffer(byte* buffer, byte buffersize) {
  for (int i = 0; i < buffersize; i++) {
    Serial.print(buffer[i]);
    Serial.print(" ");
  }
  Serial.println();
}

void PrintUID(byte* buffer, byte buffersize) {
  for (int i = 0; i < buffersize; i++) {
    Serial.print((char)buffer[i]);
  }
  Serial.println();
}

//FLUX SENSOR
void PulseCounter() {
  pulseCount++;
}

bool isPrintable(byte c) {
  return (c >= 48 && c <= 122); // ASCII stampabili
}

