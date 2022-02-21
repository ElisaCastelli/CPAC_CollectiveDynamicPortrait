import peasy.*;
import ddf.minim.*;

PeasyCam cam;
Minim minim;
AudioPlayer player;

float t;
PImage img;


void setup(){
   size(displayWidth, displayHeight);
   cam=new PeasyCam(this,180);
   cam.setMinimumDistance(50);
   cam.setMaximumDistance(500);
   minim=new Minim(this);
   player=minim.loadFile("dontstop_level_3.wav");
   player.play();
   frameRate(20);
 
}



void draw(){
  background(0);
  
  translate (width/4-100,height/2);
  
  for(int j=0; j<player.bufferSize()-1; j+=2){
  
  strokeWeight(abs(1+player.right.get(j)*100));
  println(abs(1+player.right.get(j)*50));
 
  }

  for (int i=0; i<90; i++){
    strokeCap(ROUND);
    line(x1(t+i),y1(t+i),x2(t+i),y2(t+i));
    stroke(192,192,192);
    strokeCap(ROUND);
    line(x1(t+i)+width/2,y1(t+i),x2(t+i)+width/2,y2(t+i));
    stroke(255,255,255);
    rect(x1(t+i)- width/6,y1(t+i),5,5);
    rect(x1(t+i)+1100,y1(t+i),5,5);
  }
  
  t+=0.03;
  
}

float x1 (float t){
  return sin(t/10)*500 - tan(t/20)*200;
}

float y1 (float t){
  return tan(-t/20)*300+sin(t/20)*200;
}

float x2 (float t){
  return sin(t/10)*500+ tan(t/10)*200;
}

float y2 (float t){
  return -cos(t/20)*300+ cos(t/12)*20;
}
