$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Project = "F:\Unreal Engine\Projects\CrazyKix"
$Xlsx = Join-Path $Root "listingData-9NST3ZJ3R8D7-980d5ad6-859f-e969-03fc-4d4891241fbb-listingSummaryId.xlsx"
$Bak = $Xlsx + ".bak"
$Assets = Join-Path $Root "Assets"
$IconSrc = Join-Path $Project "Content\Assets\Images\Icon.png"
$HeroSrc = Join-Path $Project "Content\Assets\Images\IMG_Kix1920_1080.png"
$ShotDir = Join-Path $Root "Screenshots"

function Save-Cover([string]$Src, [string]$Dst, [int]$W, [int]$H, [double]$AnchorY = 0.0) {
    if (Test-Path -LiteralPath $Dst) { return }
    $srcImg = [System.Drawing.Image]::FromFile($Src)
    try {
        $bmp = New-Object System.Drawing.Bitmap $W, $H
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.Clear([System.Drawing.Color]::Black)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $scale = [Math]::Max($W / [double]$srcImg.Width, $H / [double]$srcImg.Height)
        $dw = [int][Math]::Ceiling($srcImg.Width * $scale)
        $dh = [int][Math]::Ceiling($srcImg.Height * $scale)
        $x = [int](($W - $dw) / 2)
        $y = [int](($H - $dh) * $AnchorY)
        $g.DrawImage($srcImg, $x, $y, $dw, $dh)
        $g.Dispose()
        $dir = Split-Path $Dst -Parent
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $bmp.Save($Dst, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
    finally { $srcImg.Dispose() }
    Write-Host ("  {0}x{1}  {2}" -f $W, $H, (Split-Path $Dst -Leaf))
}

function Escape-Xml([string]$s) {
    $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
}

function New-CellXml([string]$Ref, [string]$Raw) {
    $escaped = Escape-Xml $Raw
    if ($Raw -match "`r|`n") {
        return '<c r="' + $Ref + '" t="str"><v xml:space="preserve">' + $escaped + '</v></c>'
    }
    return '<c r="' + $Ref + '" t="str"><v>' + $escaped + '</v></c>'
}

New-Item -ItemType Directory -Force -Path (Join-Path $Assets "Desktop") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Assets "Logos") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Assets "Promo") | Out-Null

Save-Cover $IconSrc (Join-Path $Assets "Logos\Poster1440x2160.png") 1440 2160 0.0
Save-Cover $IconSrc (Join-Path $Assets "Logos\Box1080x1080.png") 1080 1080 0.0
Save-Cover $IconSrc (Join-Path $Assets "Logos\Tile300x300.png") 300 300 0.0
Copy-Item -LiteralPath (Join-Path $ShotDir "4.png") -Destination (Join-Path $Assets "Promo\SuperHero1920x1080.png") -Force
Save-Cover $HeroSrc (Join-Path $Assets "Promo\TitledHero1920x1080.png") 1920 1080 0.0
Save-Cover $IconSrc (Join-Path $Assets "Promo\FeaturedSquare1080x1080.png") 1080 1080 0.55

$i = 1
Get-ChildItem -LiteralPath $ShotDir -Filter "*.png" | Where-Object { $_.Name -match '^\d+\.png$' } | Sort-Object { [int]$_.BaseName } | ForEach-Object {
    if ([int]$_.BaseName -eq 9) { return }
    if ($i -gt 8) { return }
    $dst = Join-Path $Assets ("Desktop\{0:D2}.png" -f $i)
    if (-not (Test-Path -LiteralPath $dst)) {
        Copy-Item -LiteralPath $_.FullName -Destination $dst -Force
    }
    $i++
}

$DescriptionEn = @"
Crazy Kix is a fast-paced action platformer where every second counts.

Fly across floating platforms above a sea of lava while dodging laser-firing bots. Activate powerful cannon buttons to destroy enemies, but be quick - each button has a cooldown, forcing you to keep moving and plan your route.

Can you master every level and survive the chaos?

Take on the ultimate lava challenge in Crazy Kix!
"@.Trim()

$DescriptionAr = @"
كريزي كيكس لعبة أكشن ومنصات سريعة الإيقاع، حيث كل ثانية لها أهميتها.

حلّق عبر المنصات العائمة فوق بحر من الحمم البركانية، وتجنّب الروبوتات التي تطلق الليزر. فعّل أزرار المدافع القوية لتدمير الأعداء، لكن أسرع - فلكل زر فترة تهدئة تجبرك على الاستمرار في الحركة وتخطيط مسارك.

هل تستطيع إتقان كل مستوى والنجاة من الفوضى؟

خُض تحدي الحمم الأقصى في Crazy Kix!
"@.Trim()

$En = [ordered]@{
    Description = $DescriptionEn
    Title = "Crazy Kix"
    ShortTitle = "Crazy Kix"
    SortTitle = "Crazy Kix"
    VoiceTitle = "Crazy Kix"
    ShortDescription = "Fly, dodge lasers, activate cannons, and survive the lava arena!"
    DevStudio = "MazenX"
    CopyrightTrademarkInformation = "(c) 2026 MazenX. All rights reserved."
    DesktopScreenshot1 = "Assets/Desktop/01.png"
    DesktopScreenshot2 = "Assets/Desktop/02.png"
    DesktopScreenshot3 = "Assets/Desktop/03.png"
    DesktopScreenshot4 = "Assets/Desktop/04.png"
    DesktopScreenshot5 = "Assets/Desktop/05.png"
    DesktopScreenshot6 = "Assets/Desktop/06.png"
    DesktopScreenshot7 = "Assets/Desktop/07.png"
    DesktopScreenshot8 = "Assets/Desktop/08.png"
    DesktopScreenshotCaption1 = "Main menu - jump into the lava arena"
    DesktopScreenshotCaption2 = "Explore volcanic platforms"
    DesktopScreenshotCaption3 = "Hit cannon buttons to fight back"
    DesktopScreenshotCaption4 = "Race past turrets and traps"
    DesktopScreenshotCaption5 = "Fly across the lava with jet thrusters"
    DesktopScreenshotCaption6 = "Stay airborne to survive"
    DesktopScreenshotCaption7 = "Dodge laser-firing bots"
    DesktopScreenshotCaption8 = "Outrun enemy drones"
    StoreLogo720x1080 = "Assets/Logos/Poster1440x2160.png"
    StoreLogo1080x1080 = "Assets/Logos/Box1080x1080.png"
    StoreLogo300x300 = "Assets/Logos/Tile300x300.png"
    PromoImage1920x1080 = "Assets/Promo/SuperHero1920x1080.png"
    XboxTitledHero1920x1080 = "Assets/Promo/TitledHero1920x1080.png"
    XboxFeaturedPromo1080x1080 = "Assets/Promo/FeaturedSquare1080x1080.png"
    Feature1 = "Fly freely using jet-powered movement"
    Feature2 = "Battle laser-shooting enemy bots"
    Feature3 = "Survive dangerous lava-filled arenas"
    Feature4 = "Activate cannons to eliminate enemies"
    Feature5 = "Cannon buttons reactivate after a short cooldown"
    Feature6 = "Challenging levels with increasing difficulty"
    Feature7 = "Fast-paced gameplay that rewards quick reflexes"
    MinimumHardwareReq1 = "OS: Windows 10 64-bit (version 1903 or later)"
    MinimumHardwareReq2 = "Processor: Intel Core i5-4590 or AMD FX-8350"
    MinimumHardwareReq3 = "Memory: 8 GB RAM"
    MinimumHardwareReq4 = "Graphics: NVIDIA GTX 960 or AMD Radeon R9 280"
    MinimumHardwareReq5 = "DirectX: Version 12"
    MinimumHardwareReq6 = "Storage: 5 GB available space"
    RecommendedHardwareReq1 = "OS: Windows 10/11 64-bit"
    RecommendedHardwareReq2 = "Processor: Intel Core i7-6700 or AMD Ryzen 5 1600"
    RecommendedHardwareReq3 = "Memory: 16 GB RAM"
    RecommendedHardwareReq4 = "Graphics: NVIDIA GTX 1060 or AMD Radeon RX 580"
    RecommendedHardwareReq5 = "DirectX: Version 12"
    RecommendedHardwareReq6 = "Storage: 5 GB available space"
    SearchTerm1 = "action platformer"
    SearchTerm2 = "jetpack"
    SearchTerm3 = "lava"
    SearchTerm4 = "arcade"
    SearchTerm5 = "flying"
    SearchTerm6 = "cannons"
    SearchTerm7 = "dodge"
}

$Ar = [ordered]@{
    Description = $DescriptionAr
    Title = "Crazy Kix"
    ShortTitle = "Crazy Kix"
    SortTitle = "Crazy Kix"
    VoiceTitle = "كريزي كيكس"
    ShortDescription = "حلّق، تجنّب الليزر، فعّل المدافع، وانجُ من حلبة الحمم!"
    DevStudio = "MazenX"
    CopyrightTrademarkInformation = "(c) 2026 MazenX. جميع الحقوق محفوظة."
    DesktopScreenshotCaption1 = "القائمة الرئيسية - انطلق إلى حلبة الحمم"
    DesktopScreenshotCaption2 = "استكشف المنصات البركانية"
    DesktopScreenshotCaption3 = "اضغط أزرار المدافع للرد"
    DesktopScreenshotCaption4 = "اركض بين الأبراج والفخاخ"
    DesktopScreenshotCaption5 = "حلّق فوق الحمم بالدفع النفاث"
    DesktopScreenshotCaption6 = "ابقَ في الهواء لتنجو"
    DesktopScreenshotCaption7 = "تجنّب روبوتات الليزر"
    DesktopScreenshotCaption8 = "اهرب من طائرات العدو المسيرة"
    Feature1 = "حلّق بحرية بحركة الدفع النفاث"
    Feature2 = "قاتل روبوتات العدو التي تطلق الليزر"
    Feature3 = "انجُ من حلبات الحمم الخطرة"
    Feature4 = "فعّل المدافع للقضاء على الأعداء"
    Feature5 = "أزرار المدافع تُعاد تفعيلها بعد تهدئة قصيرة"
    Feature6 = "مستويات صعبة تزداد تحدياً"
    Feature7 = "لعب سريع يكافئ ردود الفعل السريعة"
    MinimumHardwareReq1 = "نظام التشغيل: Windows 10 64-bit (الإصدار 1903 أو أحدث)"
    MinimumHardwareReq2 = "المعالج: Intel Core i5-4590 أو AMD FX-8350"
    MinimumHardwareReq3 = "الذاكرة: 8 غيغابايت رام"
    MinimumHardwareReq4 = "الرسوميات: NVIDIA GTX 960 أو AMD Radeon R9 280"
    MinimumHardwareReq5 = "DirectX: الإصدار 12"
    MinimumHardwareReq6 = "التخزين: 5 غيغابايت مساحة متوفرة"
    RecommendedHardwareReq1 = "نظام التشغيل: Windows 10/11 64-bit"
    RecommendedHardwareReq2 = "المعالج: Intel Core i7-6700 أو AMD Ryzen 5 1600"
    RecommendedHardwareReq3 = "الذاكرة: 16 غيغابايت رام"
    RecommendedHardwareReq4 = "الرسوميات: NVIDIA GTX 1060 أو AMD Radeon RX 580"
    RecommendedHardwareReq5 = "DirectX: الإصدار 12"
    RecommendedHardwareReq6 = "التخزين: 5 غيغابايت مساحة متوفرة"
    SearchTerm1 = "أكشن"
    SearchTerm2 = "منصات"
    SearchTerm3 = "حمم"
    SearchTerm4 = "أركيد"
    SearchTerm5 = "طيران"
    SearchTerm6 = "مدافع"
    SearchTerm7 = "روبوتات"
}

function Get-CellText([System.Xml.XmlElement]$Cell) {
    if ($null -eq $Cell) { return "" }
    $v = $Cell.GetElementsByTagName("v") | Select-Object -First 1
    if ($null -eq $v) { return "" }
    return [string]$v.InnerText
}

function Set-CellText([xml]$Doc, [System.Xml.XmlElement]$Row, [string]$Ns, [string]$Col, [string]$Text) {
    $rowNum = $Row.GetAttribute("r")
    $ref = $Col + $rowNum
    $cell = $null
    foreach ($c in $Row.GetElementsByTagName("c")) {
        if ($c.GetAttribute("r") -eq $ref) { $cell = $c; break }
    }
    if ($null -eq $cell) {
        $cell = $Doc.CreateElement("c", $Ns)
        $cell.SetAttribute("r", $ref)
        [void]$Row.AppendChild($cell)
    }
    $cell.SetAttribute("t", "str")
    $v = $cell.GetElementsByTagName("v") | Select-Object -First 1
    if ($null -eq $v) {
        $v = $Doc.CreateElement("v", $Ns)
        [void]$cell.AppendChild($v)
    }
    $v.InnerText = $Text
    if ($Text -match "`r|`n") {
        $v.SetAttribute("space", "http://www.w3.org/XML/1998/namespace", "preserve")
    }
}

Write-Host "Filling workbook (default + ar)"
$srcXlsx = $Xlsx
if (Test-Path -LiteralPath $Bak) { $srcXlsx = $Bak }

$tmp = Join-Path $env:TEMP ("listingFill_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
Copy-Item -LiteralPath $srcXlsx -Destination (Join-Path $tmp "listing.zip")
Expand-Archive -LiteralPath (Join-Path $tmp "listing.zip") -DestinationPath (Join-Path $tmp "unz") -Force
$sheetPath = Join-Path $tmp "unz\xl\worksheets\sheet1.xml"
$ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
[xml]$doc = [System.IO.File]::ReadAllText($sheetPath)
$doc.worksheet.dimension.ref = "A1:E454"

$filled = 0
foreach ($row in $doc.worksheet.sheetData.row) {
    $a = $null
    foreach ($c in $row.c) {
        if ($c.r -match '^A\d+$') { $a = $c; break }
    }
    $field = Get-CellText $a
    if ($field -eq "Field") {
        Set-CellText $doc $row $ns "E" "ar"
        continue
    }
    $enVal = $En[$field]
    $arVal = $Ar[$field]
    if ($null -ne $enVal) {
        Set-CellText $doc $row $ns "D" ([string]$enVal)
        $filled++
    }
    if ($null -ne $arVal) {
        Set-CellText $doc $row $ns "E" ([string]$arVal)
    }
    else {
        Set-CellText $doc $row $ns "E" ""
    }
}
Write-Host ("Filled {0} fields" -f $filled)

$utf8 = New-Object System.Text.UTF8Encoding $false
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding = $utf8
$settings.Indent = $false
$settings.OmitXmlDeclaration = $false
$writer = [System.Xml.XmlWriter]::Create($sheetPath, $settings)
$doc.Save($writer)
$writer.Close()

if (-not (Test-Path -LiteralPath $Bak)) { Copy-Item -LiteralPath $Xlsx -Destination $Bak }

$out = Join-Path $tmp "out.xlsx"
$fs = [System.IO.File]::Open($out, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
$unz = Join-Path $tmp "unz"
Get-ChildItem $unz -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($unz.Length).TrimStart('\').Replace('\', '/')
    [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel, [System.IO.Compression.CompressionLevel]::Optimal)
}
$zip.Dispose()
$fs.Dispose()
Copy-Item -LiteralPath $out -Destination $Xlsx -Force
Remove-Item $tmp -Recurse -Force
Write-Host "Wrote $Xlsx"
Write-Host "Columns: default (English) + ar (Arabic)"
