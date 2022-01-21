import os

acousticness = 1
valence = 1
content_image = "dummy_cropped.jpg"

print(os.popen('python style_transfer_demo.py ' + str(acousticness) + ' ' + str(valence) + ' ' + content_image).read())