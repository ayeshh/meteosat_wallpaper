# Define the URL of the image
$url = "https://api.met.no/weatherapi/geosatellite/1.4/?area=global&type=infrared"

# Define the path where the image will be saved
$outputPath = [Environment]::GetFolderPath("MyPictures") + "\EUMETSAT_Image.jpg"

# Create the folder My Pictures if it doesn't exist
if (!(Test-Path -Path (Split-Path $outputPath))) {
    New-Item -ItemType Directory -Path (Split-Path $outputPath)
}

# Use Invoke-WebRequest to download the image
Invoke-WebRequest -Uri $url -OutFile $outputPath

# Output a message indicating the download is complete
Write-Host "Download complete: $outputPath"

# Check if the file exists
if (Test-Path $outputPath) {
    # Set the wallpaper using the SystemParametersInfo function
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

    # Constants for the SystemParametersInfo function
    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDCHANGE = 0x02

    # Set the wallpaper
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $outputPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

    # Set wallpaper style (fit in this case)
    Set-ItemProperty -path "HKCU:Control Panel\Desktop" -name WallpaperStyle -value 6
    Set-ItemProperty -path "HKCU:Control Panel\Desktop" -name TileWallpaper -value 0

    # Output a message indicating the wallpaper has been set
    Write-Host "Wallpaper set to: $outputPath"
} else {
    Write-Host "Image file not found: $outputPath"
}
