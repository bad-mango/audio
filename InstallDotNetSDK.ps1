# InstallDotNetSDK.ps1

# Set up the temporary directory
$tempDir = [System.IO.Path]::Combine($env:TEMP, "DotNetSDKSetup")
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

# Function to check if .NET SDK is installed
function Check-DotNetSDK {
    try {
        $dotnetVersion = & dotnet --version
        if ($dotnetVersion) {
            Write-Host ".NET SDK is already installed. Version: $dotnetVersion"
            return $true
        }
    }
    catch {
        Write-Host ".NET SDK is not installed."
        return $false
    }
}

# Function to install .NET SDK using the downloaded installer
function Install-DotNetSDK {
    $dotnetInstallerUrl = "https://aka.ms/dotnet/download"
    $installerPath = [System.IO.Path]::Combine($tempDir, "dotnet-sdk-installer.exe")

    # Download the .NET SDK installer executable
    Download-File -url $dotnetInstallerUrl -outputPath $installerPath
    
    # Run the installer
    Write-Host "Installing .NET SDK..."
    Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait
    
    # Ensure .NET SDK is available in the PATH for the current session
    $dotnetInstallDir = [System.IO.Path]::Combine($env:USERPROFILE, ".dotnet")
    $env:PATH += ";$dotnetInstallDir"
    [System.Environment]::SetEnvironmentVariable("PATH", $env:PATH, [System.EnvironmentVariableTarget]::Process)
}

# Check if .NET SDK is installed and install it if necessary
if (-not (Check-DotNetSDK)) {
    Install-DotNetSDK
}

# Recheck if .NET SDK is available in the current session
if (-not (Check-DotNetSDK)) {
    Write-Host "The .NET SDK installation was not recognized. Please restart PowerShell and try again."
    exit
} else {
    Write-Host ".NET SDK installation completed successfully."
}
