# Path to the new wallpaper
$wallpaperPath = "C:\Path\To\Your\Wallpaper.jpg"

# Change the wallpaper
$code = @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper
{
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    public static void Set(string filePath)
    {
        SystemParametersInfo(0x0014, 0, filePath, 0x0001 | 0x0002);
    }
}
"@

Add-Type -TypeDefinition $code -Language CSharp
[Wallpaper]::Set($wallpaperPath)
