@echo off
setlocal
cd /d "%~dp0"

echo.
echo ==================================================
echo          DDS Windows Environment Setup            
echo   Apache * MariaDB / MySQL * PHP 8.5 * phpMyAdmin   
echo ==================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Setup encountered an issue. Press any key to exit...
    pause >nul
)
