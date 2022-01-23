import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PImage img0,small_img0;
//int posX,posY,v=0;
int v=0;
int posX;
int posY;
int wid,hei;



void setup() {
  size(640, 480);
  video = new Capture(this, 640/2, 480/2);
  //video = new Capture(this, 640/2, 480/2, "pipeline: ksvideosrc device-index=0! image/jpeg, width=640/2, height=480/2, framerate=30/1 ! jpegdec ! videoconvert");
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
}

void draw() {
  
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(255, 255, 255);
  strokeWeight(1);
  Rectangle[] faces = opencv.detect();
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x * 0.8, faces[i].y * 0.6, faces[i].width *1.4, faces[i].height *1.5);
     
   // println(faces[i].x * 0.8);
    
     posX= int(faces[i].x * 0.8);
     posY=int(faces[i].y * 0.6);
     wid=int(faces[i].width *1.4);
     hei=int(faces[i].height *1.5);
   
   
    }
 
    
   
}



void captureEvent(Capture c) {
  c.read();
}

void mousePressed(){
 
  video.stop();
  println(posX);
  small_img0=get(posX, posY, wid, hei);
  image(small_img0,0,0);
  save(str(v)+".jpg");
  v=v+1;
  delay(1000);
  video.start();
  println(v);
  
}
  
