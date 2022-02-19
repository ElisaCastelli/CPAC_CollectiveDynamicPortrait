


void setup(){
  size(displayWidth,displayHeight);
  background(0);
  frameRate(20);
} 

void draw(){
 translate(width/2,height/2);
 float mag=400;
 float s=5;

 noStroke();
 
 for(int i=0; i<100; i++){
   float w=map(sin(radians(frameCount)),-1,1,-100,100);
    float wave1=map(tan(radians(frameCount*0.8 + i + w)),-1,1,-mag,mag);
     float wave2=map(tan(radians(frameCount +i)),-1,1,-mag,mag);
      float c=map(sin(radians(frameCount*5 +i )),-1,1,0,255);
      int m=millis();
      fill(m%c);
      rect(wave1,wave2,s,s);
      stroke(0,128,128);
 }
 
}
