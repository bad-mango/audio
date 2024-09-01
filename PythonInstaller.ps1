# Function to check if Python is installed
function Check-Python {
    $pythonVersion = try {
        python --version 2>&1
    } catch {
        $null
    }

    if ($pythonVersion) {
        Write-Host "Python is already installed. Version: $pythonVersion"
        return $true
    } else {
        Write-Host "Python is not installed."
        return $false
    }
}

# Check if Python is already installed
if (-not (Check-Python)) {
    # Define the URL to the Python installer (change version number as needed)
    $pythonInstallerUrl = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"

    # Define the path to save the installer
    $installerPath = "$env:TEMP\python-installer.exe"

    # Download the installer
    Write-Host "Downloading Python installer..."
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $installerPath

    # Define the installation arguments
    $installArgs = "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 SimpleInstall=1"

    # Run the installer
    Write-Host "Installing Python..."
    Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait

    # Clean up the installer file
    Write-Host "Cleaning up..."
    Remove-Item $installerPath

    # Verify installation
    Write-Host "Verifying Python installation..."
    python --version
    if ($?) {
        Write-Host "Python was installed successfully!"
    } else {
        Write-Host "Python installation failed."
        exit 1
    }
} else {
    Write-Host "Skipping Python installation as it is already installed."
}
