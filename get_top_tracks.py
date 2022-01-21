import requests

import argparse
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

client = udp_client.SimpleUDPClient("127.0.0.1", 4321)


class GetUserTopTracks:
    def __init__(self):
        self.spotify_token = "BQApH5N_52oxSm-_LpvRXWFB1oOqphpqciK5z-DrSjHet2WLm3Az98KXC20bQtv29zVIPki6TogH2OKnEmyHQWZlR5SL9DY1o__cgUlJ7CVLAFsPwZBT3NR4YfxFQg0nJ3FIVL0KgVCyw1xrx82Hs6WEMoQ5ALTSQCadh_MOOsRgDSPXF6R_7zSDUSfYXX51VKc-jYftVEnsclsEdotb3KKCp1Tu_c8-nlcLirf5C5A"
    
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

def getParams():
    return 123


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