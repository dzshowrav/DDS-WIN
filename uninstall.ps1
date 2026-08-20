# ==============================================================================
# DDS Windows Uninstaller - Complete Clean Removal
# Stops all services, removes C:\DDS, cleans Windows PATH
# ==============================================================================

param (
    [switch]$Force,
    [switch]$WipeProjects
)

$Host.UI.RawUI.WindowTitle = "DDS Windows Uninstaller"

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Red
Write-Host "             DDS Windows Complete Uninstaller            " -ForegroundColor Yellow
Write-Host "  =======================================================" -ForegroundColor Red
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DdsBase = "C:\DDS"

if (-not $Force) {
    Write-Host "  This will completely remove DDS and its services from this computer." -ForegroundColor Yellow
    $Confirm = Read-Host "  Are you sure you want to uninstall DDS? (y/N)"
    if ($Confirm -notmatch "^[yY]$") {
        Write-Host "`n  [!] Uninstallation cancelled by user.`n" -ForegroundColor Gray
        exit 0
    }

    $ConfirmProjects = Read-Host "  Do you also want to delete your website files in 'C:\DDS\Projects'? (y/N)"
    if ($ConfirmProjects -match "^[yY]$") {
        $WipeProjects = $true
    }
}

Write-Host ""
Write-Host "[1/4] Stopping all active DDS services and processes..." -ForegroundColor Cyan
$ProcessesToKill = @("httpd", "mysqld", "mariadbd", "php-cgi", "php")
foreach ($proc in $ProcessesToKill) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            Write-Host "      [OK] Stopped process: $($_.ProcessName) (PID $($_.Id))" -ForegroundColor Green
        } catch {}
    }
}

# Ensure ports 8080, 8443, 3306, 9000 are freed
Start-Sleep -Milliseconds 500

Write-Host "[2/4] Removing DDS paths from Windows User PATH environment..." -ForegroundColor Cyan
try {
    $UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($UserPath) {
        $PathEntries = $UserPath -split ";" | Where-Object { 
            $_ -and 
            $_ -ne $ScriptDir -and 
            $_ -notlike "C:\DDS*" -and
            $_ -notlike "*\DDS\Services*"
        }
        $CleanedUserPath = ($PathEntries -join ";").TrimEnd(";")
        [System.Environment]::SetEnvironmentVariable("Path", $CleanedUserPath, "User")
        $env:Path = $CleanedUserPath
        Write-Host "      [OK] User PATH cleaned successfully." -ForegroundColor Green
    }
} catch {
    Write-Host "      [!] Note: Could not update User PATH automatically: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "[3/4] Deleting DDS runtime services, logs, and temporary files..." -ForegroundColor Cyan
if (Test-Path $DdsBase) {
    # Remove Services
    if (Test-Path "$DdsBase\Services") {
        Remove-Item -Path "$DdsBase\Services" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Removed C:\DDS\Services" -ForegroundColor Green
    }
    # Remove Logs
    if (Test-Path "$DdsBase\Logs") {
        Remove-Item -Path "$DdsBase\Logs" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Removed C:\DDS\Logs" -ForegroundColor Green
    }
    # Remove Certificates
    if (Test-Path "$DdsBase\Certificates") {
        Remove-Item -Path "$DdsBase\Certificates" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Removed C:\DDS\Certificates" -ForegroundColor Green
    }
    # Remove tmp
    if (Test-Path "$DdsBase\tmp") {
        Remove-Item -Path "$DdsBase\tmp" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Removed C:\DDS\tmp" -ForegroundColor Green
    }

    # Handle Projects
    if ($WipeProjects) {
        if (Test-Path "$DdsBase\Projects") {
            Remove-Item -Path "$DdsBase\Projects" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "      [OK] Removed C:\DDS\Projects" -ForegroundColor Green
        }
        Remove-Item -Path $DdsBase -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Removed root folder C:\DDS" -ForegroundColor Green
    } else {
        Write-Host "      [i] Preserved your website project files in C:\DDS\Projects" -ForegroundColor Cyan
        # Clean root C:\DDS if empty
        $remaining = Get-ChildItem -Path $DdsBase -ErrorAction SilentlyContinue
        if ($remaining.Count -eq 0) {
            Remove-Item -Path $DdsBase -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "[4/4] Cleaning local build and dependency artifacts..." -ForegroundColor Cyan
$UiNodeModules = Join-Path $ScriptDir "dds-ui\node_modules"
if (Test-Path $UiNodeModules) {
    Remove-Item -Path $UiNodeModules -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [OK] Cleaned dds-ui node_modules." -ForegroundColor Green
}

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host "           🎉 DDS Has Been Completely Uninstalled!        " -ForegroundColor Green
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  - All web server, PHP, and database processes were stopped." -ForegroundColor White
Write-Host "  - All runtime binaries and cache files were removed." -ForegroundColor White
Write-Host "  - Windows PATH environment variable was restored." -ForegroundColor White
if ($WipeProjects) {
    Write-Host "  - All project data in C:\DDS was deleted." -ForegroundColor White
} else {
    Write-Host "  - Your website files remain safely in C:\DDS\Projects." -ForegroundColor White
}
Write-Host ""
Write-Host "  You can now safely delete this repository folder if desired." -ForegroundColor Gray
Write-Host ""
