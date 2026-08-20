# DDS PowerShell Launcher
$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check for node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    if (Test-Path 'C:\Program Files\nodejs\node.exe') {
        $env:Path = "C:\Program Files\nodejs;" + $env:Path
    } else {
        Write-Error "Node.js is not found in PATH. Please install Node.js or run setup.ps1"
        exit 1
    }
}

$UiEntry = Join-Path $ScriptDir "dds-ui\index.js"
& node $UiEntry @args
