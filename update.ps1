# DDS Windows Update Script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Updating DDS..." -ForegroundColor Cyan

# Stop services if running
& node "$ScriptDir\dds-ui\index.js" stop 2>$null

# Pull git if repository exists
if (Test-Path "$ScriptDir\.git") {
    try {
        Push-Location $ScriptDir
        git pull
        Pop-Location
    } catch {}
}

# Update npm dependencies
Push-Location "$ScriptDir\dds-ui"
if (Test-Path 'C:\Program Files\nodejs\npm.cmd') {
    & 'C:\Program Files\nodejs\npm.cmd' install --no-audit --no-fund
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
    & npm install --no-audit --no-fund
}
Pop-Location

# Regenerate vhost config
& node "$ScriptDir\dds-ui\index.js" vhosts 2>$null

Write-Host "DDS is up to date!" -ForegroundColor Green
