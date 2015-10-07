import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 
import processing.net.*; 

import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class iControl extends PApplet {




Client client;        //Connect to iRobot
ControlP5 controlP5;  //GUI

//GUI Elements
Button b;

//iRobot Vars
float  theSpeed    = 0;
float  theDistance = 0;
float  theAngle    = 0;
float  theRadius   = 1;

public void setup() {
 
 size(640,480);
 frameRate(60);
 smooth();
 
 //Init Connection to iRobot
 client = new Client(this,"192.168.127.63",8000); 
 
 //Init GUI Elements
 controlP5 = new ControlP5(this);
 
 controlP5.addButton("Forwards",0,(width/2)-(55/2),((height/2)-50),55,19);
 controlP5.addButton("Backwards",0,(width/2)-(55/2),((height/2)+50),55,19);
 
 controlP5.addButton("Turn_Left",0,((width/2)-100)-(55/2),(height/2),55,19);
 controlP5.addButton("Turn_Right",0,((width/2)+100)-(55/2),(height/2),55,19);
 
 controlP5.addButton("Forwards_Right",0,((width/2)+75)-(75/2),(height/2)-40,75,19);
 controlP5.addButton("Forwards_Left",0,((width/2)-75)-(75/2),(height/2)-40,75,19);
 
 controlP5.addButton("Down_Right",0,((width/2)-75)-(75/2),(height/2)+40,75,19);
 controlP5.addButton("Down_Left",0,((width/2)+75)-(75/2),(height/2)+40,75,19);
 
 controlP5.addSlider("Speed",0,500,theSpeed,470,30,120,20);
 controlP5.addSlider("Radius",0,2000,theRadius,470,65,120,20);
 controlP5.addSlider("Distance",0,5000,theDistance,470,100,120,20);
 controlP5.addSlider("Angle",0,360,theAngle,470,135,120,20);
 
 Slider sTick = (Slider)controlP5.controller("Speed");
 Slider rTick = (Slider)controlP5.controller("Radius");
 Slider dTick = (Slider)controlP5.controller("Distance");
 Slider aTick = (Slider)controlP5.controller("Angle");
 
 sTick.setNumberOfTickMarks(11);
 rTick.setNumberOfTickMarks(11);
 dTick.setNumberOfTickMarks(11);
 aTick.setNumberOfTickMarks(25);
 
}

public void draw() {
  
 background(0);
 
 fill(0,100,180);
 noStroke();
 ellipse(width/2,(height/2)+10,40,40);
 
 if(client.available() > 0) {
  
   String b = client.readString();
   
   String msg = new String(b); 
   
   println(msg);
  
 } 

}

public void Speed(float speed) {
 
 theSpeed = speed;
  
}

public void Radius(float _radius) {
 
 theRadius = _radius;
  
}

public void Distance(float distance) {
 
 theDistance = distance;
  
}

public void Angle(float angle) {
 
 theAngle = angle; 
  
}

public void controlEvent(ControlEvent theEvent) {
 
}

public void Forwards(int theValue) {
  
 fwdEvent(); 
}

public void Forwards_Right(int theValue) {
  
 fwdRightEvent(); 
}

public void Forwards_Left(int theValue) {
  
 fwdLeftEvent(); 
}


public void  Backwards(int theValue) {
  
 downEvent(); 
}

public void  Down_Right(int theValue) {
  
 downRightEvent(); 
}

public void  Down_Left(int theValue) {
  
 downLeftEvent(); 
}

public void  Turn_Right(int theValue) {
  
 rightEvent(); 
}

public void  Turn_Left(int theValue) {
  
 leftEvent(); 
}

public void fwdEvent() {
 
 println(); 
 println("Going Forward at "+theSpeed+" mm/s for "+theDistance+" mm");
 
 String msg = "f"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
  
}

public void fwdLeftEvent() {
 
 println(); 
 println("Going Forward at "+theSpeed+" mm/s for "+theDistance+" mm at "+theAngle+"Degrees");
 
  String msg = "q"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
  
}

public void fwdRightEvent() {
 
 println(); 
 println("Going Forward at "+theSpeed+" mm/s for "+theDistance+" mm turning at "+theRadius+"mm");
 
 String msg = "e"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
  
}
   
public void downEvent() {
 
 println(); 
 println("Going Backwards at "+(theSpeed*-1)+"mm/s for "+(theDistance*-1)+" mm");
 
 String msg = "d"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 
}

public void downLeftEvent() {
 
 println(); 
 println("Going Backwards at "+(theSpeed*-1)+"mm/s for "+(theDistance*-1)+" mm turning at "+theRadius+"mm");
 
 String msg = "z"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 
}

public void downRightEvent() {
 
 println(); 
 println("Going Backwards at "+(theSpeed*-1)+"mm/s for "+(theDistance*-1)+" mm turning at"+theRadius+"mm");
 
 String msg = "c"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 
}

public void leftEvent() {
 
 println(); 
 println("Turning "+theAngle+" Degrees Left");
 
 String msg = "l"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance*0+"/"+(int)theAngle+"/>";
 
 client.write(msg);
  
}

public void rightEvent() {
 
 println(); 
 println("Turning "+(theAngle*-1)+" Degrees Right");
 
 String msg = "r"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance*0+"/"+(int)theAngle+"/>";
 
 client.write(msg);
 
}

public void keyPressed() {
  
   switch(key) {
     
    case 'w':
    case 'W':
      
      fwdEvent();
   
      break;
     
    case 's':
    case 'S':
    
      downEvent();
   
      break;
     
    case 'a':
    case 'A':
    
      leftEvent();
   
      break;
     
    case 'd':
    case 'D':
    
      rightEvent();
   
      break;
     
    case 'q':
    case 'Q':
    
      fwdLeftEvent();
   
      break;
     
    case 'e':
    case 'E':
    
      fwdRightEvent();
   
      break;
    
    case 'z':
    case 'Z':
    
      downLeftEvent();
   
      break;
     
    case 'c':
    case 'C':
    
      downRightEvent();
   
      break;    
     
     
   }
             
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "iControl" });
  }
}
