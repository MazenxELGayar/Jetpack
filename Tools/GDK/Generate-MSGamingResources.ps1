# Resize game art into GDK MicrosoftGame.config ShellVisuals slots.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$Project = "F:\Unreal Engine\Projects\CrazyKix"
$IconSrc = Join-Path $Project "Content\Assets\Images\Icon.png"
$SplashSrc = Join-Path $Project "Content\Assets\Images\IMG_Kix1920_1080.png"
$Dests = @(
    (Join-Path $Project "Build\Windows\MSGaming\Resources"),
    (Join-Path $Project "Build\Win64\MSGaming\Resources")
)

function Save-CoverPng([string]$Src, [string]$Dst, [int]$W, [int]$H) {
    $srcImg = [System.Drawing.Image]::FromFile($Src)
    try {
        $bmp = New-Object System.Drawing.Bitmap $W, $H
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $scale = [Math]::Max($W / [double]$srcImg.Width, $H / [double]$srcImg.Height)
        $dw = [int][Math]::Ceiling($srcImg.Width * $scale)
        $dh = [int][Math]::Ceiling($srcImg.Height * $scale)
        $x = [int](($W - $dw) / 2)
        $y = [int](($H - $dh) / 2)
        $g.DrawImage($srcImg, $x, $y, $dw, $dh)
        $g.Dispose()
        $dir = Split-Path $Dst -Parent
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $bmp.Save($Dst, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
    finally { $srcImg.Dispose() }
    Write-Host ("Wrote {0}x{1}  {2}" -f $W, $H, $Dst)
}

if (-not (Test-Path -LiteralPath $IconSrc)) { throw "Missing icon: $IconSrc" }
if (-not (Test-Path -LiteralPath $SplashSrc)) { throw "Missing splash: $SplashSrc" }

foreach ($dest in $Dests) {
    Save-CoverPng $IconSrc (Join-Path $dest "SmallLogo.png") 44 44
    Save-CoverPng $IconSrc (Join-Path $dest "StoreLogo.png") 100 100
    Save-CoverPng $IconSrc (Join-Path $dest "Logo.png") 150 150
    Save-CoverPng $IconSrc (Join-Path $dest "Square480x480Logo.png") 480 480
    Save-CoverPng $SplashSrc (Join-Path $dest "SplashScreen.png") 1920 1080
}

$IcoSrc = Join-Path $Project "Content\Assets\KixIcons\convertico-Icon.ico"
if (Test-Path -LiteralPath $IcoSrc) {
    Copy-Item -LiteralPath $IcoSrc -Destination (Join-Path $Project "Build\Windows\Application.ico") -Force
    Write-Host "Copied convertico-Icon.ico -> Build\Windows\Application.ico (embedded on next Shipping build)"
}
