/*
Processing flowchart:
- click per partecipare                             DONE
- qrcode appare                                     in progress
- processing riceve valori spotify                  in progress
- esecuzione foto                                   DONE
- applicazione ritaglio,                            DONE
                divisione,                          DONE
                style transfer                      DONE
- aggiornamento quadro, attesa per successivo click DONE

quadro sempre presente, all'inizio cornice vuota

STATI:
- MAIN - scan the qr code and click to join (confronta ultimi valori di spotify con quello appena arrivato, se non sono arrivati nuovi stampa avviso)
- PHOTO - acquisizione foto
- PROCESSING - run style transfer

*/





import oscP5.*;
import netP5.*;
import processing.video.*;

/* image plot and division */

// number of rows/columns of division
final int N_IMAGE_X=2;
final int N_IMAGE_Y=2;
final int total_parts=N_IMAGE_X * N_IMAGE_Y;
// for now number of images coincides with total parts

PImage[] small_images;
PVector[] pos_image;
PImage[] img;


/* spotify */

String message_receiver="";
ArrayList<SpotifyParameter> participants_spotify_values;

/*QR image*/
PImage QR;

/* communication */
OscP5 oscP5;
NetAddress myRemoteLocation;
API_Client client;
String msgs;

/* font */
PFont font;
float timeInterval;
float timePast;
int textFade=4;
int textAlpha=200;

boolean style_done = false;
boolean new_user_arrived = true;
boolean mouse_first_click = false;
boolean photo_taken = false;
boolean warning_auth = false;

// STATES
boolean MAIN = true;
boolean PHOTO = false;
boolean PROCESSING = false;


void setup() {
  client = new API_Client();
  client.deleteAll(); //svuoto il database
  //size(displayWidth,displayHeight,P3D);
  size(displayWidth,displayHeight);
  frameRate(10);
  timePast=millis();
  timeInterval=2000.0f;
  
  oscP5 = new OscP5(this, 4321);
  font =createFont("GOGOIA-Regular.ttf",200);
  participants_spotify_values = new ArrayList<SpotifyParameter>();

  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
}

void textFade(){
  if(millis()>timeInterval+timePast){
  timePast=millis();
  textFade*=-1;
  }
  textAlpha+=textFade;
}

void draw() {

  if (new_user_arrived){
    background(255);
    textAlign(CENTER);
    textFont(font);
    noStroke();
    fill(44,100,172);
    textSize(200);
    text("COLLECTIVE DYNAMIC PORTRAIT", width/2, height/6);
    textSize(120);
    textFade();
    fill(44,100,172,textAlpha);
    QR = loadImage("QR_heroku.png");
    image(QR, width/2, 3*height/5, 200, 200);
    text("Scan the QR code and then click here to start!", width/2, height/2);
  }

   if(message_receiver != ""){
     
     //if(participants_spotify_values.size()==0 || !sp.checkEqual(participants_spotify_values.get(participants_spotify_values.size()-1))){
      //  participants_spotify_values.add(sp);
      //  println(sp.getReqString());
      //}
      background(255);
      textAlign(CENTER);
      textSize(120);
      noStroke();
      fill(44,100,172);
      text("Press ENTER and say Cheese...!", width/2, height/2);
    }

   if (style_done){
     updatePortrait();
     background(255);
     textAlign(CENTER);
     textSize(100);
     noStroke();
     fill(44,100,172);
     QR = loadImage("QR_heroku.png");
     image(QR, 3*width/4, 2*height/5, 200, 200);
     text("A new person arrives...", width/2, height/8); // aggiungo la frase in alto sopra le foto
     text("Scan the QR and then double click to join", width/2, 2*height/8);
     // plot one part for each image
     for(int index=0; index<img.length;index++){
       for(int image=0;image<img.length;image++){
         // for now just follow sequential order
         if (index == image)
           image(small_images[index + total_parts*image],pos_image[index].x,pos_image[index].y);
       }
     }
   }

   //if (mouse_first_click){
   //   background(255);
   //   textAlign(CENTER);
   //   textSize(120);
   //   noStroke();
   //   fill(44,100,172);
   //   text("go check the server's command line", width/2, height/2);
   //}

   if (photo_taken){
      background(255);
      textAlign(CENTER);
      textSize(120);
      noStroke();
      fill(44,100,172);
      text("Now relax, take a look around, have a cup of tea, while we make some magic...", width/2, height/2);
   }

}


void mouseClicked(){
  
  if(message_receiver == "" && new_user_arrived){
   
    new_user_arrived = false;
    style_done = false;
    
    //OscMessage myMessage = new OscMessage("/spotify");
    //oscP5.send(myMessage, myRemoteLocation);
    
  }else if (style_done){
    new_user_arrived = true;
  }
}

void keyPressed(){
  OscMessage myMessage;
  if (key == '\n'){
    
    // three STATES
    if (MAIN){
      SpotifyParameter temp = client.get_msgs();
      // check if user did not give authorizaton with qr code
      if(temp!=null && ! participants_spotify_values.get(participants_spotify_values.size()-1).checkEqual(temp)) {
        participants_spotify_values.add(temp);
        println("Features received:");
        println(temp.getReqString()); // song name needs to be added
        
        MAIN = false;
        PHOTO = true;
        warning_auth = false;
      }
      else{
        warning_auth = true;
      }
        
    }
    
    else if(PHOTO){
      

      // ask python to take photo
      myMessage = new OscMessage("/photo");
      myMessage.add(participants_spotify_values.size());
      oscP5.send(myMessage, myRemoteLocation);
      
      // for final project is better to wait for message from python server
      // wait until face file is created
      try{
        do{
          delay(1000);
          print((str(participants_spotify_values.size()) + "_face.jpg"));
          
          //if (message_receiver)
          
        } while(! fileExistsCaseSensitive(str(participants_spotify_values.size()) + "_face.jpg"));
      }catch (Exception e){
        println("error: " + e);
      }
      
    }
    else if(PROCESSING){
      myMessage = new OscMessage("/style");
      myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getAcousticness()); //prendo l'acousticness dagli ultimi valori aggiunti
      myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getValence());  //prendo la valence dagli ultimi valori aggiunti
      myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getEnergy()); //prendo l'energy dagli ultimi valori aggiunti
      myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getSpeechiness());  //prendo la speechiness dagli ultimi valori aggiunti
      //myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getTempo()); //prendo il tempo dagli ultimi valori aggiunti
      //myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getDanceability());  //prendo la danceability dagli ultimi valori aggiunti
      //myMessage.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getMode()); //prendo il mode dagli ultimi valori aggiunti
      myMessage.add(str(participants_spotify_values.size()) + "_face.jpg");

      /* Send photo and params to style_transfer script */
      oscP5.send(myMessage, myRemoteLocation);
    }
  }
  
  
  
  
  
  
  
  
  
  
    // only enter is accepted
    if (key == '\n' ) {
    
    
    println("mando osc style");
    // send stylized photo
        
  }
}

void oscEvent(OscMessage theOscMessage) {
  
  if(theOscMessage.checkAddrPattern("/photo_return")==true){
    message_receiver = theOscMessage.get(0).stringValue();
  }
  
  //if(theOscMessage.checkAddrPattern("/spotify_return")==true){
    
  //  //leggo i valori ricevuti
  //  message_receiver = theOscMessage.get(0).stringValue();
    
  //  println("Spotify parameters: " + message_receiver);
  //  SpotifyParameter sp = new SpotifyParameter(message_receiver);
  //  participants_spotify_values.add(sp);
  //  mouse_first_click = false;
  //}
  
  if(theOscMessage.checkAddrPattern("/style_return")==true){
    style_done = true;
    photo_taken = false;
  }
}
