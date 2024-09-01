# DownloadNuGetCLI.ps1

# Set up the temporary directory
$tempDir = [System.IO.Path]::Combine($env:TEMP, "NuGetSetup")
if (-not (Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory
}

# Function to download a file from a URL
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )
    
    Write-Host "Downloading from $url..."
    Invoke-WebRequest -Uri $url -OutFile $outputPath
    Write-Host "Downloaded to $outputPath"
}

# Download NuGet CLI (nuget.exe)
$nugetExeUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$nugetExePath = [System.IO.Path]::Combine($tempDir, "nuget.exe")
Download-File -url $nugetExeUrl -outputPath $nugetExePath

Write-Host "NuGet CLI downloaded successfully."
