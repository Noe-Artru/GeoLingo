from gtts import gTTS
import pygame
from pushbullet import Pushbullet
import time

# Put this code on your (Android) phone, and run it using an app like Pydroid 3
# Don't forget to install the gtts, pygame and pushbullet.py libraries
API_KEY = ""  # Replace with your Pushbullet API Key
pb = Pushbullet(API_KEY)

def text_to_speech(text = "No message given"):
    tts = gTTS(text=text, lang='en')
    tts.save("output.mp3")  
    pygame.mixer.init()  
    pygame.mixer.music.load("output.mp3")  
    pygame.mixer.music.play() 
    while pygame.mixer.music.get_busy():  
        continue
    pygame.mixer.quit() 

def check_pushes():
    print("Listening for Pushbullet notifications...")
    if len(pb.get_pushes()):
        latest_push = pb.get_pushes()[0]["iden"]  # ID of latest push notification
    else:
        latest_push = None

    while True: # Loop to check for new pushes
        pushes = pb.get_pushes()
        if pushes:
            push = pushes[0]
            if push["iden"] != latest_push and "body" in push: # New push and the push it text
                text = push["body"] 
                print(f"New Push Received: {text}")
                text_to_speech(text)  
                latest_push = push["iden"] 

        time.sleep(5)  # Poll every 5 seconds to avoid hitting API limits

if __name__ == "__main__":
    check_pushes()
