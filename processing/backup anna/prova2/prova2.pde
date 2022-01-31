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
String s="PRESS A KEY TO START";
//PFont f=createFont("LetterGothicStd.ttf",32);
float timeInterval;
float timePast;
int textFade=2;
int textAlpha=100;


void settings(){
  size(displayWidth,displayHeight,P3D);
}


void setup(){
  timePast=millis();
  timeInterval=2000.0f;
  
 img=new PImage[n_images];
 small_images=new PImage[total_parts*n_images];
 // for each image
 for(int image=0;image<img.length;image++){
   img[image]=loadImage(str(image) + ".jpg");
   
 // int img_height=img[image].height;
  //int img_width=img[image].width;
  
  int img_height=1000;
  int img_width=1000;
  
  
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
        pos_image[index]= new PVector(400 +  x *(small_images_width + spacing_x), 200 +  y *(small_images_height+spacing_y));
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
  textSize(60);
  fill(153,51,102,textAlpha);
  //textFont(f);
  text(s,displayWidth/4,displayHeight/2);

  if(value==0){
    background(256);
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
