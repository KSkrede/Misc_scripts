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
    param(
        [string] $WallpaperPath,
        [string] $OutputFile = "change_wallpaper.ps1"
    )

    # Escape backslashes and double-quote the path
    $escapedWallpaperPath = $WallpaperPath -replace '\\', '\\\\'

    $scriptContent = @"
# Path to the new wallpaper (input as a string)
\$wallpaperPath = "$escapedWallpaperPath"

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
[Wallpaper]::Set(\$wallpaperPath)
"@

    $startupFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Startup'), $OutputFile)
    Set-Content -Path $startupFolder -Value $scriptContent -Force
    return $startupFolder
}

# Function to generate the .bat file to run the PowerShell script on startup
function Generate-RunOnStartupBatFile {
    param(
        [string] $Ps1ScriptPath,
        [string] $OutputFile = "run_ps1_on_startup.bat"
    )

    $batContent = @"
@echo off
powershell.exe -ExecutionPolicy Bypass -File "$Ps1ScriptPath"
"@

    $batPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Startup'), $OutputFile)
    Set-Content -Path $batPath -Value $batContent -Force
    return $batPath
}

# Function to uninstall/delete the generated files from the startup folder
function Uninstall-StartupFiles {
    $startupFolder = [System.Environment]::GetFolderPath('Startup')
    $ps1FilePath = [System.IO.Path]::Combine($startupFolder, "change_wallpaper.ps1")
    $batFilePath = [System.IO.Path]::Combine($startupFolder, "run_ps1_on_startup.bat")

    if (Test-Path $ps1FilePath) {
        Remove-Item $ps1FilePath -Force
        [System.Windows.Forms.MessageBox]::Show("Deleted '$ps1FilePath'")
    }

    if (Test-Path $batFilePath) {
        Remove-Item $batFilePath -Force
        [System.Windows.Forms.MessageBox]::Show("Deleted '$batFilePath'")
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

    # Generate PowerShell script to change the wallpaper
    $ps1ScriptPath = Generate-ChangeWallpaperScript -WallpaperPath $selectedImagePath
    Write-Output "Generated PowerShell script: $ps1ScriptPath"

    # Generate .bat file to run PowerShell script on startup
    $batScriptPath = Generate-RunOnStartupBatFile -Ps1ScriptPath $ps1ScriptPath
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
