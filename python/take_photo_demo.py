# import dependencies
#from IPython.display import display, Javascript, Image
from base64 import b64decode, b64encode
import cv2
import numpy as np
import os
import sys


# IMPORTANT
# load cv2.CascadeClassifier
# I needed to specify the full path to the xml file, modify according to your pc
face_cascade = cv2.CascadeClassifier('C:\\Users\\franc\\anaconda3\\envs\\tf-gpu\\Lib\\site-packages\\cv2\\data\\haarcascade_frontalface_alt2.xml')
print("Entra in take_photo_demo")
#face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")


# path where images are stored
image_folder = '../pictures/'
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

# sometimes no face is detected, so we make the program try again, 
face_found = False
max_attempts = 5

while face_found == False:
  # taking photo

  try:
    filename = take_photo(image_folder + file_id + '.jpg')
    print('Saved to {}'.format(filename))
    # Show the image which was just taken.
    # display(Image(filename))
    # display(Image(filename2))

    print("exit status (checking if everything went fine):")
    if os.path.exists(filename):
        print(0)
    else:
        print(1)
        sys.exit()
  
  except Exception as err:
    # Errors will be thrown if the user does not have a webcam or if they do not
    # grant the page permission to access it.
    print(str(err))
    print(2)
    sys.exit()


  # face detect
    
  # Read the input image
  img = cv2.imread(filename)
    
  # Convert into grayscale
  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
  # Detect faces
  faces = face_cascade.detectMultiScale(gray, 1.1, 4)

  for (x, y, w, h) in faces:
      #cv2.rectangle(img, (x, y), (x+w, y+h), 
       #             (0, 0, 255), 2)

      # increase area around face before cropping
      x_padding = int(w*0.1)
      y_padding = int(h*0.1)
      max_height = img.shape[0]
      max_width = img.shape[1]
      # if increasing is impossible while maintaining height == width, don't increase
      if y - y_padding < 0 or y + h + y_padding > max_height or x - x_padding < 0 or x + w + x_padding > max_width:
        x_padding = 0
        y_padding = 0

      faces = img[y - y_padding:y + h + y_padding, x - x_padding:x + w + x_padding]
      #cv2.imshow("face",faces)
      cv2.imwrite(image_folder + file_id + '_face.jpg', faces)

      # update flag
      face_found = True

      # just take the first face
      break
  
  if face_found:
    print(0)
  else:
    --max_attempts

  if max_attempts <= 0:
    break

if not face_found:
  print(3)

#cv2.imshow('img', img)
#cv2.waitKey()