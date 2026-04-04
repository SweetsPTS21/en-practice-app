Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir ".."))
$sourceIconPath = Join-Path $repoRoot "assets/branding/app_logo.png"

if (-not (Test-Path -LiteralPath $sourceIconPath)) {
    throw "Source icon was not found at: $sourceIconPath"
}

function New-ResizedBitmap {
    param(
        [System.Drawing.Image]$SourceImage,
        [int]$Size
    )

    $bitmap = [System.Drawing.Bitmap]::new(
        $Size,
        $Size,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $cropSize = [Math]::Min($SourceImage.Width, $SourceImage.Height)
    $cropX = [int](($SourceImage.Width - $cropSize) / 2)
    $cropY = [int](($SourceImage.Height - $cropSize) / 2)

    $graphics.DrawImage(
        $SourceImage,
        [System.Drawing.Rectangle]::new(0, 0, $Size, $Size),
        [System.Drawing.Rectangle]::new($cropX, $cropY, $cropSize, $cropSize),
        [System.Drawing.GraphicsUnit]::Pixel
    )

    $graphics.Dispose()
    return $bitmap
}

function Save-Png {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Save-Ico {
    param(
        [hashtable[]]$Entries,
        [string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $pngEntries = @()
    try {
        foreach ($entry in $Entries) {
            $stream = [System.IO.MemoryStream]::new()
            $entry.Bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            $pngEntries += [pscustomobject]@{
                Size = [int]$entry.Size
                Data = $stream.ToArray()
            }
            $stream.Dispose()
        }

        $file = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        try {
            $writer = [System.IO.BinaryWriter]::new($file)
            $writer.Write([UInt16]0)
            $writer.Write([UInt16]1)
            $writer.Write([UInt16]$pngEntries.Count)

            $offset = 6 + (16 * $pngEntries.Count)
            foreach ($entry in $pngEntries) {
                $dimensionByte = if ($entry.Size -ge 256) { [byte]0 } else { [byte]$entry.Size }
                $writer.Write($dimensionByte)
                $writer.Write($dimensionByte)
                $writer.Write([byte]0)
                $writer.Write([byte]0)
                $writer.Write([UInt16]1)
                $writer.Write([UInt16]32)
                $writer.Write([UInt32]$entry.Data.Length)
                $writer.Write([UInt32]$offset)
                $offset += $entry.Data.Length
            }

            foreach ($entry in $pngEntries) {
                $writer.Write($entry.Data)
            }

            $writer.Flush()
            $writer.Dispose()
        } finally {
            $file.Dispose()
        }
    } finally {
        foreach ($entry in $Entries) {
            $entry.Bitmap.Dispose()
        }
    }
}

$pngTargets = @(
    @{ Size = 48; Path = "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" },
    @{ Size = 72; Path = "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" },
    @{ Size = 96; Path = "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" },
    @{ Size = 144; Path = "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" },
    @{ Size = 192; Path = "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" },
    @{ Size = 20; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png" },
    @{ Size = 40; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png" },
    @{ Size = 60; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png" },
    @{ Size = 29; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png" },
    @{ Size = 58; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png" },
    @{ Size = 87; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png" },
    @{ Size = 40; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png" },
    @{ Size = 80; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png" },
    @{ Size = 120; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png" },
    @{ Size = 120; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png" },
    @{ Size = 180; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png" },
    @{ Size = 76; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png" },
    @{ Size = 152; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png" },
    @{ Size = 167; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png" },
    @{ Size = 1024; Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" },
    @{ Size = 16; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png" },
    @{ Size = 32; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png" },
    @{ Size = 64; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png" },
    @{ Size = 128; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png" },
    @{ Size = 256; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png" },
    @{ Size = 512; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png" },
    @{ Size = 1024; Path = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png" },
    @{ Size = 32; Path = "web/favicon.png" },
    @{ Size = 192; Path = "web/icons/Icon-192.png" },
    @{ Size = 512; Path = "web/icons/Icon-512.png" },
    @{ Size = 192; Path = "web/icons/Icon-maskable-192.png" },
    @{ Size = 512; Path = "web/icons/Icon-maskable-512.png" }
)

$sourceImage = [System.Drawing.Image]::FromFile($sourceIconPath)
try {
    foreach ($target in $pngTargets) {
        $bitmap = New-ResizedBitmap -SourceImage $sourceImage -Size $target.Size
        Save-Png -Bitmap $bitmap -Path (Join-Path $repoRoot $target.Path)
        $bitmap.Dispose()
    }

    $icoEntries = @(
        @{ Size = 16; Bitmap = (New-ResizedBitmap -SourceImage $sourceImage -Size 16) },
        @{ Size = 32; Bitmap = (New-ResizedBitmap -SourceImage $sourceImage -Size 32) },
        @{ Size = 48; Bitmap = (New-ResizedBitmap -SourceImage $sourceImage -Size 48) },
        @{ Size = 64; Bitmap = (New-ResizedBitmap -SourceImage $sourceImage -Size 64) },
        @{ Size = 128; Bitmap = (New-ResizedBitmap -SourceImage $sourceImage -Size 128) },
        @{ Size = 256; Bitmap = (New-ResizedBitmap -SourceImage $sourceImage -Size 256) }
    )
    Save-Ico -Entries $icoEntries -Path (Join-Path $repoRoot "windows/runner/resources/app_icon.ico")
} finally {
    $sourceImage.Dispose()
}
