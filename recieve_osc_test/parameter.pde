
class SpotifyParameter{
  
  float acousticness;
  float valence;
  
  SpotifyParameter(String message){
    int length = message.length();
     int parsePosition = message.indexOf(",");
     this.acousticness = float(message.substring(1,parsePosition));
     this.valence = float(message.substring(parsePosition+2, length-1 ));
     //print(acousticness);
     //print(valence);
  }
  
  float getAcousticness(){
    return acousticness;
  }
  
  float getValence(){
    return valence;
  }
  
}
