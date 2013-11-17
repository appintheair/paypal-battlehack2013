#include <Rainbowduino.h>
#include <Wire.h>

void setup() {
  Rb.init();  
  Rb.blankDisplay();
  
  Wire.begin(10);
  delay(2000);
  Wire.onReceive(digitReceive);
}

void loop() {
  
}

void digitReceive(int count) {
  int number = Wire.read();
  
  Rb.blankDisplay();
  delay(200);
  Rb.drawChar(number, 0, 0, 0x00FF00);
}
