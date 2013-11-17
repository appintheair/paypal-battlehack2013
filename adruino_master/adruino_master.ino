#include <Wire.h>
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h> 

int DOLLAR = 0x24;

unsigned char buf[16] = {0};
unsigned char len = 0;

void setup() {
  Wire.begin();
  ble_begin();
  
  Serial.begin(57600);  
}

int numbers = 0;

void loop() {
  while ( ble_available() ) {
   sendValue(ble_read());
  }
  
  while(Serial.available()) {
    sendValue(Serial.read());
  }
  
  numbers = 0;
  
  ble_do_events();
}

void sendValue(int value) {
  if (numbers == 0) {
     Wire.beginTransmission(7);
     Wire.write(DOLLAR);
     Wire.endTransmission();
   }
   sendNumber(value);
   numbers++;
}

void sendNumber(int number) {
  int output;
  switch(numbers) {
    case 0:
      output = 8;
      break;
    case 1:
      output = 9;
      break;
    case 2:
      output = 10;
      break;
  }
  Wire.beginTransmission(output);
  Wire.write(0x30 + number-48);
  Wire.endTransmission();
}
