/*
Processing flowchart:
- click per partecipare                             DONE
- qrcode appare                                     work in progress
- processing riceve valori spotify                  DONE
- esecuzione foto                                   DONE
- applicazione ritaglio,                            DONE
                divisione,                             TODO
                style transfer                      DONE
- aggiornamento quadro, attesa per successivo click    TODO


altri TODO:
  - gestione messaggi osc in arrivo
  - resettare schermata processing quando arriva uno 0 dopo style transfer
*/


import oscP5.*;
import netP5.*;
String message_receiver;
ArrayList<SpotifyParameter> participants_spotify_values;
import processing.video.*;


// instantiate two objects, each one for sending its own message
OscP5 oscP5;
OscP5 oscP5_spotify;
NetAddress myRemoteLocation;
PFont font;

void setup() {
  size(1920,1080,P3D);
  frameRate(25);
  oscP5 = new OscP5(this, 4321);
  oscP5_spotify = new OscP5(this, 4321);
  font =createFont("GOGOIA-Regular.ttf",50);
  participants_spotify_values = new ArrayList<SpotifyParameter>();

  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
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

   if(message_receiver != null){
      background(255);
      textAlign(CENTER);
      textSize(35);
      noStroke();
      fill(44,100,172);
      text("Press ENTER to participate!", width/2, height/2);
    }
}


void mousePressed(){
  if(message_receiver == null){
    OscMessage myMessage = new OscMessage("/spotify");
    oscP5_spotify.send(myMessage, myRemoteLocation);
  }
}

//here I added the style transfer request: before and after that we need to add the missing parts(read above):
void keyPressed(){
  if (key == '\n' ) {
    
    
    
    // ask python to take photo
    OscMessage myMessage = new OscMessage("/photo");
    myMessage.add(participants_spotify_values.size());
    oscP5.send(myMessage, myRemoteLocation);
    
    // for final project is better to wait for message from python server
    // wait until face file is created
    println("I'm");
    try{
      do{
        println("... waiting ...");
        delay(1000);
      } while(! fileExistsCaseSensitive(str(participants_spotify_values.size()) + "_face.jpg"));
    }
    catch (Exception e){
      println("error: " + e);
    }
    println("image found!");
    
    // send stylized photo
    myMessage = new OscMessage("/style");
    myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getAcousticness()); //prendo l'acousticness dell'ultima coppia di valori aggiunti
    myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getValence());  //prendo la valence dell'ultima coppia di valori aggiunti
    myMessage.add(str(participants_spotify_values.size()) + "_face.jpg");

    /* Send photo and params to style_transfer script */
    oscP5.send(myMessage, myRemoteLocation);
  
  // check returned message to check everything went fine
  
  
  //message_receiver = null;
  }
}

void oscEvent(OscMessage theOscMessage) {
  
  //leggo i valori ricevuti
  message_receiver = theOscMessage.get(0).stringValue();
  println("Spotify parameters: " + message_receiver);
  SpotifyParameter sp = new SpotifyParameter(message_receiver);
  participants_spotify_values.add(sp);
 
}
