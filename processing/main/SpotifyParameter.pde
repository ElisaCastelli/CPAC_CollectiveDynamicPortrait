class SpotifyParameter{
  
  float acousticness, valence, energy, speechiness, tempo, danceability, mode;
  String request_string;
  
  SpotifyParameter(float acousticness,float valence,float energy,float speechiness,float tempo,float danceability,float mode, String request_string){
    this.acousticness = acousticness;
    this.valence = valence;
    this.energy = energy;
    this.speechiness = speechiness;
    this.tempo = tempo;
    this.danceability = danceability;
    this.mode = mode;
    this.request_string = request_string;
  }
  
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
  
  boolean checkEqual(SpotifyParameter sp2){
    return this.acousticness == sp2.getAcousticness() && this.valence == sp2.getValence() && this.energy == sp2.getEnergy() && this.speechiness == sp2.getSpeechiness() && this.tempo == sp2.getTempo() && this.danceability == sp2.getDanceability() && this.mode == sp2.getMode();
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

  String getRequest_string(){
    return request_string;  
  }
}
