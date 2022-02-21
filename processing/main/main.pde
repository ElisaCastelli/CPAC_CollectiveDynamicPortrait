/*
NOTE

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

String photo_return="";
String style_transfer_return = "";
String pong = "";
ArrayList<SpotifyParameter> participants_spotify_values;

/*QR image*/
PImage QR;

/* communication */
OscP5 oscP5;
NetAddress myRemoteLocation;
API_Client client;
OscMessage myMessage;

/* font */
PFont font;
float timeInterval;
float timePast;
int textFade=4;
int textAlpha=200;

boolean warning_auth = false;
boolean warning_server = false;
boolean error_generic = false;

// STATES
boolean MAIN = true;
boolean PHOTO = false;
boolean PROCESSING = false;


void setup() {
  client = new API_Client();
  client.deleteAll(); //svuoto il database
  //size(displayWidth,displayHeight,P3D);
  size(displayWidth,displayHeight);
  frameRate(1);
  timePast=millis();
  timeInterval=2000.0f;
  
  oscP5 = new OscP5(this, 4321);
  font =createFont("GOGOIA-Regular.ttf",200);
  participants_spotify_values = new ArrayList<SpotifyParameter>();

  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
  
  // ping
  myMessage = new OscMessage("/ping");
  oscP5.send(myMessage, myRemoteLocation);
}

void textFade(){
  if(millis()>timeInterval+timePast){
  timePast=millis();
  textFade*=-1;
  }
  textAlpha+=textFade;
}

void draw() {
  
  if (MAIN){
    println("back in main!");
    background(255);
    textAlign(CENTER);
    textFont(font);
    fill(44,100,172);
    noStroke();
    updatePortrait();
    textSize(150);
    text("COLLECTIVE DYNAMIC PORTRAIT", width/2, height/10);
    textSize(100);
    fill(44,100,172);
    QR = loadImage("QR_heroku.png");
    image(QR, 11 * width/12, 10*height/12, 200, 200);
    text("Scan the QR and press enter to join", width/2, 1.5 * height/8);
    // plot one part for each image
    for(int index=0; index<img.length;index++){
      for(int image=0;image<img.length;image++){
        // for now just follow sequential order
        if (index == image)
          image(small_images[index + total_parts*image],pos_image[index].x,pos_image[index].y);
      }
    }
  }
   
   else if(PHOTO){
     println("take a photo");
      background(255);
      textAlign(CENTER);
      textFont(font);
      fill(44,100,172);
      noStroke();
      //if(participants_spotify_values.size()==0 || !sp.checkEqual(participants_spotify_values.get(participants_spotify_values.size()-1))){
      //  participants_spotify_values.add(sp);
      //  println(sp.getReqString());
      //}
      textSize(120);
      fill(44,100,172);
      text("Press ENTER and say Cheese...!", width/2, height/2);
   }
   else if (PROCESSING){
     println("relax");
      background(255);
      textAlign(CENTER);
      textSize(120);
      fill(44,100,172);
      noStroke();
      text("Now relax, take a look around, have a cup of tea, while we make some magic...", width/2, height/2);
   }

  if (warning_server){
    textFont(font);
    textSize(80);
    fill(255,20,20);
    text("server not connected", width/8, height/8);
  }
  
  if (warning_auth){
    textFont(font);
    textSize(80);
    fill(255,20,20);
    text("ohhhh", 7 * width/8, height/8);
  }

}

void keyPressed(){
  if (key == '\n'){
    
    // new ping
    myMessage = new OscMessage("/ping");
    oscP5.send(myMessage, myRemoteLocation);
    
    //check if server is running
    if (pong == ""){
      warning_server = true;
      println("server is not running!");
    }
    else {
      println("pong received...");
      //set pong to empty for constant control
      pong = "";
      
      warning_server = false;
      // three STATES
      if (MAIN){
        SpotifyParameter temp = client.get_msgs();
        // check if user did not give authorizaton with qr code
        if(temp!=null){
          // add the user to the value list if he is the first participant OR, if he is not, I check that he didn't participate in the previous photo
          if (!error_generic && (participants_spotify_values.size() == 0 || !participants_spotify_values.get(participants_spotify_values.size()-1).checkEqual(temp))){
            participants_spotify_values.add(temp);
            
            println("Features received:");
            println(temp.getReqString()); // song name needs to be added
            
            // change STATE
            MAIN = false;
            PHOTO = true;
            warning_auth = false;
            
          }
          // check that, if an error occoured, The participant is the same or still the first one, so he can skip giving again authorization
          else if (error_generic && (participants_spotify_values.size() == 0 || participants_spotify_values.get(participants_spotify_values.size()-1).checkEqual(temp))){
            println("Features received:");
            println(temp.getReqString()); // song name needs to be added
            
            // change STATE
            MAIN = false;
            PHOTO = true;
            error_generic = false;
            warning_auth = false;
          }
          // last case: no error occourred, but participant forgot to give the authorization. 
          else if (!error_generic && participants_spotify_values.get(participants_spotify_values.size()-1).checkEqual(temp)){
            warning_auth = true;
          }
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
            if (! photo_return.equals("") && ! photo_return.equals("0")){
                            
              // change STATE
              PHOTO = false;
              MAIN = true;
              error_generic = true;
              photo_return = "";
              break;
            }
            
          } while(! fileExistsCaseSensitive(str(participants_spotify_values.size()) + "_face.jpg"));
        }catch (Exception e){
          println("error: " + e);
        }
        // change STATE
        PHOTO = false;
        PROCESSING = true;
        photo_return = "";
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
                        
        try{
          do{
            delay(1000);
            println(PROCESSING);
            if (! style_transfer_return.equals("") && ! style_transfer_return.equals("0")){
              // change STATE
              PROCESSING = false;
              MAIN = true;
              error_generic = true;
              style_transfer_return = "";
              break;
            }
            
          } while(! style_transfer_return.equals("0") );
        }catch (Exception e){
          println("error: " + e);
        }
        
        println("finito");
        
        // change STATE
        PROCESSING = false;
        MAIN = true;
        style_transfer_return = "";
      }
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  
  if(theOscMessage.checkAddrPattern("/photo_return")==true){
    photo_return = theOscMessage.get(0).stringValue();
  }
  
  if(theOscMessage.checkAddrPattern("/style_return")==true){
    style_transfer_return = theOscMessage.get(0).stringValue();
  }
  
  if(theOscMessage.checkAddrPattern("/pong")==true){
    pong = theOscMessage.get(0).stringValue();
  }
  
}
