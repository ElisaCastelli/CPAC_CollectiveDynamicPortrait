import argparse
import requests
import random
import time
import os

from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

from spotipy.oauth2 import SpotifyClientCredentials


client = udp_client.SimpleUDPClient("127.0.0.1", 4321)


class GetUserTopTracks:
    def __init__(self):
        self.spotify_token = login()
    
    def get_top_tracks(self):
        """Search For the top Song"""
        query = "https://api.spotify.com/v1/me/top/tracks?time_range=short_term&limit=5"
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
    
    def get_user_profile(self):
        """Search For the user logged in"""
        query = "https://api.spotify.com/v1/me"
        response = requests.get(
            query,
            headers={
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer {}".format(self.spotify_token)
            }
        )
        response_json = response.json()
        user = response_json["display_name"]

        print(user)

        return user


def sendvalues(unused_addr):
    cp = GetUserTopTracks()
    cp.get_user_profile()
    acousticness, valence = cp.get_track_features()

    msg = [acousticness, valence]
  
    client.send_message("/mousepressed", "{}".format(msg))


def login():
    cid = '49e612edb8144e78befdfceaf0612429'
    secret = '73fab72888874b4483f74f64ffad137c'
    client_credentials_manager = SpotifyClientCredentials(
        client_id=cid, client_secret=secret)
    token = client_credentials_manager.get_access_token()
    # access_token = token["access_token"]
    print("\nplease go to this link and generate your token, checking user-read-private and user-top-read")
    print("https://developer.spotify.com/console/get-current-user/")
    access_token = input("Enter your token: ")

    return access_token




# function for handling style transfer requests
def run_style_transfer(message_id, acousticness, valence, content_image):
# format is used to format the numbers for string values instead of objects:
    print(message_id,"OSC ID")
    print("acousticness -> ", acousticness)
    print("valence -> ", valence)
    print("content image -> ", content_image)

    process_out = os.popen('python style_transfer_demo.py ' + str(acousticness) + ' ' + str(valence) + ' ' + content_image).read()
    # check that the last character (actually, last two to be sure) is the exit status 0
    if int(process_out[-2:]) == 0:
        client.send_message("/keypressed", "0")
        print('style transfer completed!')
    elif int(process_out[-2:]) == 1:
        client.send_message("/keypressed", "1")
        print('something went wrong during style transfer: missing stylized picture')

    else:
        client.send_message("/keypressed", "2")
        print('something went terribly wrong. go check the code NOW')

    

# function for handling take photo
def run_take_photo(message_id, participant_id):
    print(message_id,"OSC ID")
    print("participant_id -> ", participant_id)

    process_out = os.popen('python take_photo_demo.py ' + str(participant_id)).read()
    # check that the last character (actually, last two to be sure) is the exit status 0
    if int(process_out[-2:]) == 0:
        client.send_message("/keypressed", "0")
        print('photo taken and face obtained!')
    elif int(process_out[-2:]) == 1:
        client.send_message("/keypressed", "1")
        print('something went wrong with the camera')
    elif int(process_out[-2:]) == 2:
        client.send_message("/keypressed", "2")
        print('something went terribly wrong. go check the code NOW')
    else:
        client.send_message("/keypressed", "3")
        print('face not detected')

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=5005,
        help="The port the OSC server is listening on")
    args = parser.parse_args()

    dispatcher = dispatcher.Dispatcher()

    # This links a messageID to a function. 
    # That is, when a message with a given ID is received, the given function is run:
    dispatcher.map("/spotify",sendvalues)
    dispatcher.map("/style",run_style_transfer)
    dispatcher.map("/photo",run_take_photo)

    
    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()