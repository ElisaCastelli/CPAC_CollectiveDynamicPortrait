import argparse
import random
import time

from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

client = udp_client.SimpleUDPClient("127.0.0.1", 1234)

def sendvalues(unused_addr):
    msg = getParams()
  
    client.send_message("/mousepressed", "{}".format(msg))

def getParams():
    return 123

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=5005,
        help="The port the OSC server is listening on")
    args = parser.parse_args()

    dispatcher = dispatcher.Dispatcher()

    dispatcher.map("/miklo",sendvalues)

    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()