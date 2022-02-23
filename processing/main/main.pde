import oscP5.*;
import netP5.*;
import processing.video.*;
import peasy.*;
import ddf.minim.*;

/* dynamic background */
PeasyCam cam;
Minim minim;
AudioPlayer soundtrack_player = null;
AudioPlayer enter_sound_player = null;

float time_background;

/* image plot and division */

// number of rows/columns of division
int n_max_users = 9;
//int n_images;
int current_n_users = 0;
int N_IMAGE_X;
int N_IMAGE_Y;
int total_parts;
int frame_h;
int frame_w;
// for now number of images coincides with total parts

PImage[] small_images;
PVector[] pos_image;
PImage[] img;
PImage frame;


/* spotify */

String photo_return="";
String style_transfer_return = "";
String pong = "";
ArrayList<SpotifyParameter> participants_spotify_values;

/*QR image*/
PImage QR;

/* communication */
OscP5 oscP5;
NetAddress local_server;
OscMessage my_message;

API_Client django_communication;


/* font */
PFont font;
float timeInterval;
float timePast;
int textFade=4;
int textAlpha=200;

// WARNINGS
boolean warning_auth = false;
boolean warning_server = false;
boolean error_generic = false;

// STATES
boolean MAIN = true;
boolean PHOTO = false;
boolean PROCESSING = false;

//effects
float transparency = 0;
float transparency_2 = 0;

void settings(){
  size(displayWidth,displayHeight);
  
  updatePortraitDimensions();
}

void setup() {
  background(0);
  django_communication = new API_Client();
  django_communication.deleteAll(); //svuoto il database

  frameRate(24);
  timePast=millis();
  timeInterval=2000.0f;
  
  frame = loadImage("frame.png");
  frame_h = int(1.27* height/2);
  frame_w = int(1.53* height/2);
  frame.resize(frame_w, frame_h);
  total_parts = N_IMAGE_X * N_IMAGE_Y;
  
  /* background */
  cam=new PeasyCam(this,180);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  minim=new Minim(this);
  
  oscP5 = new OscP5(this, 4321);
  font =createFont("GOGOIA-Regular.ttf",200);
  participants_spotify_values = new ArrayList<SpotifyParameter>();

  local_server = new NetAddress("127.0.0.1", 5005);
  
  // ping
  my_message = new OscMessage("/ping");
  oscP5.send(my_message, local_server);
}

void textFade(){
  if(millis()>timeInterval+timePast){
  timePast=millis();
  textFade*=-1;
  }
  textAlpha+=textFade;
}

void draw() {
  //set common parameters
  background(0);
  textAlign(CENTER);
  textFont(font);
  fill(255, 255, 255);
  
  //plot INSTRUCTION according to the actual STATE
  if (MAIN){
    println("back in main!");
    updatePortrait();
    textSize(width/38);
    textFade();
    fill(255, 255, 255, textAlpha);
    text("Scan the QR and press enter to join", width/2, 1.5 * height/12);
    
    if  (! error_generic && participants_spotify_values.size() > 0){
      plotBackground();  
    }
  }
  else if(PHOTO){
      println("take a photo");
      textSize(width/38);
      text("Press ENTER and say Cheese...!", width/2, 1.5 * height/12);
  }
  else if (PROCESSING){
    //updatePortrait();
      println("relax");
      textSize(width/38);
      text("When you feel ready, press enter to make the magic begin...", width/2, 1.5 * height/12);
  }

  // plot WARNINGS
  
  if (warning_server){
      textFont(font);
      textSize(width/45);
      fill(255, 204, 128);
      text("server not connected", width/8, height/9);
  }
  
  if (warning_auth){
      textFont(font);
      textSize(width/45);
      fill(255, 204, 128);
      text("remember to scan the qr", 7 * width/8, height/9);
  }
  
  if (error_generic){
      textFont(font);
      textSize(width/45);
      fill(255, 204, 128);
      text("a problem occourred...", width/8, height/7);
      text("...returned to main screen", width/8, height/5.5);
  }
  
  transparency_2+=2;
  tint(255, transparency_2);
  println("dentro for" +  N_IMAGE_X + " " + N_IMAGE_Y + " " + current_n_users + " imglength" + img.length);
  for(int index=0; index<img.length;index++){
      for(int image=0;image<img.length;image++){
        // for now just follow sequential order
        if (index == image)
          image(small_images[index + total_parts*image],pos_image[index].x,pos_image[index].y);
      }
    }
  //plot title
  textSize(width/18);
  fill(255, 255, 255);
  text("COLLECTIVE DYNAMIC PORTRAIT", width/2, height/13);
  
  /* PORTRAIT FRAME */
  transparency+=5;
  tint(255, transparency);
  image(frame,pos_image[0].x- frame.width/5.7, pos_image[0].y- frame.width/11);
  
  
  
  //plot QR code
  QR = loadImage("QR_heroku.png");
  image(QR, 11 * width/12, 10*height/12, width/15, width/15);
}

void keyPressed(){
  if (key == '\n'){
    
    // new ping
    my_message = new OscMessage("/ping");
    oscP5.send(my_message, local_server);
    
    current_n_users = participants_spotify_values.size();
    
    
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
        SpotifyParameter temp = django_communication.get_msgs();
        // check if user did not give authorizaton with qr code
        if(temp!=null){
          // add the user to the value list if he is the first participant OR, if he is not, I check that he didn't participate in the previous photo
          if (!error_generic && (participants_spotify_values.size() == 0 || !participants_spotify_values.get(participants_spotify_values.size()-1).checkEqual(temp))){
            participants_spotify_values.add(temp);
            
            println("Features received:");
            println(temp.getRequest_string()); // song name needs to be added
            
            //lasdcio?
            delay(100);
            
            // change STATE
            MAIN = false;
            PHOTO = true;
            warning_auth = false;
            
            
            
          }
          // check that, if an error occoured, The participant is the same or still the first one, so he can skip giving again authorization
          else if (error_generic && (participants_spotify_values.size() == 0 || participants_spotify_values.get(participants_spotify_values.size()-1).checkEqual(temp))){
            println("Features received:");
            println(temp.getRequest_string()); // song name needs to be added
            
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
        my_message = new OscMessage("/photo");
        my_message.add(participants_spotify_values.size());
        oscP5.send(my_message, local_server);
        
        // wait until face file is created
        //updatePortrait();        
        waitPhoto();

      }
      else if(PROCESSING){
        
        
        println(N_IMAGE_X + " " + N_IMAGE_Y + " " + current_n_users);
        my_message = new OscMessage("/style");
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getAcousticness()); //prendo l'acousticness dagli ultimi valori aggiunti
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getValence());  //prendo la valence dagli ultimi valori aggiunti
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getEnergy()); //prendo l'energy dagli ultimi valori aggiunti
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getSpeechiness());  //prendo la speechiness dagli ultimi valori aggiunti
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getTempo()); //prendo il tempo dagli ultimi valori aggiunti
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getDanceability());  //prendo la danceability dagli ultimi valori aggiunti
        my_message.add((participants_spotify_values.get(participants_spotify_values.size()-1)).getMode()); //prendo il mode dagli ultimi valori aggiunti
        my_message.add(current_n_users); //prendo il numero dell'utente attuale
        my_message.add(str(participants_spotify_values.size()) + "_face.jpg");
  
        /* Send photo and params to style_transfer script */
        oscP5.send(my_message, local_server);
        
        minim=new Minim(this);
        
        enter_sound_player = minim.loadFile("../../../python/sounds/enter_sound.wav");
        enter_sound_player.play();
        
        
        waitStyleTransfer();
        updatePortraitDimensions();

      }
    }
  }
}

void oscEvent(OscMessage OSC_message_received) {
  
  if(OSC_message_received.checkAddrPattern("/photo_return")==true){
    photo_return = OSC_message_received.get(0).stringValue();
  }
  
  if(OSC_message_received.checkAddrPattern("/style_return")==true){
    style_transfer_return = OSC_message_received.get(0).stringValue();
  }
  
  if(OSC_message_received.checkAddrPattern("/pong")==true){
    pong = OSC_message_received.get(0).stringValue();
  }
  
}
