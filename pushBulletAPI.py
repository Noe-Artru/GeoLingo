from pushbullet import Pushbullet

API_KEY = ""  # Replace with your actual API key

pb = Pushbullet(API_KEY)

device = pb.devices[0] 
message = "Cafe"
push = device.push_note("TTS Trigger", message)
