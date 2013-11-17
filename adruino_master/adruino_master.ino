#include <Wire.h>

int DOLLAR = 0x24;

void setup() {
  Wire.begin();  
}

void loop() {
  Wire.beginTransmission(7);
  Wire.write(DOLLAR);
  Wire.endTransmission();
  
  Wire.beginTransmission(8);
  Wire.write(0x31);
  Wire.endTransmission();
  
  Wire.beginTransmission(9);
  Wire.write(0x32);
  Wire.endTransmission();
  
  Wire.beginTransmission(10);
  Wire.write(0x33);
  Wire.endTransmission();
  
  delay(5000);
}
