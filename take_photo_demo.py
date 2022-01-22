# import dependencies
from IPython.display import display, Javascript, Image
from base64 import b64decode, b64encode
import cv2
import numpy as np
import PIL
import io
import html
import time
import os
import sys

# path where images are stored
image_folder = 'style_pics/'
file_id = sys.argv[1]

def take_photo(filename='photo.jpg', quality=0.8):
  video_capture = cv2.VideoCapture(0)
  # Check success
  if not video_capture.isOpened():
    raise Exception("Could not open video device")
  # Read picture. ret === True on success
  ret, img = video_capture.read()
  # Close device
  video_capture.release()
  cv2.imwrite(filename, img)
  return filename


# In[8]:

try:
  filename = take_photo(image_folder + file_id + '.jpg')
  print('Saved to {}'.format(filename))
  # Show the image which was just taken.
  display(Image(filename))
  #display(Image(filename2))

  print("exit status (checking if everything went fine):")
  if os.path.exists(filename):
      print(0)
  else:
      print(1)
 
except Exception as err:
  # Errors will be thrown if the user does not have a webcam or if they do not
  # grant the page permission to access it.
  print(str(err))
  print(2)





