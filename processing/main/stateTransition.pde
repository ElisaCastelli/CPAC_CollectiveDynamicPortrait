
void waitPhoto(){
  try{
    do{
      delay(100);
      if (! photo_return.equals("") && ! photo_return.equals("0")){            
        // change STATE
        PHOTO = false;
        MAIN = true;
        error_generic = true;
        photo_return = "";
        break;
      }
      
    } while(! fileExistsCaseSensitive(str(participants_spotify_values.size()) + "_face.jpg"));
  }catch (Exception e){
    println("error: " + e);
  }
  
  // change STATE
  PHOTO = false;
  PROCESSING = true;
  photo_return = "";
}

void waitStyleTransfer(){
  try{
    do{
      delay(100);
      println(PROCESSING);
      if (! style_transfer_return.equals("") && ! style_transfer_return.equals("0")){
        // change STATE
        PROCESSING = false;
        MAIN = true;
        error_generic = true;
        style_transfer_return = "";
        break;
      }
      
    } while(! style_transfer_return.equals("0") );
  }catch (Exception e){
    println("error: " + e);
  }
  
  // change STATE
  PROCESSING = false;
  MAIN = true;
  style_transfer_return = "";
  
}
