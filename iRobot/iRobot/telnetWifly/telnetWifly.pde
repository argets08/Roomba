//bump test
#include "WiFly.h"
#include "Credentials.h"
#include <Roomba.h>
#include <string.h>

Server server(8000);
Roomba roomba(&Serial);
int rxPin = 0;
int txPin = 1;
int ddPin = 2;
int ledPin = 13;
char sensorbytes[10];
String stream;
#define bumpright (sensorbytes[0] & 0x01)
#define bumpleft  (sensorbytes[0] & 0x02)

void setup() {
  //  pinMode(txPin,  OUTPUT);
  WiFly.begin();

  if (!WiFly.join(ssid, passphrase)) {

    while (1) {
      // Hang on failure.
    }

  }

  Roomba.begin(57600);
  roomba.print("IP: ");
  roomba.println(WiFly.ip());

  pinMode(ddPin,  OUTPUT);   // sets the pins as output
  pinMode(ledPin, OUTPUT);   // sets the pins as output

  digitalWrite(ledPin, HIGH); // say we're alive

  // wake up the robot
  server.begin();

  delay(2000);
  roomba.start();

  delay(2000);
  roomba.fullMode();

  Serial.print(130, BYTE);  // CONTROL
  delay(50);
  digitalWrite(ledPin, LOW);  // say we've finished setup
}

void loop() {
  digitalWrite(ledPin, HIGH); // say we're starting loop
  Client client = server.available();


  if (client) {

    while (client.connected()) {
      if (client.available()) {
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
        //goForward();
        char c = client.read();

        stream.concat(c);

        if(c == '>') {

          stream = stream.substring(0,stream.length()-1);
          moveBot(stream);
          stream = "";

        }
      }
      client.stop();
    }
  }
}

void moveBot(String msg) {

  char sz[30];
  msg.toCharArray(sz,msg.length());

  char* m = sz;
  char* cmds;

  char* commands[5];

  int i = 0;

  while ((cmds = strtok_r(m, "/", &m)) != NULL) {

    commands[i] = cmds;

    i++;
  }

  commandBot(commands[0],commands[1],commands[2],commands[3],commands[4]);

}

void commandBot(char* dir,char* vel,char* rad,char* dis,char* ang) {

  char cmdDir = dir[0];
  int  cmdRad = atoi(rad);
  int  cmdVel = atoi(vel);
  int  cmdDis = atoi(dis);
  int  cmdAng = atoi(ang);

  Serial.println();

  Serial.print("Direction: ");
  Serial.print(cmdDir);
  Serial.println();

  Serial.print("Velocity:  ");
  Serial.print(cmdVel);
  Serial.println();

  Serial.print("Turning Radius:  ");
  Serial.print(cmdRad);
  Serial.println();

  Serial.print("Distance:  ");
  Serial.print(cmdDis);
  Serial.println();

  Serial.print("Angle:     ");
  Serial.print(cmdAng);
  Serial.println();

  Serial.println();

  switch(dir[0]) {

  case 'f':  //Forward
    // boolean tr = true;
    roomba.drive(cmdVel,32768);
    roomba.waitEvent(roomba.EventTypeBump);
    // roomba.waitDistance(cmdDis);
    roomba.drive(0,0);
    delay(500);
    break;

  case 'd':  //Backwards

    roomba.drive(cmdVel*-1,32768);
    roomba.waitDistance(cmdDis*-1);
    roomba.drive(0,0);

    delay(500);
    break;

  case 'l':  //Left

    roomba.drive(cmdVel,1);
    roomba.waitAngle(cmdAng);
    roomba.drive(0,0);

    delay(500);
    break;

  case 'r':  //Right

    roomba.drive(cmdVel,65535);
    roomba.waitAngle(cmdAng*-1);
    roomba.drive(0,0);

    delay(500);
    break;

  case 'q':  //Forward Left

    roomba.drive(cmdVel,cmdRad);
    roomba.waitDistance(cmdDis);
    roomba.drive(0,0);

    delay(500);
    break;

  case 'e':  //Forward Right

    roomba.drive(cmdVel,cmdRad*-1);
    roomba.waitDistance(cmdDis);
    roomba.drive(0,0);

    delay(500);
    break;

  case 'z':  //Backwards Left

    roomba.drive(cmdVel*-1,cmdRad);
    roomba.waitDistance(cmdDis*-1);
    roomba.drive(0,0);

    delay(500);
    break;

  case 'c':  //Backwards Right

    roomba.drive(cmdVel*-1,cmdRad*-1);
    roomba.waitDistance(cmdDis*-1);
    roomba.drive(0,0);

    delay(500);
    break;

  default:
    break;

  } 

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

