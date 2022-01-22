
import oscP5.*;
import netP5.*;
String value1;
ArrayList<SpotifyParameter> array_values;
import processing.video.*;


// To forskellige OSC objekter, til at sende hver deres besked:
OscP5 oscP5;
OscP5 oscP5_spotify;
NetAddress myRemoteLocation;
PFont font;
Capture cam;


void setup() {
  size(600,400);
  frameRate(25);
  oscP5 = new OscP5(this, 4321);
  oscP5_spotify = new OscP5(this, 4321);
  font =createFont("GOGOIA-Regular.ttf",50);
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
  
  //ho provato a copiare quello di Anna con l'animazione ma mi dava errore
  background(255);
  textAlign(CENTER);
  textFont(font);
  noStroke();
  fill(44,100,172);
  textSize(50);
  text("COLLECTIVE DYNAMIC PORTRAIT", width/2, height/7);
  textSize(30);
  text("Click here to start!", width/2, height/2);

   if(value1 != null){
      textAlign(CENTER);
      textSize(35);
      noStroke();
      fill(44,100,172);
      text("Press ENTER to take your photo!", width/2, height/2);
    }
}


/*
Processing flowchart:
- click per partecipare                             DONE
- qrcode appare                                     ? not needed
- processing riceve valori spotify                  DONE
- esecuzione foto                                      TODO
- applicazione ritaglio,                               TODO
                divisione,                             TODO
                style transfer                      DONE
- aggiornamento quadro, attesa per successivo click    TODO

*/

void mousePressed(){
  OscMessage myMessage = new OscMessage("/spotify");
  oscP5_spotify.send(myMessage, myRemoteLocation);
}

//here I added the style transfer request: before and after that we need to add the missing parts(read above):
void keyPressed(){
  if (key == '\n' ) {

    //take photo, ANNA SISTEMA TU COL METODO MIGLIORE
    if (cam.available() == true) {
      cam.read();
    }
    image(cam, 0, 0);
    save("current_photo.jpg");
    // send stylized photo
    OscMessage myMessage = new OscMessage("/style");
    myMessage.add((array_values.get(array_values.size()-1)).getAcousticness()); //prendo l'acousticness dell'ultima coppia di valori aggiunti
    myMessage.add((array_values.get(array_values.size()-1)).getValence());  //prendo la valence dell'ultima coppia di valori aggiunti
    myMessage.add("current_photo.jpg");

  /* Send photo and params to style_transfer script */
  oscP5.send(myMessage, myRemoteLocation);
  
  // check returned message to check everything went fine
  
  }
}

void oscEvent(OscMessage theOscMessage) {
  
  //leggo i valori ricevuti
  value1 = theOscMessage.get(0).stringValue();
  println("Spotify parameters: " + value1);
  SpotifyParameter sp = new SpotifyParameter(value1);
  array_values.add(sp);
 
}
