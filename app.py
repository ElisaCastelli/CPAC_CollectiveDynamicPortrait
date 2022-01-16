from flask import Flask, redirect, url_for, request, session
from flask_sqlalchemy import SQLAlchemy
import spotipy
import os
import time
from spotipy.oauth2 import SpotifyOAuth

app = Flask(__name__)

app.config["DEBUG"] = True
app.secret_key = "IU86bytdtb72boLAui"
app.config['SESSION_COOKIE_NAME'] = 'spotify-login-session'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:andres123@localhost/CPAC'
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

@app.route("/")
def login():
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
    sp_oauth = create_spotify_oauth()
    session.clear()
    code = request.args.get('code')
    token_info = sp_oauth.get_access_token(code)
    session["token_info"] = token_info #metto le informazioni del token nella session
    return redirect("/getParameters")

@app.route('/getParameters')
def getParameters():
    session['token_info'], authorized = get_token()
    session.modified = True
    if not authorized:
        return redirect('/')
    sp = spotipy.Spotify(auth=session.get('token_info').get('access_token'))
    #rsp.current_user_top_tracks(time_range='medium_term', limit=1, offset=0)
    for track in sp.current_user_saved_tracks(limit=1, offset=0)["items"]:
        track_uri = track["track"]["uri"]
        track_features = sp.audio_features(track_uri)[0]
        track_id = track_features["id"]
        song = sp.track(track_id)
        track_name = song["name"]
        track_artist = song["artists"][0]["name"]
        val = track_features["valence"]
        acoustic = track_features["acousticness"]
        params = {"acousticness": acoustic, "valence": val}

    write_db(params)
    return params

class Values(db.Model):
    pos = db.Column(db.Integer)
    val_acousticness = db.Column(db.Integer, nullable=False, primary_key=True)
    val_valence = db.Column(db.Integer, nullable=False)

    def __init__(self, val_acousticness, val_valence):
        self.val_acousticness = val_acousticness
        self.val_valence = val_valence

def write_db(values):
    acousticness = values["acousticness"]
    valence = values["valence"]
    
    entry = Values(acousticness, valence)

    db.session.add(entry)
    db.session.commit()

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


if __name__ == '__main__':
    db.create_all()
    app.run()