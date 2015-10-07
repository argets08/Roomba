//bump test
#include "WiFly.h"
#include "Credentials.h"
#include <Roomba.h>
#include <string.h>

Server server(8000);
Roomba roomba(&Serial);

 int ddPin = 5;
    int ledPin = 13;
    char sensorbytes[10];

    #define bumpright (sensorbytes[0] & 0x01)
    #define bumpleft  (sensorbytes[0] & 0x02)

    void setup() {
      pinMode(ddPin,  OUTPUT);   // sets the pins as output
      pinMode(ledPin, OUTPUT);   // sets the pins as output
      Serial.begin(57600);
      digitalWrite(ledPin, HIGH); // say we're alive
     
      // wake up the robot
      digitalWrite(ddPin, HIGH);
      delay(100);
      digitalWrite(ddPin, LOW);
      delay(500);
      digitalWrite(ddPin, HIGH);
      delay(2000);
     
      // set up ROI to receive commands 
      Serial.print(128, BYTE);  // START
      delay(50);
      Serial.print(130, BYTE);  // CONTROL
      delay(50);
      digitalWrite(ledPin, LOW);  // say we've finished setup

      // Flash Serial Power Button to indicate happiness!!
      digitalWrite(ledPin, HIGH);
      Serial.print(139, BYTE);
      Serial.print(25,BYTE);
      Serial.print(0,BYTE);
      Serial.print(128,BYTE);
      delay(500);
      Serial.print(139, BYTE);
      Serial.print(25,BYTE);
      Serial.print(255,BYTE);
      Serial.print(128,BYTE);
      delay(500);
      Serial.print(139, BYTE);
      Serial.print(25,BYTE);
      Serial.print(255,BYTE);
      Serial.print(0,BYTE);
    }

    void loop() {
      digitalWrite(ledPin, HIGH); // say we're starting loop
      updateSensors();
      digitalWrite(ledPin, LOW);  // say we're after updateSensors
      if(bumpleft) {
        spinRight();
        delay(1000);
      }
      else if(bumpright) {
        spinLeft();
        delay(1000);
      }
      goForward();
    }

    void goForward() {
      Serial.print(137, BYTE);   // DRIVE
      Serial.print(0x00,BYTE);   // 0x00c8 == 200
      Serial.print(0xc8,BYTE);
      Serial.print(0x80,BYTE);
      Serial.print(0x00,BYTE);
    }
    void goBackward() {
      Serial.print(137, BYTE);   // DRIVE
      Serial.print(0xff,BYTE);   // 0xff38 == -200
      Serial.print(0x38,BYTE);
      Serial.print(0x80,BYTE);
      Serial.print(0x00,BYTE);
    }
    void spinLeft() {
      Serial.print(137, BYTE);   // DRIVE
      Serial.print(0x00,BYTE);   // 0x00c8 == 200
      Serial.print(0xc8,BYTE);
      Serial.print(0x00,BYTE);
      Serial.print(0x01,BYTE);   // 0x0001 == spin left
    }
    void spinRight() {
      Serial.print(137, BYTE);   // DRIVE
      Serial.print(0x00,BYTE);   // 0x00c8 == 200
      Serial.print(0xc8,BYTE);
      Serial.print(0xff,BYTE);
      Serial.print(0xff,BYTE);   // 0xffff == -1 == spin right
    }
    void updateSensors() {
      Serial.print(142, BYTE);
      Serial.print(1,   BYTE);  // sensor packet 1, 10 bytes
      delay(100); // wait for sensors
      char i = 0;
      while(Serial.available()) {
        int c = Serial.read();
        if( c==-1 ) {
          for( int i=0; i<5; i ++ ) {   // say we had an error via the LED
            digitalWrite(ledPin, HIGH);
            delay(50);
            digitalWrite(ledPin, LOW); 
            delay(50);
          }
        }
        sensorbytes[i++] = c;
      }   
    }

