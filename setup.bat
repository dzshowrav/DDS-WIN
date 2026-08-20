@echo off
setlocal
cd /d "%~dp0"

title DDS Windows Setup

echo.
echo =======================================================
echo         DDS Local Server Stack - Windows Setup         
echo     Apache 2.4 * MariaDB 10.11 * PHP 8.5 * phpMyAdmin  
echo =======================================================
echo.
echo Starting automated environment configuration...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo =======================================================
    echo Setup encountered an error. Please check the logs above.
    echo =======================================================
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Press any key to exit this installer or type 'dds' to start...
pause >nul
