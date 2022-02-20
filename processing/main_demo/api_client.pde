import http.requests.*;


class API_Client{
  String mainUrl="https://collective-dynamic-portrait.herokuapp.com"; 
  GetRequest req;
  
  //PostRequest post;
  String get_msg_api="";
  String deleteAll="";
  
  // ---- CONSTRUCTOR ----
  API_Client(){
    this.get_msg_api=mainUrl+"/get_msgs";
    this.deleteAll=mainUrl+"/delete_all";
  }
  
  // ---- METHODS ----
  SpotifyParameter get_msgs(){
    this.req = new GetRequest(this.get_msg_api); 
    this.req.send();
    SpotifyParameter sp = null;
    JSONObject JSONobj = parseJSONObject(req.getContent());
    if(JSONobj!=null){
      float[] msgs=new float[JSONobj.size()]; 
      msgs[0] = JSONobj.getFloat("acousticness");
      msgs[1] = JSONobj.getFloat("valence");
      msgs[2] = JSONobj.getFloat("energy");
      msgs[3] = JSONobj.getFloat("speechiness");
      msgs[4] = JSONobj.getFloat("tempo");
      msgs[5] = JSONobj.getFloat("danceability");
      msgs[6] = JSONobj.getFloat("mode");
      sp = new SpotifyParameter(msgs[0],msgs[1],msgs[2],msgs[3],msgs[4],msgs[5],msgs[6], req.getContent());
    }
    return sp;
  }
  
  void deleteAll(){
    this.req = new GetRequest(this.deleteAll); 
    this.req.send();
  }
  
}
