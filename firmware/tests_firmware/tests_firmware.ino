#include "SPI.h"
#include "MFRC522.h"
#include <vector>
#include <string.h> 

#define RST_PIN  9 // RES pin
#define SS_PIN  10 // SDA (SS) pin
#define LED_PIN 6

//RFID
MFRC522 mfrc522(SS_PIN, RST_PIN);

byte smallcup[7] = {4,197,86,97,16,2,136}; 
byte bigcup[7] = {4,127,179,222,16,1,137};


struct UID {
  std::string name;
  byte uid[7];
};

std::vector<UID> UIDs;

//FLOW SENSOR
byte flow_pin = 8;
unsigned int flow_count = 0;
unsigned int prev_count = 0;
unsigned long prev_time = millis();
bool b_wheel_turning = false;


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
  byte sbyte[7] = {4,197,86,97,16,2,136};
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
  attachInterrupt( flow_pin, flowCounter, FALLING );
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

  //FLUX
  if( ( millis() - prev_time ) > 1000 ){
    b_wheel_turning = ( flow_count == prev_count ) ? false : true;
    
    prev_count = flow_count;
    prev_time = millis();
    
    Serial.print( "flow_count: " );
    Serial.println( flow_count );
    Serial.print( "b_wheel_turning: " );
    Serial.println( b_wheel_turning );
    Serial.println( "" );    
  }
}

bool compareUID(byte* buffer, byte buffersize){
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

void printUID(byte* buffer, byte buffersize){
  for(int i = 0; i<buffersize; i++){
    Serial.print(i);
    Serial.print(" : ");
    Serial.println(buffer[i]);
  }
}

void flowCounter(){
  flow_count++;
}