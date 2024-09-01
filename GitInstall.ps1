# Set up the temporary directory for the installation files
$tempDir = [System.IO.Path]::Combine($env:TEMP, "GitSetup")
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

# Function to check if Git is installed
function Check-Git {
    try {
        $gitVersion = & git --version
        if ($gitVersion) {
            Write-Host "Git is already installed. Version: $gitVersion"
            return $true
        }
    }
    catch {
        Write-Host "Git is not installed."
        return $false
    }
}

# Function to install Git
function Install-Git {
    $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe"
    $installerPath = [System.IO.Path]::Combine($tempDir, "GitInstaller.exe")

    # Download the Git installer
    Download-File -url $gitInstallerUrl -outputPath $installerPath

    # Run the installer
    Write-Host "Installing Git..."
    Start-Process -FilePath $installerPath -ArgumentList "/SILENT" -Wait

    Write-Host "Git installation completed."
}

# Check if Git is installed and install it if necessary
if (-not (Check-Git)) {
    Install-Git
}

# Recheck if Git is available in the current session
if (-not (Check-Git)) {
    Write-Host "The Git installation was not recognized. Please restart PowerShell and try again."
    exit
} else {
    Write-Host "Git is ready to use."
}
