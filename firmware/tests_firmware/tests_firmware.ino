

int OUT_PIN = 13;

void setup() {
  pinMode(OUT_PIN, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(OUT_PIN, LOW);
  delay(1000);
  digitalWrite(OUT_PIN, HIGH);
  delay(1000);
}
