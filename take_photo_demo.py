#!/usr/bin/env python
# coding: utf-8

# <a href="https://colab.research.google.com/github/ElisaCastelli/CPAC_CollectiveDynamicPortrait/blob/main/CPACprovaFaceDetect.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>

# In[6]:


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


# In[7]:


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
  filename = take_photo('photo.jpg')
  print('Saved to {}'.format(filename))
  # Show the image which was just taken.
  display(Image(filename))
  #display(Image(filename2))
 
except Exception as err:
  # Errors will be thrown if the user does not have a webcam or if they do not
  # grant the page permission to access it.
  print(str(err))


# In[9]:


print("exit status (checking if everything went fine):")
if os.path.exists(filename):
    print(0)
else:
    print(1)

