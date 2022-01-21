
class SpotifyParameter{
  
  float acousticness;
  float valence;
  
  SpotifyParameter(String message){
    int length = message.length();
     int parsePosition = message.indexOf(",");
     acousticness = float(message.substring(1,parsePosition-1));
     valence = float(message.substring(parsePosition+2, length-1 ));
     
  }
  
}
