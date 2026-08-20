# ==============================================================================
# DDS Windows One-Line Web Installer
# Usage: irm https://raw.githubusercontent.com/dzshowrav/DDS-WIN/main/install.ps1 | iex
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "DDS Windows Web Installer"

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Cyan
Write-Host "         DDS Local Server Stack - Web Installer          " -ForegroundColor Yellow
Write-Host "     Apache 2.4 · MariaDB 10.11 · PHP 8.5 · phpMyAdmin   " -ForegroundColor Gray
Write-Host "  =======================================================" -ForegroundColor Cyan
Write-Host ""

$DefaultInstallPath = "C:\DDS\App"
$TargetDir = $DefaultInstallPath

Write-Host "  Installing DDS to: $TargetDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

$ZipUrl = "https://github.com/dzshowrav/DDS-WIN/archive/refs/heads/main.zip"
$TempZip = Join-Path $env:TEMP "dds_web_install.zip"
$TempExtract = Join-Path $env:TEMP "dds_web_extract"

Write-Host "[1/4] Downloading latest DDS stack..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -UseBasicParsing

Write-Host "[2/4] Extracting package files..." -ForegroundColor Cyan
if (Test-Path $TempExtract) {
    Remove-Item -Path $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
}
Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

$SubDir = Get-ChildItem -Path $TempExtract -Directory | Select-Object -First 1
if ($SubDir) {
    Copy-Item -Path "$($SubDir.FullName)\*" -Destination $TargetDir -Recurse -Force
} else {
    Copy-Item -Path "$TempExtract\*" -Destination $TargetDir -Recurse -Force
}

Remove-Item -Path $TempZip, $TempExtract -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[3/4] Running automated environment configuration..." -ForegroundColor Cyan
$SetupScript = Join-Path $TargetDir "setup.ps1"
if (Test-Path $SetupScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$SetupScript"
}

Write-Host "[4/4] Creating Desktop Shortcut..." -ForegroundColor Cyan
try {
    $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory)
    $ShortcutPath = Join-Path $DesktopPath "DDS Server Control.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = (Join-Path $TargetDir "dds.cmd")
    $Shortcut.WorkingDirectory = $TargetDir
    $Shortcut.Description = "DDS Local Web Server Stack Manager"
    $Shortcut.Save()
    Write-Host "      [OK] Desktop shortcut created." -ForegroundColor Green
} catch {}

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host "               🎉 DDS Successfully Installed!            " -ForegroundColor Green
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Type 'dds' in any terminal to open the visual dashboard!" -ForegroundColor Cyan
Write-Host ""
