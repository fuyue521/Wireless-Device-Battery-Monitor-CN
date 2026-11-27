@echo off
setlocal enabledelayedexpansion
rem Build the Simplified-Chinese installer.
rem Needs: NSIS (makensis on PATH) and a previously built WirelessBattery.exe (see ..\build.bat).

cd /d "%~dp0.."

if not exist "WirelessBattery.exe" (
    echo [error] WirelessBattery.exe not found. Build the application first with build.bat.
    exit /b 1
)

where makensis >nul 2>&1
if errorlevel 1 (
    echo [error] makensis not found. Install NSIS 3.x ^(winget install NSIS.NSIS^) and try again.
    exit /b 1
)

set HC=third_party\headsetcontrol\headsetcontrol.exe
set HCSHA=e371da043710ddb8fc70af77f2ccad1cd03f8c6f49ba423e08764ad7a94a3c40

if not exist "%HC%" (
    echo [1/2] Downloading HeadsetControl 4.3.0 ...
    if not exist "third_party\headsetcontrol" mkdir "third_party\headsetcontrol"
    curl -L -o "%HC%" "https://github.com/Sapd/HeadsetControl/releases/download/4.3.0/headsetcontrol-windows-x86_64.exe"
    if errorlevel 1 (
        echo [error] Download failed. Put headsetcontrol.exe ^(4.3.0, win64^) into third_party\headsetcontrol\ manually.
        exit /b 1
    )
)

for /f "skip=1 delims=" %%H in ('certutil -hashfile "%HC%" SHA256') do (
    set ACT=%%H
    goto :havehash
)
:havehash
set ACT=%ACT: =%
if /i not "%ACT%"=="%HCSHA%" (
    echo [error] headsetcontrol.exe SHA-256 mismatch:
    echo         expected %HCSHA%
    echo         actual   %ACT%
    exit /b 1
)

rem The installer name comes from APP_VERSION in the .nsi, so it can never drift from the package.
rem ("!" in the pattern would be eaten by delayed expansion, so match on "define APP_VERSION" only.)
set APPVER=
for /f "tokens=3" %%v in ('findstr /c:"define APP_VERSION" "installer\Wireless-Device-Battery-Monitor-CN.nsi"') do set APPVER=%%~v
if not defined APPVER (
    echo [error] Could not read APP_VERSION from installer\Wireless-Device-Battery-Monitor-CN.nsi.
    exit /b 1
)

if not exist "dist" mkdir "dist"
echo [2/2] Running makensis ...
rem -INPUTCHARSET UTF8 pins the source encoding: makensis 3 otherwise decodes the .nsi with the
rem system ANSI code page and the Simplified-Chinese strings turn into mojibake.
makensis -INPUTCHARSET UTF8 "installer\Wireless-Device-Battery-Monitor-CN.nsi"
if errorlevel 1 exit /b 1

echo.
echo Done: dist\Wireless-Device-Battery-Monitor-CN-Setup-%APPVER%.exe
