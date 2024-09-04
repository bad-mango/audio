@echo off
setlocal

:: Define the correct download URL and paths
set ffmpegUrl=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z
set tempPath=%TEMP%
set downloadPath=%tempPath%\ffmpeg-git-full.7z
set extractPath=%tempPath%\ffmpeg

:: Download the FFmpeg archive using bitsadmin
echo Downloading FFmpeg from %ffmpegUrl%...
bitsadmin /transfer "FFmpegDownload" /download /priority high %ffmpegUrl% %downloadPath%

:: Check if the download was successful
if not exist "%downloadPath%" (
    echo Download failed. Please check the URL and try again.
    exit /b 1
)

echo Download complete. Extracting the archive...

:: Create the extraction directory
if not exist "%extractPath%" (
    mkdir "%extractPath%"
)

:: Extract the archive using tar (Windows 10+)
tar -xf "%downloadPath%" -C "%extractPath%"

:: Check if the extraction was successful
if not exist "%extractPath%\bin\ffmpeg.exe" (
    echo Extraction failed. Please check the archive and try again.
    exit /b 1
)

echo FFmpeg extraction complete. FFmpeg is ready to use in the TEMP directory at %extractPath%.

:: Optional: Add FFmpeg to PATH for the current session
set PATH=%extractPath%\bin;%PATH%

echo You can now use FFmpeg by typing "ffmpeg" in the command prompt.

endlocal
pause
