void updatePortrait(){
  println(N_IMAGE_X + " " + N_IMAGE_Y + " " + current_n_users);
  int img_height = displayHeight / 2;
  int img_width= displayHeight / 2;
  int diff_users;
  int lastPhotoExistent = 0; //tengo memorizzato l'indice dell'ultima presente
  if(MAIN)
    updateImg();
  small_images=new PImage[total_parts*total_parts];
  //File dataFolder2 = new File(dataPath("/Users/elisacastelli/Documents/GitHub/CPAC_CollectiveDynamicPortrait/pictures"));

  println("img.length: " + img.length);
  if(current_n_users == 0){
    println("caso 0");
    img=new PImage[1];
    //img[image]=loadImage(dataFolder2 + "/ghost_photo.jpg");
    img[0]=loadImage("../../../pictures/" + "ghost_photo.jpg");
    plotSmallImage(0, img_height, img_width);
  }
  
  else /*if(current_n_users == total_parts) */{
    println("caso 2");
    
    diff_users = current_n_users - total_parts;
    
    println(N_IMAGE_X + " " + N_IMAGE_Y + " " + current_n_users + " eee" + total_parts);
    for(int image=0; image < total_parts; image++){
      if (fileExistsCaseSensitive("stylized" + str(image+1) + "_face" + ".jpg")) {
        img[image]=loadImage("../../../pictures/" + "stylized" + str(image + 1 + diff_users) + "_face" + ".jpg");
        //img[image]=loadImage(dataFolder2 + "/stylized" + str(image+1) + "_face" + ".jpg");
      }
      else { // tengo questo else per sicurezza ma se funziona puoi toglierlo
        img[image]=loadImage("../../../pictures/" + "ghost_photo.jpg");
        //img[image]=loadImage(dataFolder2 + "/ghost_photo.jpg");
      }
      plotSmallImage(image, img_height, img_width);
    }
  } 
  /*else if (current_n_users > total_parts) {
    println("caso 3");
    diff_users = current_n_users - total_parts;
    println(N_IMAGE_X + " " + N_IMAGE_Y + " " + current_n_users + " eee" + total_parts);
    for(int image=0; image < total_parts; image++){
      if (fileExistsCaseSensitive("stylized" + str(image+1) + "_face" + ".jpg")) {
        img[image]=loadImage("../../../pictures/" + "stylized" + str(image+1 + diff_users) + "_face" + ".jpg");
        //img[image]=loadImage(dataFolder2 + "/stylized" + str(image+1) + "_face" + ".jpg");
      }
      else { // tengo questo else per sicurezza ma se funziona puoi toglierlo
        img[image]=loadImage("../../../pictures/" + "ghost_photo.jpg");
        //img[image]=loadImage(dataFolder2 + "/ghost_photo.jpg");
      }
      plotSmallImage(image, img_height, img_width);
    }

  }*/
}

void plotSmallImage(int image, int img_height, int img_width){
    img[image].resize(img_width,img_height);

  pos_image=new PVector[total_parts];

  int spacing_x=0;
  int spacing_y=0;
  int index=0;

  int small_images_width=img_width/N_IMAGE_X;
  int small_images_height=img_height/N_IMAGE_Y;
  //for each pair of x-y coordinates
  for(int y=0;y< N_IMAGE_Y; y++){
    for(int x=0;x< N_IMAGE_X; x++){
      println("dentro for" +  N_IMAGE_X + " " + N_IMAGE_Y + " " + current_n_users);
      // add current image part to small_images
                                                         // get only the portion of image corresponding to the current subdivision
      small_images[index + total_parts*image]=img[image].get(x*small_images_width,  y*small_images_height,  small_images_width,  small_images_height);
      pos_image[index]= new PVector(displayWidth/2 - img_width/2 + x *(small_images_width + spacing_x), displayHeight/2 - img_height/2 +  y *(small_images_height + spacing_y));
      index++;
    }
  }
}

void updatePortraitDimensions(){
    switch(min(current_n_users, n_max_users)){
    case 0:
      N_IMAGE_X=1;
      N_IMAGE_Y=1;
    break;
    case 1:
      N_IMAGE_X=1;
      N_IMAGE_Y=1;
    break;
    case 2:
      N_IMAGE_X=2;
      N_IMAGE_Y=1;
    break;
    case 3:
      N_IMAGE_X=3;
      N_IMAGE_Y=1;
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
     N_IMAGE_X=7;
     N_IMAGE_Y=1;
     break;
    case 8:
     N_IMAGE_X=4;
     N_IMAGE_Y=2;
     break;
    default:
     N_IMAGE_X=3;
     N_IMAGE_Y=3;
     break;
  }
  
  total_parts = N_IMAGE_X * N_IMAGE_Y;
  updateImg();
}

void updateImg(){
  img=new PImage[total_parts];
}