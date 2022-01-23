final int N_IMAGE_X=2;
final int N_IMAGE_Y=1;

final int total_image=N_IMAGE_X * N_IMAGE_Y;
final int n_images=2;

PImage[] small_images;
PVector[] pos_image;
PImage[] img;
//int r=int(random(total_image));


void settings(){
  size(displayWidth,displayHeight,P3D);
  


}


void setup(){
  
 img=new PImage[n_images];

 for(int i=0;i<img.length;i++){
   img[i]=loadImage(str(i) + ".jpg");
   
  int img_height=img[i].height;
  int img_width=img[i].width;
  
  img[i].resize(img_width,img_height);
  small_images=new PImage[total_image];
  pos_image=new PVector[total_image];
  
  int spacing_x=2;
  int spacing_y=2;
  int index=0;
  
  int small_images_width=img_width/N_IMAGE_X;
  int small_images_height=img_height/N_IMAGE_Y;
   
    for(int y=0;y< N_IMAGE_Y; y++){
      for(int x=0;x< N_IMAGE_X; x++){
        small_images[index]=img[i].get(x*small_images_width,  y*small_images_height,  small_images_width,  small_images_height);
        pos_image[index]= new PVector(400 +  x *(small_images_width + spacing_x), 200 +  y *(small_images_height+spacing_y));
      
        index++;
      
      }
    } 
  }
}



void draw() {
  background(255);
 
for(int index=0; index<img.length;index++){
    image(small_images[index],pos_image[index].x,pos_image[index].y);
    }

  
}
