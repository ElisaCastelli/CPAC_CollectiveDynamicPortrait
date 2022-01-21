from lib2to3.pgen2 import token
import requests

import argparse
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

from spotipy.oauth2 import SpotifyOAuth

client = udp_client.SimpleUDPClient("127.0.0.1", 4321)


class GetUserTopTracks:
    def __init__(self):
        self.spotify_token = login()
    
    def get_top_tracks(self):
        """Search For the top Song"""
        query = "https://api.spotify.com/v1/me/top/tracks?limit=1"
        response = requests.get(
            query,
            headers={
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer {}".format(self.spotify_token)
            }
        )
        response_json = response.json()
        artist = response_json["items"][0]["artists"][0]["name"]
        song = response_json["items"][0]["name"]
        uri = response_json["items"][0]["id"]

        print(artist + ' - ' + song)

        return artist, song, uri

    def get_track_features(self):
        """Search For the Song Features"""
        artist, song, uri = self.get_top_tracks()

        query = "https://api.spotify.com/v1/audio-features/{}".format(uri)
        response = requests.get(
            query,
            headers={
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer {}".format(self.spotify_token)
            }
        )
        response_json = response.json()
        acousticness = response_json["acousticness"]
        valence = response_json["valence"]

        print("acousticness: {} \nvalence: {}".format(acousticness, valence))

        return acousticness, valence


def sendvalues(unused_addr):
    cp = GetUserTopTracks()
    acousticness, valence = cp.get_track_features()

    msg = str("acousticness: {} \nvalence: {}".format(acousticness, valence))
  
    client.send_message("/mousepressed", "{}".format(msg))


def login():
    global sp_oauth 
    sp_oauth, access_token = create_spotify_oauth()
    return access_token

def create_spotify_oauth():
    sp_oauth_init = SpotifyOAuth(
                client_id="49e612edb8144e78befdfceaf0612429",
                client_secret="73fab72888874b4483f74f64ffad137c",
                redirect_uri="authorize",
                scope="user-top-read")
    
    access_token = authorize(sp_oauth_init)

    return sp_oauth_init, access_token

def authorize(sp_oauth):
    token_info = sp_oauth.get_access_token()
    access_token = token_info["access_token"]
    return access_token



if __name__ == '__main__':
    cp = GetUserTopTracks()
    cp.get_track_features()


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