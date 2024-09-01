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

# Define the path to the Python script to run (change this to the correct path)
$pythonScriptPath = "C:\path\to\your\import_subprocess.pyw"

# Create a scheduled task named "MicCheck"
Write-Host "Creating scheduled task 'MicCheck'..."
$taskName = "MicCheck"
$taskDescription = "Runs the import_subprocess.pyw script on workstation unlock."
$trigger = "on workstation unlock"
$repeatInterval = "5 minutes"
$taskCommand = "schtasks /create /tn $taskName /tr `"$pythonScriptPath`" /sc onlogon /du infinite /ri 5 /f /ru SYSTEM /rl HIGHEST /it"

# Create the task using schtasks
schtasks /create /tn $taskName /tr "`"$pythonScriptPath`"" /sc unlock /du infinite /ri 5 /f /ru SYSTEM /rl HIGHEST /it

if ($?) {
    Write-Host "Scheduled task 'MicCheck' created successfully!"
} else {
    Write-Host "Failed to create the scheduled task 'MicCheck'."
}

Write-Host "Done."
