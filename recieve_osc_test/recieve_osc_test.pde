
import oscP5.*;
import netP5.*;
String value1;
ArrayList<SpotifyParameter> spotifyParameters;


// To forskellige OSC objekter, til at sende hver deres besked:
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  frameRate(25);
  oscP5 = new OscP5(this,4321);

  myRemoteLocation = new NetAddress("127.0.0.1", 6543);
}

void draw() {
  background(0);
   if(value1 != null){
    textAlign(CENTER);
    fill(200);
    stroke(255);
    textSize(15);
    text("Random værdier fra Python:", width/2, height/2+100);
    textSize(20);
    text(float(value1)*10, width/2, height/2+120);
    noStroke();
    fill(255,0,0);
    ellipse(200,120,float(value1)*width,height*float(value1));
    
    }
}

void mousePressed(){
  OscMessage myMessage = new OscMessage("/miklo");

  /* Hvad der sendes, og hvor til */
  oscP5.send(myMessage, myRemoteLocation);
}

void oscEvent(OscMessage theOscMessage) {
  // Således ser det ud for modtagelse af kun én OSC besked:
  value1 = theOscMessage.get(0).stringValue();
  SpotifyParameter sp = new SpotifyParameter(value1);
  spotifyParameters.add(sp);
  print(value1);
}
