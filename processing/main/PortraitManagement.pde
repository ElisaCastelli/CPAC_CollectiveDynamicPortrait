void updatePortrait(){

  int img_height = displayHeight / 2;
  int img_width= displayHeight / 2;
  int lastPhotoExistent = 0; //tengo memorizzato l'indice dell'ultima presente
  img=new PImage[total_parts];
  small_images=new PImage[total_parts*total_parts];
  //File dataFolder2 = new File(dataPath("/Users/elisacastelli/Documents/GitHub/CPAC_CollectiveDynamicPortrait/pictures"));

  if(participants_spotify_values.size()<total_parts){
    for(int image=0; image < img.length; image++){
      if (fileExistsCaseSensitive("stylized" + str(image+1) + "_face" + ".jpg")) {
        lastPhotoExistent=image;
        img[image]=loadImage("../../../pictures/" + "stylized" + str(image+1) + "_face" + ".jpg");
        //img[image]=loadImage(dataFolder2 + "/stylized" + str(image+1) + "_face" + ".jpg");
      } else { //se non esiste la foto ristampo l'ultima presente
        img[image]=loadImage("../../../pictures/" + "stylized" + str(lastPhotoExistent+1) + "_face" + ".jpg");
        //img[image]=loadImage(dataFolder2+ "/stylized" + str(lastPhotoExistent+1) + "_face" + ".jpg");
      }
      plotSmallImage(image, img_height, img_width);
    }
  }
  else if(participants_spotify_values.size() == total_parts){
    for(int image=0; image < img.length; image++){
      if (fileExistsCaseSensitive("stylized" + str(image+1) + "_face" + ".jpg")) {
        img[image]=loadImage("../../../pictures/" + "stylized" + str(image+1) + "_face" + ".jpg");
        //img[image]=loadImage(dataFolder2 + "/stylized" + str(image+1) + "_face" + ".jpg");
      }
      else { // tengo questo else per sicurezza ma se funziona puoi toglierlo
        img[image]=loadImage("../../../pictures/" + "ghost_photo.jpg");
        //img[image]=loadImage(dataFolder2 + "/ghost_photo.jpg");
      }
      plotSmallImage(image, img_height, img_width);
    }
  }else if (participants_spotify_values.size() > total_parts){
    for(int index=participants_spotify_values.size() - img.length; index<participants_spotify_values.size(); index++){
      //int image = index - (participants_spotify_values.size() - img.length);
      int image = index % total_parts;    // usare il modulo è piu figo e leggibile
      if(fileExistsCaseSensitive("stylized"+str(index+1)+"_face"+".jpg")){
          img[image]=loadImage("../../../pictures/" + "stylized" + str(index+1) + "_face" + ".jpg");
          //img[image]=loadImage(dataFolder2 + "/stylized" + str(index+1) + "_face" + ".jpg");
      }
      else {
        img[image]=loadImage("../../../pictures/" + "ghost_photo.jpg");
        //img[image]=loadImage(dataFolder2 + "/ghost_photo.jpg");
      }
      plotSmallImage(image, img_height, img_width);
    }

  }
}

void plotSmallImage(int image, int img_height, int img_width){
    img[image].resize(img_width,img_height);

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
      index++;
    }
  }
}
