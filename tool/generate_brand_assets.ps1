$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = Split-Path $PSScriptRoot -Parent
$sourcePath = Join-Path $repo 'assets\logo\810d3772-6ef2-40c3-af89-e8b40db5c186.png'
$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
# Deterministic packaging of the founder's original artwork: crop / resize only.
# The symbol and horizontal wordmark are separate outputs; originals stay intact.
function Export-Asset($Rect, [int]$Width, [int]$Height, $Destination, [bool]$Background = $false, [int]$Inset = 0) {
    $image = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($image)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        if ($Background) { $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#F5F6F8')) }
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($source, [System.Drawing.Rectangle]::new($Inset, $Inset, $Width - 2*$Inset, $Height - 2*$Inset), $Rect, [System.Drawing.GraphicsUnit]::Pixel)
        $directory = Split-Path $Destination -Parent
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        $image.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $image.Dispose() }
}
try {
    $wordmark = [System.Drawing.Rectangle]::new(82, 282, 1507, 402)
    $symbol = [System.Drawing.Rectangle]::new(82, 282, 410, 402)
    Export-Asset $wordmark 1507 402 (Join-Path $repo 'assets\brand\hadgaly-wordmark.png')
    foreach ($size in @(@('mdpi',48),@('hdpi',72),@('xhdpi',96),@('xxhdpi',144),@('xxxhdpi',192))) {
        Export-Asset $symbol $size[1] $size[1] (Join-Path $repo "android\app\src\main\res\mipmap-$($size[0])\ic_launcher.png") $true ([int]($size[1]*0.08))
    }
    # Adaptive icon foreground: 66dp artwork in Android's 108dp safe canvas.
    Export-Asset $symbol 432 432 (Join-Path $repo 'android\app\src\main\res\drawable-xxxhdpi\ic_hadgaly_foreground.png') $false 84
} finally { $source.Dispose() }
