# Apply CrazyKix.ico + desktop.ini + launch shortcut on a GDK install folder.
param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot
)

$ErrorActionPreference = "Continue"
$IcoSrc = "F:\Unreal Engine\Projects\CrazyKix\Content\Assets\KixIcons\convertico-Icon.ico"
if (-not (Test-Path -LiteralPath $IcoSrc)) {
    Write-Host "ERROR: missing $IcoSrc" -ForegroundColor Red
    exit 1
}

function Find-GameFolders([string]$Root) {
    $exe = Get-ChildItem -LiteralPath $Root -Recurse -Filter "CrazyKix.exe" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "vc_redist" } |
        Select-Object -First 1
    if (-not $exe) { return $null }
    $content = $exe.DirectoryName
    $title = Split-Path $content -Parent
    return [pscustomobject]@{ Content = $content; Title = $title; Exe = $exe.FullName }
}

function Set-FolderIcon([string]$Folder, [string]$IcoName) {
    $ini = Join-Path $Folder "desktop.ini"
    @"
[.ShellClassInfo]
IconResource=$IcoName,0
IconFile=$IcoName
IconIndex=0
"@ | Set-Content -LiteralPath $ini -Encoding Unicode
    attrib.exe +s +r "$Folder"  >$null 2>&1
    attrib.exe +h +s "$ini"     >$null 2>&1
    attrib.exe +h (Join-Path $Folder $IcoName) >$null 2>&1
}

$found = Find-GameFolders $GameRoot
if (-not $found) {
    Write-Host "Could not find CrazyKix.exe under $GameRoot" -ForegroundColor Yellow
    exit 1
}

Copy-Item -LiteralPath $IcoSrc -Destination (Join-Path $found.Title "CrazyKix.ico") -Force
Set-FolderIcon $found.Title "CrazyKix.ico"

# Content is the payload folder — keep the default Explorer folder icon.

$shell = New-Object -ComObject WScript.Shell
$lnk = Join-Path $found.Title "Crazy Kix.lnk"
$sc = $shell.CreateShortcut($lnk)
$sc.TargetPath = $found.Exe
$sc.WorkingDirectory = $found.Content
$sc.WindowStyle = 1
$sc.Description = "Crazy Kix"
$sc.IconLocation = (Join-Path $found.Title "CrazyKix.ico")
$sc.Save()

$uninstSrc = Join-Path $PSScriptRoot "Uninstall-CrazyKix.bat"
$uninstDst = Join-Path $found.Title "Uninstall CrazyKix.bat"
if (Test-Path -LiteralPath $uninstSrc) {
    Copy-Item -LiteralPath $uninstSrc -Destination $uninstDst -Force
    Write-Host "Uninstall: $uninstDst"
}

Write-Host "Folder icon applied to: $($found.Title)"
Write-Host "Shortcut: $lnk"
Write-Host "Note: GDK encrypts CrazyKix.exe, so Explorer still shows a generic .exe icon. Use the shortcut."
exit 0
