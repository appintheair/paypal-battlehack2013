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
  int convertedNumber = value-48;
  if (numbers == 0 && convertedNumber >= 0 && convertedNumber <= 9) {
     sendNumber(DOLLAR);
     numbers++;
  }
  sendNumber(convertedNumber + 0x30);
  numbers++;
}

int digits[] = { -1, -1, -1, -1 };

void sendNumber(int number) {
  int oldNumber = digits[numbers];
  if (oldNumber >= 0) {
    if (oldNumber == number)
      return;
    animate(oldNumber, true);
  }
  animate(number, false);
  digits[numbers] = number;
}

void animate(int n, bool r) {
  for (int i=r?1:-8; r?i<8:i<=0; i++) {
   show(n, i+8); 
   delay(30);
  }
}

void show(int n, int p) {
  int output = numbers + 7;
  Wire.beginTransmission(output);
  byte data[4];
  data[0] = n >> 4;
  data[1] = n & 0xf;
  data[2] = p >> 4;
  data[3] = p & 0xf;
  Wire.write(data, 4);
  Wire.endTransmission();
}
