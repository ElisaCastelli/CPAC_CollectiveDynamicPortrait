

// number of rows/columns of division
final int n_max_users=9; //it's also equal to n_images max
 int n_images;
 int n_users=3; //which is equal to n_images
 
 int N_IMAGE_X;
 int N_IMAGE_Y;
 int total_parts;
// for now number of images coincides with total parts
 
 

PImage[] small_images;
PVector[] pos_image;
PImage[] img;
int value=1;

//text

PFont font;
float timeInterval;
float timePast;
int textFade=4;
int textAlpha=200;
PImage qrcodeImage;
PImage frame;
float transparency=0;



float x1 (float t){
  return sin(t/10)*500 - tan(t/20)*200;
}

float y1 (float t){
  return tan(-t/20)*300+sin(t/20)*200;
}

float x2 (float t){
  return sin(t/10)*500+ tan(t/10)*200;
}

float y2 (float t){
  return -cos(t/20)*300+ cos(t/12)*20;
}

void settings(){
  size(displayWidth,displayHeight,P3D);

  switch(n_users){
    case 1:
      N_IMAGE_X=1;
      N_IMAGE_Y=1;
    break;
    case 2:
      N_IMAGE_X=2;
      N_IMAGE_Y=1;
    break;
    case 3:
      N_IMAGE_X=1;
      N_IMAGE_Y=3;
    break;
    case 4:
      N_IMAGE_X=2;
      N_IMAGE_Y=2;
    break;
    case 5:
      N_IMAGE_X=5;
      N_IMAGE_Y=1;
    break;
    case 6:
     N_IMAGE_X=3;
     N_IMAGE_Y=2;
    break;
    case 7:
     N_IMAGE_X=1;
     N_IMAGE_Y=7;
     break;
    case 8:
     N_IMAGE_X=4;
     N_IMAGE_Y=2;
     break;
    case 9:
     N_IMAGE_X=3;
     N_IMAGE_Y=3;
     break;
    
  }
}


void setup(){
  
    //frameRate(10); 
  println(N_IMAGE_X);
  println(N_IMAGE_Y);
  total_parts=N_IMAGE_X * N_IMAGE_Y;
  println(total_parts);
  n_images=n_users;
  
   //size of the face images
 int img_height = displayHeight / 2;
  int img_width= displayHeight / 2;
  //cornice
  frame=loadImage("frame1.jpg");
  frame.resize(img_width+220,img_height+220);
  
  qrcodeImage= loadImage("QRCODE.jpg");
  
  //text
  font =createFont("GOGOIA-Regular.ttf",200);
  timePast=millis();
  timeInterval=2000.0f;
  
 img=new PImage[n_images];
 small_images=new PImage[total_parts*n_images];
 // for each image
 for(int image=0;image<img.length;image++){
   img[image]=loadImage(str(image) + ".jpg");
   
  
  
  img[image].resize(img_width,img_height);
  
  
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
        pos_image[index]= new PVector(displayWidth/2 - img_width*2/4  +  x *(small_images_width + spacing_x),  displayHeight/2 - img_height*2/4 +  y *(small_images_height+spacing_y));
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
    text("Click here to start!", width/2, height/2);


 
if(value==0){
 

  
  
  //image(qrcodeImage,10,10);
  //image(qrcodeImage,displayWidth/2-qrcodeImage.width,  displayHeight/2-qrcodeImage.height,  500,500); 



// plot one part for each image
transparency+=0.8;
tint(255, transparency);
image(frame,pos_image[0].x-110, pos_image[0].y-110);
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
