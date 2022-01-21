import subprocess
import os

def setup():
    size(800, 1000)
    background(235,235,235)
    frameRate(30)

def draw():
    fill(255)
    rect(80, 80, 640, 840)
  
def keyPressed():
    subprocess.run('%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe')
    fill(100)
    rect(180, 180, 540, 540)
    
    
