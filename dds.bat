@echo off
setlocal
set "SCRIPT_DIR=%~dp0"

where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    if exist "C:\Program Files\nodejs\node.exe" (
        set "PATH=C:\Program Files\nodejs;%PATH%"
    ) else (
        echo [ERROR] Node.js is not found in PATH.
        echo Please install Node.js from https://nodejs.org/ or run setup.bat
        exit /b 1
    )
)

node "%SCRIPT_DIR%dds-ui\index.js" %*
