@echo off
setlocal
cd /d "%~dp0"

title DDS Windows Installer

echo.
echo =======================================================
echo         DDS Local Server Stack - Easy Installer        
echo =======================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Setup encountered an error.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Press any key to exit or type 'dds' to start...
pause >nul
