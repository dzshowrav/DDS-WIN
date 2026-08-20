@echo off
setlocal
set "SCRIPT_DIR=%~dp0"

echo.
echo ==================================================
echo          DDS Windows Environment Setup            
echo   Apache * MariaDB / MySQL * PHP 8 * phpMyAdmin   
echo ==================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup.ps1"

pause
