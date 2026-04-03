Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir ".."))

function New-RoundedRectanglePath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [float]$Radius
    )

    $diameter = $Radius * 2
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-IconBitmap {
    param([int]$Size)

    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $primary = [System.Drawing.ColorTranslator]::FromHtml("#0F2747")
    $primaryStrong = [System.Drawing.ColorTranslator]::FromHtml("#1D5E9B")
    $highlight = [System.Drawing.ColorTranslator]::FromHtml("#7BC8FF")
    $accent = [System.Drawing.ColorTranslator]::FromHtml("#F57C3D")
    $accentSoft = [System.Drawing.ColorTranslator]::FromHtml("#FFD7B8")
    $ink = [System.Drawing.ColorTranslator]::FromHtml("#0B1A2B")
    $paper = [System.Drawing.ColorTranslator]::FromHtml("#F6FAFF")

    $outerPadding = $Size * 0.06
    $backgroundSize = $Size - ($outerPadding * 2)
    $cornerRadius = $Size * 0.18

    $backgroundPath = New-RoundedRectanglePath `
        -X $outerPadding `
        -Y $outerPadding `
        -Width $backgroundSize `
        -Height $backgroundSize `
        -Radius $cornerRadius

    $backgroundBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.RectangleF]::new($outerPadding, $outerPadding, $backgroundSize, $backgroundSize),
        $primary,
        $primaryStrong,
        45
    )
    $graphics.FillPath($backgroundBrush, $backgroundPath)

    $spotBrush = [System.Drawing.Drawing2D.PathGradientBrush]::new($backgroundPath)
    $spotBrush.CenterColor = [System.Drawing.Color]::FromArgb(185, $highlight)
    $spotBrush.SurroundColors = [System.Drawing.Color[]]@([System.Drawing.Color]::FromArgb(0, $highlight))
    $spotGraphicsPath = New-RoundedRectanglePath `
        -X ($outerPadding + ($Size * 0.12)) `
        -Y ($outerPadding + ($Size * 0.08)) `
        -Width ($backgroundSize * 0.8) `
        -Height ($backgroundSize * 0.72) `
        -Radius ($Size * 0.2)
    $graphics.FillPath($spotBrush, $spotGraphicsPath)

    $accentBubbleSize = $Size * 0.24
    $accentBubbleBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(216, $accent))
    $graphics.FillEllipse(
        $accentBubbleBrush,
        $Size * 0.64,
        $Size * 0.14,
        $accentBubbleSize,
        $accentBubbleSize
    )

    $shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(50, $ink))
    $graphics.FillEllipse(
        $shadowBrush,
        $Size * 0.14,
        $Size * 0.62,
        $Size * 0.58,
        $Size * 0.18
    )

    $fontSize = [float]($Size * 0.30)
    $font = [System.Drawing.Font]::new("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center

    $textBounds = [System.Drawing.RectangleF]::new(
        $Size * 0.13,
        $Size * 0.22,
        $Size * 0.60,
        $Size * 0.36
    )
    $textShadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(55, $ink))
    $graphics.DrawString("EN", $font, $textShadowBrush, [System.Drawing.RectangleF]::new(
            $textBounds.X + ($Size * 0.012),
            $textBounds.Y + ($Size * 0.012),
            $textBounds.Width,
            $textBounds.Height
        ), $format)
    $textBrush = [System.Drawing.SolidBrush]::new($paper)
    $graphics.DrawString("EN", $font, $textBrush, $textBounds, $format)

    $pencilPen = [System.Drawing.Pen]::new($accent, [float]($Size * 0.11))
    $pencilPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pencilPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine(
        $pencilPen,
        [float]($Size * 0.58),
        [float]($Size * 0.71),
        [float]($Size * 0.79),
        [float]($Size * 0.50)
    )

    $tipPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $tipPath.AddPolygon([System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new([float]($Size * 0.80), [float]($Size * 0.46)),
            [System.Drawing.PointF]::new([float]($Size * 0.86), [float]($Size * 0.40)),
            [System.Drawing.PointF]::new([float]($Size * 0.83), [float]($Size * 0.53))
        ))
    $tipBrush = [System.Drawing.SolidBrush]::new($ink)
    $graphics.FillPath($tipBrush, $tipPath)

    $eraserPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $eraserPath.AddPolygon([System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new([float]($Size * 0.52), [float]($Size * 0.74)),
            [System.Drawing.PointF]::new([float]($Size * 0.57), [float]($Size * 0.69)),
            [System.Drawing.PointF]::new([float]($Size * 0.61), [float]($Size * 0.73)),
            [System.Drawing.PointF]::new([float]($Size * 0.56), [float]($Size * 0.78))
        ))
    $eraserBrush = [System.Drawing.SolidBrush]::new($accentSoft)
    $graphics.FillPath($eraserBrush, $eraserPath)

    $backgroundBrush.Dispose()
    $spotBrush.Dispose()
    $accentBubbleBrush.Dispose()
    $shadowBrush.Dispose()
    $font.Dispose()
    $format.Dispose()
    $textShadowBrush.Dispose()
    $textBrush.Dispose()
    $pencilPen.Dispose()
    $tipPath.Dispose()
    $tipBrush.Dispose()
    $eraserPath.Dispose()
    $eraserBrush.Dispose()
    $spotGraphicsPath.Dispose()
    $backgroundPath.Dispose()
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

    $memoryStreams = @()
    try {
        foreach ($entry in $Entries) {
            $stream = [System.IO.MemoryStream]::new()
            $entry.Bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            $memoryStreams += [pscustomobject]@{
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
            $writer.Write([UInt16]$memoryStreams.Count)

            $offset = 6 + (16 * $memoryStreams.Count)
            foreach ($entry in $memoryStreams) {
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

            foreach ($entry in $memoryStreams) {
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

$sourceIconPath = Join-Path $repoRoot "assets/branding/app_logo.png"
$sourceBitmap = New-IconBitmap -Size 1024
Save-Png -Bitmap $sourceBitmap -Path $sourceIconPath
$sourceBitmap.Dispose()

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

foreach ($target in $pngTargets) {
    $bitmap = New-IconBitmap -Size $target.Size
    Save-Png -Bitmap $bitmap -Path (Join-Path $repoRoot $target.Path)
    $bitmap.Dispose()
}

$icoEntries = @(
    @{ Size = 16; Bitmap = (New-IconBitmap -Size 16) },
    @{ Size = 32; Bitmap = (New-IconBitmap -Size 32) },
    @{ Size = 48; Bitmap = (New-IconBitmap -Size 48) },
    @{ Size = 64; Bitmap = (New-IconBitmap -Size 64) },
    @{ Size = 128; Bitmap = (New-IconBitmap -Size 128) },
    @{ Size = 256; Bitmap = (New-IconBitmap -Size 256) }
)
Save-Ico -Entries $icoEntries -Path (Join-Path $repoRoot "windows/runner/resources/app_icon.ico")
