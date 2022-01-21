import argparse
import random
import time

from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

client = udp_client.SimpleUDPClient("127.0.0.1", 1234)

# The function now has 4 parameters as it receives messageID and the messages (here 3) that are included.
def sendvalues(unused_addr, message1, message2, message3):
# format is used to format the numbers for string values instead of objects:
    print(unused_addr,"OSC ID")
    print(message1,"first message")
    print(message2,"second message")
    print(message3,"third message")

    for x in range(10):
        client.send_message("/mousepressed", "{}".format(random.random()))
        time.sleep(1)
        if x == 9:
            break

def sendothervalues(unused_addr, message1):

    print(unused_addr,"OSC ID")
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
    dispatcher.map("/miklo",sendvalues)
    dispatcher.map("/miklokey",sendothervalues)

    
    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()