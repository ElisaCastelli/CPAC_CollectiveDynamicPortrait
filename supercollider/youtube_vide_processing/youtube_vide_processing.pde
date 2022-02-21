import netP5.*;
import oscP5.*;
OscP5 osc;
NetAddress sc;
float amp1=0.0;
 
void setup(){
  size(500,500);
  osc=new OscP5(this,12321);
  sc=new NetAddress("127.0.0.1",57120);
  osc.plug(this,"newamp","/amp1");
  
}
void draw(){
  background(0);
  OscMessage msg = new OscMessage("/getamp");
  osc.send(msg,sc);
  println(msg);
  stroke(153,255,0);
  strokeWeight(10);
  line(120,height/2.0, 30+amp1, height/2.0);
}

void newamp(float rms){
  
  amp1=map(rms,0.0,1.0,0.0,350.0);
  
}
