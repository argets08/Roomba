import controlP5.*;
import processing.net.*;

Client client;        //Connect to iRobot
ControlP5 controlP5;  //GUI

//GUI Elements
Button b;
String[] commands = new String[100];
//iRobot Vars
int itemCounter = 0;
float  theSpeed    = 0;
float  theDistance = 0;
float  theAngle    = 0;
float  theRadius   = 1;
int recording = 0;
//ScrollList l;
void setup() {
  
 size(640,480);
 frameRate(60);
 smooth();
 //comm = new Arraylist();
 //Init Connection to iRobot
 client = new Client(this,"192.168.127.56",8000); 
 
 //Init GUI Elements
 controlP5 = new ControlP5(this);
 // l = controlP5.addScrollList("List",0,255,128,10);
    
 controlP5.addButton("Done",0,30,30,55,19);
 controlP5.addButton("Record",0,30,10,55,19);
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

void draw() {
  
 background(0);
 
 fill(0,100,180);
 noStroke();
 ellipse(width/2,(height/2)+10,40,40);
 
 if(client.available() > 0) {
  
   String b = client.readStringUntil(10);
   
   String msg = new String(b); 
   
   println(msg);
  
 } 

}

void Speed(float speed) {
 
 theSpeed = speed;
  
}

void Radius(float _radius) {
 
 theRadius = _radius;
  
}

void Distance(float distance) {
 
 theDistance = distance;
  
}

void Angle(float angle) {
 
 theAngle = angle; 
  
}

public void controlEvent(ControlEvent theEvent) {
      
}

public void Record(){
if(recording == 0){
    itemCounter = 0;
	recording = 1;
	}
	else recording = 0;
}

public void Done(){
  for(int j = 0; j < itemCounter; j++){
    println(commands[j]);
    client.write(commands[j]);
  }
  recording = 0;
  itemCounter=0;
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
 if(recording == 1){
   String msg = "f"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
   commands[itemCounter] = msg;
   //l.addItem(msg, itemCounter);
   itemCounter++;
 }
 else{
    println(); 
   println("Going Forward at "+theSpeed+" mm/s for "+theDistance+" mm");
   String msg = "f"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
   client.write(msg);
 }
  
}

public void fwdLeftEvent() {
   if(recording == 1){
    String msg = "q"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
   commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 
 println(); 
 println("Going Forward at "+theSpeed+" mm/s for "+theDistance+" mm at "+theAngle+"Degrees");
 
  String msg = "q"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 }
  
}

public void fwdRightEvent() {
  if(recording == 1){
   String msg = "e"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
   commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 println(); 
 println("Going Forward at "+theSpeed+" mm/s for "+theDistance+" mm turning at "+theRadius+"mm");
 
 String msg = "e"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 }
}
   
public void downEvent() {
  if(recording == 1){
 String msg = "d"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
   commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 println(); 
 println("Going Backwards at "+(theSpeed*-1)+"mm/s for "+(theDistance*-1)+" mm");
 
 String msg = "d"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 }
}

public void downLeftEvent() {
  if(recording == 1){
   String msg = "z"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
   commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 println(); 
 println("Going Backwards at "+(theSpeed*-1)+"mm/s for "+(theDistance*-1)+" mm turning at "+theRadius+"mm");
 
 String msg = "z"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 }
}

public void downRightEvent() {
  if(recording == 1){
   String msg = "c"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 println(); 
 println("Going Backwards at "+(theSpeed*-1)+"mm/s for "+(theDistance*-1)+" mm turning at"+theRadius+"mm");
 
 String msg = "c"+"/"+(int)theSpeed+"/"+(int)theRadius+"/"+(int)theDistance+"/"+(int)theAngle*0+"/>";
 
 client.write(msg);
 }
}

public void leftEvent() {
  if(recording == 1){
  String msg = "l"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance*0+"/"+(int)theAngle+"/>";
   commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 println(); 
 println("Turning "+theAngle+" Degrees Left");
 
 String msg = "l"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance*0+"/"+(int)theAngle+"/>";
 
 client.write(msg);
 }
}

public void rightEvent() {
  if(recording == 1){
   String msg = "r"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance*0+"/"+(int)theAngle+"/>";
   commands[itemCounter] = msg;
   itemCounter++;
 }
 else{
 println(); 
 println("Turning "+(theAngle*-1)+" Degrees Right");
 
 String msg = "r"+"/"+(int)theSpeed+"/"+(int)theRadius*0+"/"+(int)theDistance*0+"/"+(int)theAngle+"/>";
 
 client.write(msg);
 
}
}

void keyPressed() {
  
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

