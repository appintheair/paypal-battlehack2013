#include <Wire.h>
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h> 
#include <Tone.h>

int DOLLAR = 0x24;
int numbers = 0;

void setup() {
  Wire.begin();
  ble_begin();
  
  Serial.begin(9600);  
  
  setupTune();
}


void loop() {
  if (ble_available()) {
    playTune(); 
  }
  while ( ble_available() ) {
   sendValue(ble_read());
  }
  
  while(Serial.available()) {
    int x = Serial.read();
    if (x > 2) {
      sendValue(x);
    } else if (x == 1) {
      Serial.write("E9:B4:F3:9E:23:B2"); 
    } else if (x == 2) {
      Serial.write("3731A944-09AA-E79E-2E54-0A27DEB925F8");
    }
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


// music staff

Tone tone1;

#define OCTAVE_OFFSET 0
#define isdigit(n) (n >= '0' && n <= '9')

int notes[] = { 0,
NOTE_C4, NOTE_CS4, NOTE_D4, NOTE_DS4, NOTE_E4, NOTE_F4, NOTE_FS4, NOTE_G4, NOTE_GS4, NOTE_A4, NOTE_AS4, NOTE_B4,
NOTE_C5, NOTE_CS5, NOTE_D5, NOTE_DS5, NOTE_E5, NOTE_F5, NOTE_FS5, NOTE_G5, NOTE_GS5, NOTE_A5, NOTE_AS5, NOTE_B5,
NOTE_C6, NOTE_CS6, NOTE_D6, NOTE_DS6, NOTE_E6, NOTE_F6, NOTE_FS6, NOTE_G6, NOTE_GS6, NOTE_A6, NOTE_AS6, NOTE_B6,
NOTE_C7, NOTE_CS7, NOTE_D7, NOTE_DS7, NOTE_E7, NOTE_F7, NOTE_FS7, NOTE_G7, NOTE_GS7, NOTE_A7, NOTE_AS7, NOTE_B7
};

char *song = "StarWars:d=4,o=5,b=45:32p,32f#,32f#,32f#,8b.,8f#.6,32e6,32d#6,32c#6,8b.6,16f#.6,32e6,32d#6,32c#6,8b.6,16f#.6,32e6,32d#6,32e6,8c#.6,32f#,32f#,32f#,8b.,8f#.6,32e6,32d#6,32c#6,8b.6,16f#.6,32e6,32d#6,32c#6,8b.6,16f#.6,32e6,32d#6,32e6,8c#6";

void setupTune() {
  tone1.begin(8);
}

void play_rtttl(char *p)
{
  // Absolutely no error checking in here

  byte default_dur = 4;
  byte default_oct = 6;
  int bpm = 63;
  int num;
  long wholenote;
  long duration;
  byte note;
  byte scale;

  // format: d=N,o=N,b=NNN:
  // find the start (skip name, etc)

  while(*p != ':') p++;    // ignore name
  p++;                     // skip ':'

  // get default duration
  if(*p == 'd')
  {
    p++; p++;              // skip "d="
    num = 0;
    while(isdigit(*p))
    {
      num = (num * 10) + (*p++ - '0');
    }
    if(num > 0) default_dur = num;
    p++;                   // skip comma
  }

  Serial.print("ddur: "); Serial.println(default_dur, 10);

  // get default octave
  if(*p == 'o')
  {
    p++; p++;              // skip "o="
    num = *p++ - '0';
    if(num >= 3 && num <=7) default_oct = num;
    p++;                   // skip comma
  }

  Serial.print("doct: "); Serial.println(default_oct, 10);

  // get BPM
  if(*p == 'b')
  {
    p++; p++;              // skip "b="
    num = 0;
    while(isdigit(*p))
    {
      num = (num * 10) + (*p++ - '0');
    }
    bpm = num;
    p++;                   // skip colon
  }

  Serial.print("bpm: "); Serial.println(bpm, 10);

  // BPM usually expresses the number of quarter notes per minute
  wholenote = (60 * 1000L / bpm) * 4;  // this is the time for whole note (in milliseconds)

  Serial.print("wn: "); Serial.println(wholenote, 10);


  // now begin note loop
  while(*p)
  {
    // first, get note duration, if available
    num = 0;
    while(isdigit(*p))
    {
      num = (num * 10) + (*p++ - '0');
    }
    
    if(num) duration = wholenote / num;
    else duration = wholenote / default_dur;  // we will need to check if we are a dotted note after

    // now get the note
    note = 0;

    switch(*p)
    {
      case 'c':
        note = 1;
        break;
      case 'd':
        note = 3;
        break;
      case 'e':
        note = 5;
        break;
      case 'f':
        note = 6;
        break;
      case 'g':
        note = 8;
        break;
      case 'a':
        note = 10;
        break;
      case 'b':
        note = 12;
        break;
      case 'p':
      default:
        note = 0;
    }
    p++;

    // now, get optional '#' sharp
    if(*p == '#')
    {
      note++;
      p++;
    }

    // now, get optional '.' dotted note
    if(*p == '.')
    {
      duration += duration/2;
      p++;
    }
  
    // now, get scale
    if(isdigit(*p))
    {
      scale = *p - '0';
      p++;
    }
    else
    {
      scale = default_oct;
    }

    scale += OCTAVE_OFFSET;

    if(*p == ',')
      p++;       // skip comma for next note (or we may be at the end)

    // now play the note

    if(note)
    {
      Serial.print("Playing: ");
      Serial.print(scale, 10); Serial.print(' ');
      Serial.print(note, 10); Serial.print(" (");
      Serial.print(notes[(scale - 4) * 12 + note], 10);
      Serial.print(") ");
      Serial.println(duration, 10);
      tone1.play(notes[(scale - 4) * 12 + note]);
      delay(duration);
      tone1.stop();
    }
    else
    {
      Serial.print("Pausing: ");
      Serial.println(duration, 10);
      delay(duration);
    }
  }
}

void playTune() {
  play_rtttl(song);
}
