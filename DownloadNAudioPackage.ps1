# DownloadNAudioPackage.ps1

# Set up the temporary directory
$tempDir = [System.IO.Path]::Combine($env:TEMP, "NuGetPackages")
if (-not (Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory
}

# Function to download NuGet packages using correct URL
function Download-NuGetPackage {
    param (
        [string]$packageName,
        [string]$outputDir
    )
    
    # Fetch package details from NuGet API v3
    $nugetPackageUrl = "https://api.nuget.org/v3-flatcontainer/$packageName/index.json"
    
    try {
        $packageDetails = Invoke-RestMethod -Uri $nugetPackageUrl
        $latestVersion = $packageDetails.versions[-1]
        $downloadUrl = "https://api.nuget.org/v3-flatcontainer/$packageName/$latestVersion/$packageName.$latestVersion.nupkg"
        $outputFile = [System.IO.Path]::Combine($outputDir, "$packageName.nupkg")
        
        Write-Host "Downloading $packageName version $latestVersion..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile
        
        Write-Host "$packageName downloaded to $outputFile"
    }
    catch {
        Write-Host "Failed to download $packageName. Error: $_"
    }
}

# Download NAudio package
Download-NuGetPackage -packageName "naudio" -outputDir $tempDir

Write-Host "NAudio package downloaded successfully."
