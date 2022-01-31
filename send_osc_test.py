import argparse
import random
import time

import spotipy
from spotipy.oauth2 import SpotifyOAuth

from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

client = udp_client.SimpleUDPClient("127.0.0.1", 4321)

def login():
    global sp_oauth 
    sp_oauth = create_spotify_oauth()
    auth_url = sp_oauth.get_authorize_url()
    authorize()

def create_spotify_oauth():
    client_credentials_manager = SpotifyClientCredentials(
        client_id=cid, client_secret=secret)
    global sp
    sp = spotipy.Spotify(
        client_credentials_manager=client_credentials_manager, requests_timeout=200)
    return SpotifyOAuth(
        client_id="49e612edb8144e78befdfceaf0612429",
        client_secret="73fab72888874b4483f74f64ffad137c",
        redirect_uri=url_for('authorize', _external=True),
        scope="user-top-read")

def authorize():
    # sp_oauth = create_spotify_oauth()
    session.clear()
    code = request.args.get('code')
    token_info = sp_oauth.get_access_token(code)
    session["token_info"] = token_info

def getParameters():
    session['token_info'], authorized = get_token()
    session.modified = True
    if not authorized:
        return redirect('/')

    sp = spotipy.Spotify(auth=session.get('token_info').get('access_token'))

    user = sp.current_user()
    global w_msg
    w_msg = "Welcome " + user["display_name"]
    w_msg1 = 112
    
    return w_msg1

def get_token():
    token_valid = False
    token_info = session.get("token_info", {})

    if not (session.get('token_info', False)): #controllo se è già attivo un token
        token_valid = False
        return token_info, token_valid

    now = int(time.time()) 
    is_token_expired = session.get('token_info').get('expires_at') - now < 60 #controllo se il token è scaduto

    if (is_token_expired):
        sp_oauth = create_spotify_oauth()
        token_info = sp_oauth.refresh_access_token(session.get('token_info').get('refresh_token'))

    token_valid = True
    return token_info, token_valid




def sendvalues(unused_addr):
    login()
    msg = getParameters()
  
    client.send_message("/mousepressed", "{}".format(msg))

def getParams():

    return 123

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=6543,
        help="The port the OSC server is listening on")
    args = parser.parse_args()

    dispatcher = dispatcher.Dispatcher()

    dispatcher.map("/miklo",sendvalues)

    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()