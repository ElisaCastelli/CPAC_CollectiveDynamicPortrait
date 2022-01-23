/*
Processing flowchart:
- click per partecipare                             DONE
- qrcode appare                                     work in progress
- processing riceve valori spotify                  DONE
- esecuzione foto                                   DONE
- applicazione ritaglio,                            DONE
                divisione,                          DONE
                style transfer                      DONE
- aggiornamento quadro, attesa per successivo click    TODO


altri TODO:
  - gestione messaggi osc in arrivo
  - resettare schermata processing quando arriva uno 0 dopo style transfer
  - qualche transizione/animazione/abbellimento
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
final int n_images=total_parts;

PImage[] small_images;
PVector[] pos_image;
PImage[] img;

/* spotify */

String message_receiver;
ArrayList<SpotifyParameter> participants_spotify_values;




/* communication */
OscP5 oscP5;
OscP5 oscP5_spotify;
NetAddress myRemoteLocation;

/* font */
PFont font;

boolean style_done = false;

void setup() {
  size(1920,1080,P3D);
  int img_height = displayHeight / 2;
  int img_width= displayHeight / 2;
  frameRate(25);
  oscP5 = new OscP5(this, 4321);
  oscP5_spotify = new OscP5(this, 4321);
  font =createFont("GOGOIA-Regular.ttf",50);
  participants_spotify_values = new ArrayList<SpotifyParameter>();

  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
  
  img=new PImage[n_images];
  small_images=new PImage[total_parts*n_images];
  
  // for each image
  for(int image=0; image < img.length; image++){
    if (fileExistsCaseSensitive("stylized" + str(image+1) + "_face" + ".jpg")) {
      img[image]=loadImage("../../../pictures/" + "stylized" + str(image+1) + "_face" + ".jpg");
    }
    else {
      img[image]=loadImage("../../../pictures/" + "ghost_photo.jpg");
    }
    // int img_height=img[image].height;
    //int img_width=img[image].width;
    
    
    img[image].resize(img_width,img_height);
    //debug
    //println("small_images length: " + small_images.length);
    
    pos_image=new PVector[total_parts];
    
    int spacing_x=2;
    int spacing_y=2;
    int index=0;
    
    int small_images_width=img_width/N_IMAGE_X;
    int small_images_height=img_height/N_IMAGE_Y;
    //for each pair of x-y coordinates
    for(int y=0;y< N_IMAGE_Y; y++){
      for(int x=0;x< N_IMAGE_X; x++){
        // add current image part to small_images
        small_images[index + total_parts*image]=img[image].get(x*small_images_width,  y*small_images_height,  small_images_width,  small_images_height);
        pos_image[index]= new PVector(displayWidth/2 - img_width*N_IMAGE_X/4 + x *(small_images_width + spacing_x), displayHeight/2 - img_height*N_IMAGE_Y/4 +  y *(small_images_height + spacing_y));
        //debug
        //println("index: " + index);
        index++;
      
      }
    } 
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

   if(message_receiver != null){
      background(255);
      textAlign(CENTER);
      textSize(35);
      noStroke();
      fill(44,100,172);
      text("Press ENTER to participate!", width/2, height/2);
    }
    
   if (style_done){
     background(0);
     // plot one part for each image
     for(int index=0; index<img.length;index++){
       for(int image=0;image<img.length;image++){
         // for now just follow sequential order
         if (index == image)
           image(small_images[index + total_parts*image],pos_image[index].x,pos_image[index].y);
       }
     }
   }
    
}


void mousePressed(){
  
  if(message_receiver == null){
    style_done = false;
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
    
    println("hi");
    delay(3000);
    println("hey");
    style_done = true;
  }
  
  
    //message_receiver = null;
}

void oscEvent(OscMessage theOscMessage) {
  
  //leggo i valori ricevuti
  message_receiver = theOscMessage.get(0).stringValue();
  println("Spotify parameters: " + message_receiver);
  SpotifyParameter sp = new SpotifyParameter(message_receiver);
  participants_spotify_values.add(sp);
 
}
