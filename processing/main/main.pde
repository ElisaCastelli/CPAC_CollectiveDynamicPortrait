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

// Boids
int xspacing = 16;
int w;
int ene = 150;
float amplitude;
int tem = 250;
float period;
float dx;
float[] x0values;
float[] y0values;
float[] x1values;
float[] y1values;
float[] x2values;
float[] y2values;
int initNum = 1000;
Flock path0;
Flock path1;
Flock path2;
Flock path3;
Flock path4;
Flock path5;
ArrayList<Boid> vehicles;

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
  
  // boids
  w = width+xspacing;
  x0values = new float[w/xspacing];
  y0values = new float[w/xspacing];
  x1values = new float[w/xspacing];
  y1values = new float[w/xspacing];
  x2values = new float[w/xspacing];
  y2values = new float[w/xspacing];
  
  calcWave();
  renderWave();
  
  vehicles = new ArrayList<Boid>();
  for (int i1=1; i1<initNum; i1++) {
    newBoid(random(width), random(height));
  }
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
      //plotBackground();
      
      int aco = (int)participants_spotify_values.get(participants_spotify_values.size()-1).getAcousticness();
      int val = (int)participants_spotify_values.get(participants_spotify_values.size()-1).getValence();
      ene = (int)participants_spotify_values.get(participants_spotify_values.size()-1).getEnergy();
      int spe = (int)participants_spotify_values.get(participants_spotify_values.size()-1).getSpeechiness();
      tem = (int)participants_spotify_values.get(participants_spotify_values.size()-1).getTempo();
      int dan = (int)participants_spotify_values.get(participants_spotify_values.size()-1).getDanceability();
      
      aco = ((aco+1)*255/2)/2;
      val = ((val+1)*255/2)/2;
      ene = ((ene+1)*255/2)/2;
      spe = ((spe+1)*255/2)/2;
      dan = ((dan+1)*255/2)/2;
      
      if (tem > 255/2) tem = 255/2;
      
      // r: tem/val
      // g: dan/spe
      // b: aco/ene
      
      int c = 0;
      for (Boid v : vehicles) {
        if (c < (initNum/(current_n_users+1)) && current_n_users >= 1)
        {
          v.applyBehaviors(vehicles, path0);
          v.run((tem+val), (dan+spe)/2, (aco+ene)/2);
        }
        else if (c >= (initNum/(current_n_users+1)) && c < (initNum*2/(current_n_users+1)) && current_n_users >= 2)
        {
          v.applyBehaviors(vehicles, path1);
          v.run((tem+val), (dan+spe), (aco+ene));
        }
        else if (c >= (initNum*2/(current_n_users+1)) && c < (initNum*3/(current_n_users+1)) && current_n_users >= 3)
        {
          v.applyBehaviors(vehicles, path2);
          v.run((tem+val), (dan+spe), (aco+ene)/2);
        }
        else if (c >= (initNum*3/(current_n_users+1)) && c < (initNum*4/(current_n_users+1)) && current_n_users >= 4)
        {
          v.applyBehaviors(vehicles, path3);
          v.run((tem+val)/2, (dan+spe), (aco+ene));
        }
        else if (c >= (initNum*4/(current_n_users+1)) && c < (initNum*5/(current_n_users+1)) && current_n_users >= 5)
        {
          v.applyBehaviors(vehicles, path4);
          v.run((tem+val), (dan+spe)/2, (aco+ene));
        }
        else
        {
          if (current_n_users != 0)
          {
            v.applyBehaviors(vehicles, path5);
            v.run((tem+val)/2, (dan+spe), (aco+ene)/2);
          }
        }
        c++;
      }
      
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

void newBoid (float x, float y) {
  float maxspeed = random(4, 8);
  float maxforce = 0.3;
  vehicles.add(new Boid(new PVector(x, y), maxspeed, maxforce));
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

void calcWave() {
  period = tem;
  amplitude = ene;
  dx = (TWO_PI/period)*xspacing;
  float x = 0.0;
  for (int i=0; i<x1values.length; i++) {
    x0values[i] = cos(x)*amplitude/2;
    y0values[i] = sin(x)*amplitude/2;
    x1values[i] = -cos(x/2)*240 + cos(x*2)*160;
    y1values[i] = tan(-x/3+40)*40 + sin(x)*100;
    x2values[i] = sin(x+40)*50 + tan(x/2.5)*20;
    y2values[i] = sin(x-10)*350 - tan(x/6)*20;
    
    x += dx;
  }
}

void renderWave() {
  path0 = new Flock();
  path1 = new Flock();
  path2 = new Flock();
  path3 = new Flock();
  path4 = new Flock();
  path5 = new Flock();
  
  noStroke();
  fill(0);
  for (int x=0; x<x1values.length; x++) {
    path0.addPoint(x*xspacing, height/4+x0values[x]);
    path1.addPoint(x*xspacing, height/2+x1values[x]);
    path2.addPoint(x*xspacing, height/2+y1values[x]);
    path3.addPoint(x*xspacing, height/2+x2values[x]);
    path4.addPoint(x*xspacing, height/2+y2values[x]);
    path5.addPoint(x*xspacing, height*3/4+y0values[x]);
  }
    
  path0.addPoint(width+xspacing*2, height/2);
  path0.addPoint(width+xspacing*2, -xspacing*2);
  path0.addPoint(-xspacing*2, -xspacing*2);
  path0.addPoint(-xspacing*2, height/2);
  
  path1.addPoint(width+xspacing*2, height);
  path1.addPoint(width+xspacing*2, -xspacing*2);
  path1.addPoint(-xspacing*2, -xspacing*2);
  path1.addPoint(-xspacing*2, height);
  
  path2.addPoint(width+xspacing*2, height/2);
  path2.addPoint(width+xspacing*2, -xspacing*2);
  path2.addPoint(-xspacing*2, -xspacing*2);
  path2.addPoint(-xspacing*2, height/2);
  
  path3.addPoint(width+xspacing*2, height/2);
  path3.addPoint(width+xspacing*2, -xspacing*2);
  path3.addPoint(-xspacing*2, -xspacing*2);
  path3.addPoint(-xspacing*2, height/2);
  
  path4.addPoint(width+xspacing*2, height/2);
  path4.addPoint(width+xspacing*2, -xspacing*2);
  path4.addPoint(-xspacing*2, -xspacing*2);
  path4.addPoint(-xspacing*2, height/2);
  
  path5.addPoint(width+xspacing*2, height*3/4);
  path5.addPoint(width+xspacing*2, -xspacing*2);
  path5.addPoint(-xspacing*2, -xspacing*2);
  path5.addPoint(-xspacing*2, height/2);
}
