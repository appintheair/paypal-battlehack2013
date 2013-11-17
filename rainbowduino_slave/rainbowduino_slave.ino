#include <Rainbowduino.h>
#include <Wire.h>

void setup() {
  Rb.init();  
  Rb.blankDisplay();
  
  Serial.begin(9600);
  
  Wire.begin(7);
  delay(2000);
  Wire.onReceive(digitReceive);
  
}

void loop() {
  while(Serial.available()) {
    int n = Serial.read();
     displayNumber(n-48);  
  }
}

int currentNumber = -1;

void digitReceive(int count) {
  int number = 0;
  for (int i=count; i>0; i--) {
    int val = Wire.read();
    number += val << 4*(i-1);
  }
  displayNumber(number);
}

void displayNumber(int number) {
  if (number == currentNumber)
    return;
  
  Rb.blankDisplay();
  int val = number & 0x00FF;
  int x = (val & 0xF0) >> 4;
  int y = (val & 0x0F) - 8;
  Rb.drawChar(number >> 8, x, y, 0x00FF00);
  
//  if (currentNumber >= 0) {
//    animateNumber(currentNumber, true);
//  }
//  currentNumber = number;
//  animateNumber(number, false);
//  delay(500);
}

void animateNumber(int number, bool upDown) {
//  for (int i=upDown?1:-7; upDown?i<8:i<=0; i++) {
//    Rb.blankDisplay();
//    Rb.drawChar(number, 0, i, 0x00FF00);
//    delay(50);
//  }
}
