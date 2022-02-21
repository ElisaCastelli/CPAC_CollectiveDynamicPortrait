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


# handshake with processing
def pingpong(message_id):
    print(message_id,"OSC ID")
    client.send_message("/pong", "0")
    print("pong sent successfully!")

# function for handling style transfer requests
def run_style_transfer(message_id, acousticness, valence, energy, speechiness, content_image):
# format is used to format the numbers for string values instead of objects:
    print(message_id,"OSC ID")
    print("acousticness -> ", acousticness)
    print("valence -> ", valence)
    print("energy -> ", energy)
    print("speechiness -> ", speechiness)
    print("content image -> ", content_image)

    process_out = os.popen('python style_transfer_demo.py ' + str(acousticness) + ' ' + str(valence) + ' ' + str(energy) + ' ' + str(speechiness) + ' ' + content_image).read()
    # check that the last character (actually, last two to be sure) is the exit status 0
    if int(process_out[-2:]) == 0:
        client.send_message("/style_return", "0")
        print('style transfer completed!')
    elif int(process_out[-2:]) == 1:
        client.send_message("/style_return", "1")
        print('something went wrong during style transfer: missing stylized picture')

    else:
        client.send_message("/style_return", "2")
        print('something went terribly wrong. go check the code NOW')

    

# function for handling take photo
def run_take_photo(message_id, participant_id):
    print(message_id,"OSC ID")
    print("participant_id -> ", participant_id)
    print('photo taken and face obtained!')
    client.send_message("/photo_return", "0")
    process_out = os.popen('python take_photo_demo.py ' + str(participant_id)).read()
    # check that the last character (actually, last two to be sure) is the exit status 0
    if int(process_out[-2:]) == 0:
        client.send_message("/photo_return", "0")
        print('photo taken and face obtained!')
    elif int(process_out[-2:]) == 1:
        client.send_message("/photo_return", "1")
        print('something went wrong with the camera')
    elif int(process_out[-2:]) == 2:
        client.send_message("/photo_return", "2")
        print('something went terribly wrong. go check the code NOW')
    else:
        client.send_message("/photo_return", "3")
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
    #dispatcher.map("/spotify",sendvalues)
    dispatcher.map("/style",run_style_transfer)
    dispatcher.map("/photo",run_take_photo)
    dispatcher.map("/ping",pingpong)

    
    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()