@echo off
setlocal
set "SCRIPT_DIR=%~dp0"

:: Ensure node is accessible
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

:: Run DDS UI
node "%SCRIPT_DIR%dds-ui\index.js" %*
