# CreateAndRunAudioRecorder.ps1

# Set up the temporary directory for the project
$tempDir = [System.IO.Path]::Combine($env:TEMP, "AudioRecorderSetup")
if (-not (Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory
}

# Create a new .NET console project
$projectDir = [System.IO.Path]::Combine($tempDir, "AudioRecorder")
if (-not (Test-Path -Path $projectDir)) {
    dotnet new console -o $projectDir
}

# Add NAudio package to the project
dotnet add $projectDir package NAudio

# Write the C# code for recording audio
$programCode = @"
using System;
using NAudio.Wave;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine(\"Press any key to start recording...\");
        Console.ReadKey();

        using (var waveIn = new WaveInEvent())
        using (var writer = new WaveFileWriter(\"recordedAudio.wav\", waveIn.WaveFormat))
        {
            waveIn.DataAvailable += (s, a) =>
            {
                writer.Write(a.Buffer, 0, a.BytesRecorded);
            };

            waveIn.StartRecording();
            Console.WriteLine(\"Recording... Press any key to stop.\");
            Console.ReadKey();
            waveIn.StopRecording();
        }

        Console.WriteLine(\"Recording stopped. Audio saved to 'recordedAudio.wav'.\");
    }
}
"@

$programPath = [System.IO.Path]::Combine($projectDir, "Program.cs")
Set-Content -Path $programPath -Value $programCode

# Build the project
dotnet build $projectDir

# Run the project to start recording
dotnet run --project $projectDir
