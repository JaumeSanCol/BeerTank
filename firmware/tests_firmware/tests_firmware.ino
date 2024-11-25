#include "SPI.h"
#include "MFRC522.h"
#include "Vector.h"
#include <string.h>

#define RST_PIN 9  // RES pin
#define SS_PIN 10  // SDA (SS) pin
#define LED_PIN 6
#define VALVE_PIN 4
#define FLUX_PIN 3

struct UID {
  String name;
  byte uid[7];
};

//RFID
MFRC522 mfrc522(SS_PIN, RST_PIN);
Vector<UID> UIDs;
bool isPouring = false;
bool pouringEnded = true;

//FLUX SENSOR
volatile int pulseCount;
float flowRate;
unsigned long flowMilliLitres;
unsigned long totalMilliLitres;
unsigned long oldTime;
float calibrationFactor = 4.5;

/*
unsigned int flow_count = 0;
unsigned int prev_count = 0;
unsigned long prev_time = millis();
bool b_wheel_turning = false;
float volume_per_pulse = 2.25;  //volume in ml per pulse (sensor YF-S201)
float total_volume = 0.0;
*/

void setup() {

  pinMode(VALVE_PIN, OUTPUT);


  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(FLUX_PIN, INPUT_PULLUP);

  //RFID
  SPI.begin();
  mfrc522.PCD_Init();
  delay(4);
  mfrc522.PCD_DumpVersionToSerial();
  Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));

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
}

void loop() {


  if (!isPouring) {
    // reset del ciclo quando nessuna scheda è inserita nel lettore
    if (!mfrc522.PICC_IsNewCardPresent()) {
      return;
    }

    if (!mfrc522.PICC_ReadCardSerial()) {
      return;
    }

    // visualizza l'UID sulla porta seriale di Arduino IDE
    //mfrc522.PICC_DumpToSerial(&(mfrc522.uid));
    MFRC522::PICC_Type PICC_Type = mfrc522.PICC_GetType(mfrc522.uid.sak);

    PrintUID(mfrc522.uid.uidByte, mfrc522.uid.size);
    bool existsUID = true;  //= CompareUID(mfrc522.uid.uidByte, mfrc522.uid.size);
    byte buffer[18];

    if (existsUID) {
      digitalWrite(LED_PIN, HIGH);
      digitalWrite(VALVE_PIN, HIGH);
      Serial.println("VALVE ACTIVATED");
      PrintBuffer(buffer, sizeof(buffer));
      isPouring = true;
    }

    for(int i = 0; i<16*4; i++){
      bool res = ReadDataBlock(i, buffer, sizeof(buffer));
      if(res){
        Serial.print("data: ");
        PrintBuffer(buffer, sizeof(buffer));
      }
    }

    mfrc522.PICC_HaltA();
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
void PouringRoutine() {
  if (pouringEnded) {
    total_volume = 0;
    flow_count = 0;
    prev_count = 0;  // Inizializza prev_count
    pouringEnded = false;
  }

  if ((millis() - prev_time) > 1000) {
    // Verifica se c'è stato un cambiamento nel conteggio degli impulsi
    b_wheel_turning = (flow_count == prev_count) ? false : true;

    // Calcola solo il volume aggiuntivo dagli impulsi nuovi
    total_volume += (flow_count - prev_count) * volume_per_pulse;

    prev_count = flow_count;
    prev_time = millis();

    Serial.print("flow_count: ");
    Serial.println(flow_count);
    Serial.print("b_wheel_turning: ");
    Serial.println(b_wheel_turning);
    Serial.print("Total Volume (ml): ");
    Serial.println(total_volume);
    Serial.println("");
  }
  if (total_volume > 200) {
    pouringEnded = true;
  }
}


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
