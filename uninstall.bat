@echo off
setlocal
cd /d "%~dp0"

title DDS Windows Complete Uninstaller

echo.
echo =======================================================
echo          DDS Windows Complete Uninstaller              
echo =======================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Uninstallation encountered an error or was cancelled.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Press any key to close this window...
pause >nul
