@echo off
setlocal
REM Package CrazyKix Win64 Shipping with MSGameStore (.msixvc for Xbox PC App)
REM Requires: UE 5.8, GameDK env, Partner Center associate completed for store upload.

set "UE_ROOT=F:\Unreal Engine\UE_5.8"
set "PROJECT=F:\Unreal Engine\Projects\CrazyKix\CrazyKix.uproject"
set "ARCHIVE=F:\Unreal Engine\Projects\CrazyKix\Packages\Win64_GDK"

if not exist "%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" (
  echo ERROR: RunUAT not found at "%UE_ROOT%"
  exit /b 1
)

if "%GameDK%"=="" (
  echo WARNING: GameDK env var is empty. Open a NEW terminal after GDK install, or set:
  echo   set GameDK=F:\Unreal Engine\Microsoft\GDK\GDK_2604.2.7849\
)

REM UBT needs .NET Framework Developer Pack (NetFxSDK) when compiling from Build Tools.
if not exist "%ProgramFiles(x86)%\Reference Assemblies\Microsoft\Framework\.NETFramework" (
  echo WARNING: .NET Framework targeting pack not found. If UBT fails on SwarmInterface/NetFxSDK:
  echo   winget install Microsoft.DotNet.Framework.DeveloperPack_4
)

mkdir "%ARCHIVE%" 2>nul

call "%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun ^
  -project="%PROJECT%" ^
  -platform=Win64 ^
  -clientconfig=Shipping ^
  -build -cook -stage -pak -iostore -compressed ^
  -package ^
  -archive -archivedirectory="%ARCHIVE%" ^
  -utf8output ^
  -NoLiveCoding %*

set ERR=%ERRORLEVEL%
echo.
echo UAT exit code: %ERR%
echo Output folder: %ARCHIVE%
echo Look for .msixvc then install/launch with GDK tools:
echo   https://learn.microsoft.com/gaming/gdk/docs/gdk-dev/pc-dev/get-started/utilizing-microsoft-game-development-kit-tools-to-install-and-launch-your-pc-title
echo Upload the package via Partner Center when ready.
exit /b %ERR%
