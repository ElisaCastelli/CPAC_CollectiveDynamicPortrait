import http.requests.*;


class API_Client{
  
  GetRequest req;
  
  //PostRequest post;
  String get_msg_api="";
  
  // ---- CONSTRUCTOR ----
  API_Client(String mainUrl){
    this.get_msg_api=mainUrl+"/get_msgs";
    this.req = new GetRequest(this.get_msg_api); 
    
  }
  
  // ---- METHODS ----
  SpotifyParameter get_msgs(){
    this.req.send();
    
    JSONObject JSONobj = parseJSONObject(req.getContent());
    float[] msgs=new float[JSONobj.size()]; 
    msgs[0] = JSONobj.getFloat("acousticness");
    msgs[1] = JSONobj.getFloat("valence");
    msgs[2] = JSONobj.getFloat("energy");
    msgs[3] = JSONobj.getFloat("speechiness");
    msgs[4] = JSONobj.getFloat("tempo");
    msgs[5] = JSONobj.getFloat("danceability");
    msgs[6] = JSONobj.getFloat("mode");
    SpotifyParameter sp = new SpotifyParameter(msgs[0],msgs[1],msgs[2],msgs[3],msgs[4],msgs[5],msgs[6], req.getContent());
    return sp;
  }
}
