# Define the path to the Python script to run (ensure this path is correct)
$pythonScriptPath = "C:\path\to\your\import_subprocess.pyw"

# Verify if the Python script exists
if (-not (Test-Path $pythonScriptPath)) {
    Write-Host "Python script not found at path: $pythonScriptPath"
    exit 1
}

# Create a scheduled task named "MicCheck"
Write-Host "Creating scheduled task 'MicCheck'..."
$taskName = "MicCheck"
$taskDescription = "Runs the import_subprocess.pyw script on workstation unlock."
$taskAction = "`"$pythonScriptPath`""

# Remove the task if it already exists
schtasks /delete /tn $taskName /f 2>$null

# Create the task using schtasks with a trigger on unlock
schtasks /create /tn $taskName /tr $taskAction /sc onlogon /delay 0005:00 /f /rl HIGHEST /it

if ($?) {
    Write-Host "Scheduled task 'MicCheck' created successfully!"
} else {
    Write-Host "Failed to create the scheduled task 'MicCheck'."
}

Write-Host "Done."
