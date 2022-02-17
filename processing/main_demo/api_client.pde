import http.requests.*;

class API_Client{
  
  GetRequest req;
  
  String get_msg_api = "";
  // ---- CONSTRUCTOR ----
  API_Client(String mainUrl){
    this.get_msg_api = mainUrl + "/get_msgs";
    this.req = new GetRequest(this.get_msg_api); 
  }
  
  // ---- METHODS ----
  String get_msgs(){
    this.req.send();
    
    String msgs = new String();
    msgs = req.getContent();
    println("Response Content: " + msgs);
    return msgs;
  }
}
