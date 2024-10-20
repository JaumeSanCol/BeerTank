#include "SPI.h"
#include "MFRC522.h"

#define RST_PIN  9 // RES pin
#define SS_PIN  10 // SDA (SS) pin

MFRC522 mfrc522(SS_PIN, RST_PIN);

void setup() {
  Serial.begin(9600);
  SPI.begin();
  mfrc522.PCD_Init();
  delay(4);
  mfrc522.PCD_DumpVersionToSerial();
  Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));
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
  printHex(mfrc522.uid.uidByte, mfrc522.uid.size);
  mfrc522.PICC_HaltA();
}

void printHex (byte* buffer, byte buffersize){
  for (byte i = 0; i < buffersize; i++) {
  //Serial.println(buffer[i]);
  Serial.print(buffer[i] < 0x10 ? " 0" : " ");
  Serial.print(buffer[i], HEX);
  }
}