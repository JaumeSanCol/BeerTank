#include "SPI.h"
#include "MFRC522.h"
#include <vector>
#include <string.h> 

#define RST_PIN  9 // RES pin
#define SS_PIN  10 // SDA (SS) pin
#define LED_PIN 6

struct UID {
  std::string name;
  byte uid[7];
};

//RFID
MFRC522 mfrc522(SS_PIN, RST_PIN);
std::vector<UID> UIDs;
bool isPouring = false;
bool pouringEnded = true;

//FLUX SENSOR
byte flow_pin = 8;
unsigned int flow_count = 0;
unsigned int prev_count = 0;
unsigned long prev_time = millis();
bool b_wheel_turning = false;
float volume_per_pulse = 2.25; //volume in ml per pulse (sensor YF-S201)
float total_volume = 0.0; 

void setup() {
  Serial.begin(19200);
  
  //RFID
  SPI.begin();
  mfrc522.PCD_Init();
  delay(4);
  mfrc522.PCD_DumpVersionToSerial();
  Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  //TEST POPULATION
  byte sbyte[7] = {4,197,86,97,16,2,137};
  byte bbyte[7] = {4,127,179,222,16,1,137};
  UID small;
  UID big;
  small.name = "smallcup";
  big.name = "bigcup";
  memcpy(small.uid, sbyte, 7);
  memcpy(big.uid, bbyte, 7);
  UIDs.push_back(small);
  UIDs.push_back(big);

  //FLUX SENSOR
  Serial.begin(9600);
  pinMode( flow_pin, INPUT_PULLUP );
  attachInterrupt( flow_pin, FlowCounter, FALLING );
  isPouring = false;
  pouringEnded = true;

}

void loop() {


  if(!isPouring){
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

    PrintUID(mfrc522.uid.uidByte, mfrc522.uid.size);
    bool existsUID = CompareUID(mfrc522.uid.uidByte, mfrc522.uid.size);
    //byte buffer[10];
    //ReadDataBlock(0, buffer, 10);
    if(existsUID){
      digitalWrite(LED_PIN, HIGH);
      //PrintBuffer(buffer, 10);
      isPouring = true;
    }
    mfrc522.PICC_HaltA();
  }

  if(isPouring){
    PouringRoutine();
  }

  if(pouringEnded){
    digitalWrite(LED_PIN, LOW);
    isPouring = false;
  }
}

/*
void ReadDataBlock(int block, byte* buffer, int buffersize){
  byte status = mfrc522.MIFARE_Read(0, buffer, &buffersize);
  if(status != MFRC522::STATUS_OK){
    Serial.print("MIFARE_read() failed!");
    Serial.println(mfrc522.GetStatusCodeName(status));
    return 4;
  }
  Serial.println("Block was read!");
}
*/
void PouringRoutine(){
  if(pouringEnded){
    total_volume = 0;
    flow_count = 0;
    pouringEnded = false;
  }

  if ((millis() - prev_time) > 1000) {
    b_wheel_turning = (flow_count == prev_count) ? false : true;

    // Total volume in ml
    total_volume += flow_count * volume_per_pulse;

    prev_count = flow_count;
    prev_time = millis();

    Serial.print("flow_count: "); //can be removed
    Serial.println(flow_count); //can be removed
    Serial.print("b_wheel_turning: ");  //can be removed
    Serial.println(b_wheel_turning);  //can be removed
    Serial.print("Total Volume (ml): ");
    Serial.println(total_volume);
    Serial.println("");
  }
  if(total_volume > 1450){
    pouringEnded = true;
  }
}

bool CompareUID(byte* buffer, byte buffersize){
  if(buffersize != 7){
    Serial.println("Error! UID with differnt size");
    return 0;
  }

  std::string result= "none";
  for(int j = 0; j<UIDs.size(); j++){
    bool found = true;
    for(int i = 0; i<buffersize; i++){
      Serial.print(buffer[i]);
      Serial.print("-");
      Serial.print(UIDs[j].uid[i]);
      Serial.print(":");
      if(buffer[i] != UIDs[j].uid[i]){
        Serial.println("not equal");
        found = false;
        break;
      }  
    }
    if(found){
      result = UIDs[j].name;
      break;
    }
  }

  if(result == "none"){
    return false;
  } else {
    return true;
  }
}

void PrintBuffer(byte* buffer, byte buffersize){
  for(int i = 0; i<buffersize; i++){
    Serial.print(buffer[i]);
  }
  Serial.println();
}

void PrintUID(byte* buffer, byte buffersize){
  for(int i = 0; i<buffersize; i++){
    Serial.print(buffer[i]);
    Serial.print(" ");
  }
  Serial.println();
}

//FLUX SENSOR
void FlowCounter(){
  flow_count++;
}