import argparse
import random
import time
import os

from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

client = udp_client.SimpleUDPClient("127.0.0.1", 1234)

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
        client.send_message("/mousepressed", "ciaoo")
        print('style transfer completed!')
    elif int(process_out[-2:]) == 1:
        client.send_message("/mousepressed", "1")
        print('something went wrong during style transfer: missing stylized picture')

    else:
        client.send_message("/mousepressed", "2")
        print('something went terribly wrong. go check the code NOW')

    

# for now useless
def other_receiver(message_id, message1):
    print(message_id,"OSC ID")
    print(message1,"first message")
    client.send_message("/keypressed", "vuf")

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
    dispatcher.map("/style",run_style_transfer)
    dispatcher.map("/other",other_receiver)

    
    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()