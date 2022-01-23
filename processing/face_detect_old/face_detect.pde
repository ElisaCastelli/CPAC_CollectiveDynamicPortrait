import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PImage [] img;
//int posX,posY,v=0;
int v=0;

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
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x * 0.8, faces[i].y * 0.6, faces[i].width *1.4, faces[i].height *1.5);
    
    //posX=faces[i].x;
    //posY=faces[i].y;
  
 }
  
  //img[j]=loadImage(str(j)+".jpg");
  //image(small_img,0,0);
  
}

void captureEvent(Capture c) {
  c.read();
}
void mousePressed(){
  video.stop();
  save(str(v)+".jpg");
  v=v+1;
  delay(1000);
  video.start();
  println(v);
}
  
