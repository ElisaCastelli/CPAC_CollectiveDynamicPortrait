

// number of rows/columns of division
final int N_IMAGE_X=2;
final int N_IMAGE_Y=2;
final int total_parts=N_IMAGE_X * N_IMAGE_Y;
// for now number of images coincides with total parts
final int n_images=total_parts;

PImage[] small_images;
PVector[] pos_image;
PImage[] img;
int value=1;
//int r=int(random(total_parts));

//text
String s="PRESS A KEY TO START!";
//PFont f=createFont("LetterGothicStd.ttf",32);
float timeInterval;
float timePast;
int textFade=2;
int textAlpha=100;
PImage qrcodeImage;

//size of the face images
 int img_height=500;
  int img_width=1000;


void settings(){
  size(displayWidth,displayHeight,P3D);
   println(displayWidth);
 println( displayHeight);


}


void setup(){
 
  qrcodeImage= loadImage("QRCODE.jpg");
  timePast=millis();
  timeInterval=2000.0f;
  
 img=new PImage[n_images];
 small_images=new PImage[total_parts*n_images];
 // for each image
 for(int image=0;image<img.length;image++){
   img[image]=loadImage(str(image) + ".jpg");
   
 // int img_height=img[image].height;
  //int img_width=img[image].width;
  
 
  
  
  img[image].resize(img_width,img_height);
  //debug
  //println("small_images length: " + small_images.length);
  
  pos_image=new PVector[total_parts];
  
  float spacing_x=0.1;
  float spacing_y=0.1;
  int index=0;
  
  int small_images_width=img_width/N_IMAGE_X;
  int small_images_height=img_height/N_IMAGE_Y;
    //for each pair of x-y coordinates
    for(int y=0;y< N_IMAGE_Y; y++){
      for(int x=0;x< N_IMAGE_X; x++){
        // add current image part to small_images
        small_images[index + total_parts*image]=img[image].get(x*small_images_width,  y*small_images_height,  small_images_width,  small_images_height);
        pos_image[index]= new PVector(450 +  x *(small_images_width + spacing_x), 250 +  y *(small_images_height+spacing_y));
        //debug
        //println("index: " + index);
        index++;
      
      }
    } 
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
    background(0);
    textFade();
    textSize(100);
    fill(153,51,102,textAlpha);
    //textFont(f);
    text(s,displayWidth/4-50,displayHeight/2);


 
if(value==0){
  background(256);
  //image(qrcodeImage,displayWidth/2-qrcodeImage.width,  displayHeight/2-qrcodeImage.height,  500,500); 
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


void keyPressed(){
  value=0;
}
