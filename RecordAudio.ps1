# Define paths
$tempDir = [System.IO.Path]::GetTempPath()
$naudioDir = Join-Path $tempDir "Naudio"
$ffmpegZipUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
$ffmpegZipPath = Join-Path $naudioDir "ffmpeg.zip"
$ffmpegExtractPath = Join-Path $naudioDir "ffmpeg"
$ffmpegExePath = Join-Path $ffmpegExtractPath "ffmpeg-*-essentials_build/bin/ffmpeg.exe"

# Create Naudio directory if it doesn't exist
if (-not (Test-Path $naudioDir)) {
    New-Item -ItemType Directory -Path $naudioDir | Out-Null
}

# Download FFmpeg if not already downloaded
if (-not (Test-Path $ffmpegExePath)) {
    Write-Host "Downloading FFmpeg..."
    Invoke-WebRequest -Uri $ffmpegZipUrl -OutFile $ffmpegZipPath

    Write-Host "Extracting FFmpeg..."
    Expand-Archive -Path $ffmpegZipPath -DestinationPath $ffmpegExtractPath -Force

    # Clean up downloaded zip file
    Remove-Item $ffmpegZipPath -Force
}

# Add FFmpeg to PATH temporarily for this session
$env:Path += ";$($ffmpegExePath | Split-Path -Parent)"

# Define the output file path
$outputFile = "C:\Path\To\Output\audio_$(Get-Date -Format 'yyyyMMdd_HHmmss').wav"

# Record audio using FFmpeg (adjust the device name as needed)
Write-Host "Starting audio recording for 10 seconds..."
Start-Process -NoNewWindow -Wait -FilePath (Get-Command ffmpeg).Source -ArgumentList "-f dshow -i audio=""Microphone (Realtek High Definition Audio)"" -t 10 -acodec pcm_s16le $outputFile"

# Check if recording was successful
if (Test-Path $outputFile) {
    Write-Host "Recording completed successfully."
    Write-Host "Recording saved to: $outputFile"
} else {
    Write-Host "Recording failed."
}

# Pause to keep the PowerShell window open
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
