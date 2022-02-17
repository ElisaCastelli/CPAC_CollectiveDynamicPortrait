
/* PARAMETERS */
//String API_URL="http://127.0.0.1:8000";
String API_URL="https://collective-dynamic-portrait.herokuapp.com";

/* GLOBAL VARIABLES */ 
API_Client client;
String msgs;

void setup(){
  client = new API_Client(API_URL);
  msgs = client.get_msgs();
}
