


float t;

void setup(){
  background(0);
  size(displayWidth, displayHeight);
}

void draw(){
  background(0);
  stroke(255);
  strokeWeight(0.5);
 
  translate (width/4-100,height/2);
  for (int i=0; i<100; i++){
  line(x1(t+i),y1(t+i),x2(t+i),y2(t+i));
   stroke(204,153,255);
   line(x1(t+i)+1100,y1(t+i),x2(t+i)+1100,y2(t+i));
   stroke(0,128,128);
   rect(x1(t+i),y1(t+i),5,5);
  rect(x1(t+i)+1100,y1(t+i),5,5);
  }
  t+=0.05;
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
