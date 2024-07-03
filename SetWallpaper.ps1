# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to select an image file using a Windows file dialog
function Select-ImageFile {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp"
    $dialog.Title = "Select an image file"
    $dialog.ShowDialog() | Out-Null
    return $dialog.FileName
}

# Function to generate the PowerShell script to change the wallpaper
function Generate-ChangeWallpaperScript {
    $OutputDirectory = "C:\temp\WallpaperSetter"
    $OutputFile = "change_wallpaper.ps1"

    # Ensure the output directory exists
    if (-not (Test-Path -Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force
    }

    $scriptContent = @"
# Change the wallpaper
Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    public static void Set(string filePath) {
        SystemParametersInfo(0x0014, 0, filePath, 0x0001 | 0x0002);
    }
}
'
[Wallpaper]::Set("C:\temp\WallpaperSetter\wallpaper.jpg")
"@

    $ps1ScriptPath = [System.IO.Path]::Combine($OutputDirectory, $OutputFile)
    Set-Content -Path $ps1ScriptPath -Value $scriptContent -Force
    return $ps1ScriptPath
}

# Function to generate the .bat file to run the PowerShell script on startup
function Generate-RunOnStartupBatFile {
    param(
        [string] $OutputFile = "run_ps1_on_startup.bat"
    )

    $Ps1ScriptPath = "C:\temp\WallpaperSetter\change_wallpaper.ps1"

    $batContent = @"
@echo off
powershell.exe -ExecutionPolicy Bypass -File "$Ps1ScriptPath"
"@

    $startupFolder = [System.Environment]::GetFolderPath('Startup')
    $batPath = [System.IO.Path]::Combine($startupFolder, $OutputFile)
    Set-Content -Path $batPath -Value $batContent -Force
    return $batPath
}

# Function to uninstall/delete the generated files
function Uninstall-StartupFiles {
    $outputDirectory = "C:\temp\WallpaperSetter"
    $ps1FilePath = [System.IO.Path]::Combine($outputDirectory, "change_wallpaper.ps1")
    $batFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Startup'), "run_ps1_on_startup.bat")
    $wallpaperFilePath = [System.IO.Path]::Combine($outputDirectory, "wallpaper.jpg")

    if (Test-Path $ps1FilePath) {
        Remove-Item $ps1FilePath -Force
        [System.Windows.Forms.MessageBox]::Show("Deleted '$ps1FilePath'")
    }

    if (Test-Path $batFilePath) {
        Remove-Item $batFilePath -Force
        [System.Windows.Forms.MessageBox]::Show("Deleted '$batFilePath'")
    }

    if (Test-Path $wallpaperFilePath) {
        Remove-Item $wallpaperFilePath -Force
        [System.Windows.Forms.MessageBox]::Show("Deleted '$wallpaperFilePath'")
    }

    if (Test-Path $outputDirectory) {
        Remove-Item $outputDirectory -Force -Recurse
        [System.Windows.Forms.MessageBox]::Show("Deleted '$outputDirectory'")
    }

    [System.Windows.Forms.MessageBox]::Show("Uninstallation complete.")
}

# Function to install the wallpaper changer
function Install-WallpaperChanger {
    $selectedImagePath = Select-ImageFile

    if ([string]::IsNullOrWhiteSpace($selectedImagePath)) {
        [System.Windows.Forms.MessageBox]::Show("No file selected. Exiting.")
        return
    }

    Write-Output "Selected picture path: $selectedImagePath"

    # Define the output directory and file paths
    $outputDirectory = "C:\temp\WallpaperSetter"
    $destinationImagePath = "C:\temp\WallpaperSetter\wallpaper.jpg"
    $ps1ScriptPath = "C:\temp\WallpaperSetter\change_wallpaper.ps1"

    # Ensure the output directory exists
    if (-not (Test-Path -Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory -Force
    }

    # Copy the selected image to the output directory with a fixed name
    Copy-Item -Path $selectedImagePath -Destination $destinationImagePath -Force
    Write-Output "Copied image to: $destinationImagePath"

    # Generate PowerShell script to change the wallpaper
    $ps1ScriptPath = Generate-ChangeWallpaperScript
    Write-Output "Generated PowerShell script: $ps1ScriptPath"

    # Run the PowerShell script immediately to change the wallpaper
    Write-Output "Running PowerShell script to change the wallpaper"
    powershell.exe -ExecutionPolicy Bypass -File $ps1ScriptPath

    # Generate .bat file to run PowerShell script on startup
    $batScriptPath = Generate-RunOnStartupBatFile
    Write-Output "Generated .bat file for startup: $batScriptPath"

    [System.Windows.Forms.MessageBox]::Show("Wallpaper changer installed. Script path: $ps1ScriptPath`nBatch file path: $batScriptPath")
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Wallpaper Changer"
$form.Size = New-Object System.Drawing.Size(300, 150)
$form.StartPosition = "CenterScreen"

# Create the Install button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install"
$installButton.Size = New-Object System.Drawing.Size(100, 30)
$installButton.Location = New-Object System.Drawing.Point(30, 50)
$installButton.Add_Click({ Install-WallpaperChanger })
$form.Controls.Add($installButton)

# Create the Uninstall button
$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Text = "Uninstall"
$uninstallButton.Size = New-Object System.Drawing.Size(100, 30)
$uninstallButton.Location = New-Object System.Drawing.Point(150, 50)
$uninstallButton.Add_Click({ Uninstall-StartupFiles })
$form.Controls.Add($uninstallButton)

# Show the form
[void] $form.ShowDialog()
