
class SpotifyParameter{
  
  float acousticness;
  float valence;
  
  SpotifyParameter(String message){
     int parsePosition = message.indexOf(",");
     acousticness = float(message.substring(1,parsePosition-1));
     valence = float(message.substring(1,parsePosition+2));
     
  }
  
}
