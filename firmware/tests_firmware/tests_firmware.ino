#include "SPI.h"
#include "MFRC522.h"

#define RST_PIN  9 // RES pin
#define SS_PIN  10 // SDA (SS) pin
#define LED_PIN 7 

MFRC522 mfrc522(SS_PIN, RST_PIN);

byte smallcup[7] = {4,197,86,97,16,2,136}; 
byte bigcup[7] = {4,127,179,222,16,1,137};

void setup() {
  Serial.begin(9600);
  SPI.begin();
  mfrc522.PCD_Init();
  delay(4);
  mfrc522.PCD_DumpVersionToSerial();
  Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
}

void loop() {
  // reset del ciclo quando nessuna scheda è inserita nel lettore
  if ( ! mfrc522.PICC_IsNewCardPresent()) {
     return;
  }

  if ( ! mfrc522.PICC_ReadCardSerial()) {
     return;
  }

  // visualizza l'UID sulla porta seriale di Arduino IDE
  //mfrc522.PICC_DumpToSerial(&(mfrc522.uid));
  MFRC522::PICC_Type PICC_Type = mfrc522.PICC_GetType(mfrc522.uid.sak);

  printUID(mfrc522.uid.uidByte, mfrc522.uid.size);
  bool result = compareUID(mfrc522.uid.uidByte, mfrc522.uid.size);
  Serial.println(result);
  if (result == 1){
    digitalWrite(LED_PIN, HIGH);
  } else {
    digitalWrite(LED_PIN, LOW);
  }
  mfrc522.PICC_HaltA();

}

bool compareUID(byte* buffer, byte buffersize){
  if(buffersize != 7){
    Serial.println("Error! UID with differnt size");
    return;
  }

  bool exists1 = true;
  for(int i = 0; i<buffersize; i++){
    if(buffer[i] != smallcup[i]){
      exists1 = false;
      break;
    }
  }
  
  bool exists2 = true;
  for(int i = 0; i<buffersize; i++){
    if(buffer[i] != bigcup[i]){
      exists2 = false;
      break;
    }
  }

  return exists1 || exists2;

}

void printUID(byte* buffer, byte buffersize){
  for(int i = 0; i<buffersize; i++){
    Serial.print(i);
    Serial.print(" : ");
    Serial.println(buffer[i]);
  }
}