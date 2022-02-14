
class SpotifyParameter{
  
  float acousticness, valence, energy, speechiness, tempo, danceability, mode;
  
  SpotifyParameter(String message){
    String[] listParameters = split(message, ',');
    acousticness = float(listParameters[0]);
    valence = float(listParameters[1]);
    energy = float(listParameters[2]);
    speechiness = float(listParameters[3]);
    tempo = float(listParameters[4]);
    danceability = float(listParameters[5]);
    mode = float(listParameters[6]);
  }
  
  float getAcousticness(){
    return acousticness;
  }
  
  float getValence(){
    return valence;
  }
  float getEnergy(){
    return energy;
  }
  
  float getSpeechiness(){
    return speechiness;
  }
  float getTempo(){
    return tempo;
  }
  
  float getDanceability(){
    return danceability;
  }
  float getMode(){
    return mode;
  }
  
  
}
