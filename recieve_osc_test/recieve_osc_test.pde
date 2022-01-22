
import oscP5.*;
import netP5.*;
String value1;
ArrayList<SpotifyParameter> array_values;
import processing.video.*;


// To forskellige OSC objekter, til at sende hver deres besked:
OscP5 oscP5;
NetAddress myRemoteLocation;


Capture cam;

void setup() {
  size(400,400);
  frameRate(25);
  oscP5 = new OscP5(this,4321);
  
  array_values = new ArrayList<SpotifyParameter>();

  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();     
  }
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


/*
Processing flowchart:
- click per partecipare                             DONE
- qrcode appare                                     ? not needed
- processing riceve valori spotify                  confermare elisa/andres
- esecuzione foto                                      TODO
- applicazione ritaglio,                               TODO
                divisione,                             TODO
                style transfer                      DONE
- aggiornamento quadro, attesa per successivo click    TODO

*/

//here I added the style transfer request: before and after that we need to add the missing parts(read above):
void mousePressed(){
  
  // show qr code? maybe not for now
  
  //take photo, ANNA SISTEMA TU COL METODO MIGLIORE
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0);
  save("current_photo.jpg");
  // send stylized photo
  OscMessage myMessage = new OscMessage("/style");
  myMessage.add("0");
  myMessage.add("0");
  myMessage.add("current_photo.jpg");

  /* Send photo and params to style_transfer script */
  oscP5.send(myMessage, myRemoteLocation);
  
  // check returned message to check everything went fine
  
  
}

void oscEvent(OscMessage theOscMessage) {
  // Således ser det ud for modtagelse af kun én OSC besked:
  value1 = theOscMessage.get(0).stringValue();
  println("value1: " + value1);
  SpotifyParameter sp = new SpotifyParameter(value1);

  array_values.add(sp);
  
  print(array_values.size());
  
}
