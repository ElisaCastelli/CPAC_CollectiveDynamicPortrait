from flask import Flask, redirect, url_for, request, session
import spotipy
import os
import time
from spotipy.oauth2 import SpotifyOAuth

app = Flask(__name__)

app.config["DEBUG"] = True
app.secret_key = "IU86bytdtb72boLAui"
app.config['SESSION_COOKIE_NAME'] = 'spotify-login-session'


@app.route("/")
def login():
    global sp_oauth 
    sp_oauth = create_spotify_oauth()
    auth_url = sp_oauth.get_authorize_url()
    return redirect(auth_url)

def create_spotify_oauth():
    return SpotifyOAuth(
            client_id="49e612edb8144e78befdfceaf0612429",
            client_secret="73fab72888874b4483f74f64ffad137c",
            redirect_uri=url_for('authorize', _external=True),
            scope="user-library-read")

@app.route("/redirect")
def authorize():
    # sp_oauth = create_spotify_oauth()
    session.clear()
    code = request.args.get('code')
    token_info = sp_oauth.get_access_token(code)
    session["token_info"] = token_info #metto le informazioni del token nella session
    return redirect("/getParameters")

@app.route('/getParameters', methods=['GET'])
def getParameters():
    session['token_info'], authorized = get_token()
    session.modified = True
    if not authorized:
        return redirect('/')
    sp = spotipy.Spotify(auth=session.get('token_info').get('access_token'))
    track = sp.current_user_top_tracks(limit=1, offset=0, time_range="medium_term")["items"]
    track_name = track[0]["name"]
    track_URI = track[0]["uri"]
    track_features = sp.audio_features(track_URI)[0]
    acousticness = track_features["acousticness"]
    valence = track_features["valence"]
    params= {"TrackName":track_name, "Acousticness":acousticness, "Valence":valence}
    return params

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
