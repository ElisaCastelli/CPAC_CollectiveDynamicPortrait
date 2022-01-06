final int N_IMAGE_X=2;
final int N_IMAGE_Y=2;

final int total_image=N_IMAGE_X * N_IMAGE_Y;

PImage[] small_images;
PVector[] pos_image;


void settings(){
  size(displayWidth,displayHeight,P3D);
}


void setup(){
  int altezza=576;
  int larghezza=1024;
  PImage img=loadImage("40704.jpg");
  img.resize(larghezza,altezza);
  small_images=new PImage[total_image];
  pos_image=new PVector[total_image];
  
  int spacing_x=2;
  int spacing_y=2;
  int index=0;
  
  int small_images_width=larghezza/N_IMAGE_X;
  int small_images_height=altezza/N_IMAGE_Y;
   
  for(int y=0;y< N_IMAGE_Y; y++){
    for(int x=0;x< N_IMAGE_X; x++){
      small_images[index]=img.get(x*small_images_width,  y*small_images_height,  small_images_width,  small_images_height);
      pos_image[index]= new PVector(400 +  x *(small_images_width + spacing_x), 200 + 
      y *(small_images_height+spacing_y));
      
      index++;
      
    }
}
}

void draw() {
  background(0);
  for(int index=0; index<total_image;index++){
    image(small_images[index],pos_image[index].x,pos_image[index].y);
  }
}
