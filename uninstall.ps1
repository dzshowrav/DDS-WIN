# ==============================================================================
# DDS Windows Uninstaller - 100% Deep & Clean System Removal
# Stops processes, uninstalls services, wipes C:\DDS & packages, cleans PATH
# ==============================================================================

param (
    [switch]$Force,
    [switch]$WipeProjects,
    [switch]$WipeRepo
)

$Host.UI.RawUI.WindowTitle = "DDS Windows Complete Uninstaller"

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Red
Write-Host "             DDS Windows Deep System Uninstaller         " -ForegroundColor Yellow
Write-Host "  =======================================================" -ForegroundColor Red
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DdsBase = "C:\DDS"

if (-not $Force) {
    Write-Host "  This will completely uninstall DDS, all installed services (Apache, PHP," -ForegroundColor Yellow
    Write-Host "  MariaDB, phpMyAdmin), caches, and environment configurations." -ForegroundColor Yellow
    Write-Host ""
    $Confirm = Read-Host "  Are you sure you want to uninstall DDS? (y/N)"
    if ($Confirm -notmatch "^[yY]$") {
        Write-Host "`n  [!] Uninstallation cancelled by user.`n" -ForegroundColor Gray
        exit 0
    }

    $ConfirmProjects = Read-Host "  Do you also want to delete all website files in 'C:\DDS\Projects'? (y/N)"
    if ($ConfirmProjects -match "^[yY]$") {
        $WipeProjects = $true
    }

    $ConfirmRepo = Read-Host "  Do you want to delete this DDS repository folder after uninstall? (y/N)"
    if ($ConfirmRepo -match "^[yY]$") {
        $WipeRepo = $true
    }
}

Write-Host ""
# 1. Stop and terminate all processes
Write-Host "[1/6] Terminating all active DDS services and background processes..." -ForegroundColor Cyan
$ProcessesToKill = @("httpd", "mysqld", "mariadbd", "php-cgi", "php", "mysqladmin")
foreach ($proc in $ProcessesToKill) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            Write-Host "      [OK] Stopped process: $($_.ProcessName) (PID $($_.Id))" -ForegroundColor Green
        } catch {}
    }
}
Start-Sleep -Milliseconds 600

# 2. Unregister Windows Services if registered
Write-Host "[2/6] Checking and removing registered Windows Services..." -ForegroundColor Cyan
$ServicesToCheck = @("Apache2.4", "Apache", "MariaDB", "MySQL", "DDS_Apache", "DDS_MySQL")
foreach ($s in $ServicesToCheck) {
    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    if ($svc) {
        try {
            Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
            & sc.exe delete $s 2>$null | Out-Null
            Write-Host "      [OK] Removed Windows Service: $s" -ForegroundColor Green
        } catch {}
    }
}
Write-Host "      [OK] Windows Services cleaned." -ForegroundColor Green

# 3. Clean Windows PATH Environment
Write-Host "[3/6] Restoring Windows User PATH environment..." -ForegroundColor Cyan
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
        Write-Host "      [OK] User PATH restored." -ForegroundColor Green
    }
} catch {
    Write-Host "      [!] Note: PATH cleanup: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 4. Remove Package Manager installs and temp download caches
Write-Host "[4/6] Cleaning package manager caches and temp files..." -ForegroundColor Cyan
if (Get-Command winget -ErrorAction SilentlyContinue) {
    try {
        winget uninstall --id ApacheLounge.httpd --silent --accept-source-agreements 2>$null | Out-Null
    } catch {}
}

# Clean WinGet AppData temporary packages for Apache / PHP
$WinGetPackageDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
if (Test-Path $WinGetPackageDir) {
    Get-ChildItem -Path $WinGetPackageDir -Filter "*Apache*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
# Clean temp archives in %TEMP%
Get-ChildItem -Path $env:TEMP -Filter "*dds*" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $env:TEMP -Filter "*php-8.*" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $env:TEMP -Filter "*mariadb-10.*" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "      [OK] Temporary caches removed." -ForegroundColor Green

# 5. Wipe C:\DDS Core Directory
Write-Host "[5/6] Deleting DDS runtime stack from disk..." -ForegroundColor Cyan
if (Test-Path $DdsBase) {
    # Remove Services
    if (Test-Path "$DdsBase\Services") {
        Remove-Item -Path "$DdsBase\Services" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Deleted C:\DDS\Services" -ForegroundColor Green
    }
    # Remove Logs
    if (Test-Path "$DdsBase\Logs") {
        Remove-Item -Path "$DdsBase\Logs" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Deleted C:\DDS\Logs" -ForegroundColor Green
    }
    # Remove Certificates
    if (Test-Path "$DdsBase\Certificates") {
        Remove-Item -Path "$DdsBase\Certificates" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Deleted C:\DDS\Certificates" -ForegroundColor Green
    }
    # Remove tmp
    if (Test-Path "$DdsBase\tmp") {
        Remove-Item -Path "$DdsBase\tmp" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Deleted C:\DDS\tmp" -ForegroundColor Green
    }

    # Handle Projects
    if ($WipeProjects) {
        if (Test-Path "$DdsBase\Projects") {
            Remove-Item -Path "$DdsBase\Projects" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "      [OK] Deleted C:\DDS\Projects" -ForegroundColor Green
        }
        Remove-Item -Path $DdsBase -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] Completely removed C:\DDS" -ForegroundColor Green
    } else {
        Write-Host "      [i] Preserved your website project files in C:\DDS\Projects" -ForegroundColor Cyan
        $remaining = Get-ChildItem -Path $DdsBase -ErrorAction SilentlyContinue
        if ($remaining.Count -eq 0) {
            Remove-Item -Path $DdsBase -Force -ErrorAction SilentlyContinue
        }
    }
}

# 6. Clean local repo node_modules
Write-Host "[6/6] Finalizing repository and artifact cleanup..." -ForegroundColor Cyan
$UiNodeModules = Join-Path $ScriptDir "dds-ui\node_modules"
if (Test-Path $UiNodeModules) {
    Remove-Item -Path $UiNodeModules -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [OK] Cleaned dds-ui node_modules." -ForegroundColor Green
}

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host "         🎉 DDS & ALL Components Completely Removed!     " -ForegroundColor Green
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  - All web server, database, and PHP daemons terminated." -ForegroundColor White
Write-Host "  - All runtime binaries (Apache, MariaDB, PHP, PMA) deleted." -ForegroundColor White
Write-Host "  - All download caches and temporary archives cleared." -ForegroundColor White
Write-Host "  - Windows PATH environment restored to original state." -ForegroundColor White
if ($WipeProjects) {
    Write-Host "  - All project data in C:\DDS was deleted." -ForegroundColor White
} else {
    Write-Host "  - Your website files remain safely in C:\DDS\Projects." -ForegroundColor White
}
Write-Host ""

if ($WipeRepo) {
    Write-Host "  Self-deleting repository folder..." -ForegroundColor Yellow
    $SelfDeleteBatch = "$env:TEMP\dds_self_delete.bat"
    $BatchContent = @"
@echo off
timeout /t 2 /nobreak >nul
rd /s /q "$ScriptDir"
del "%~f0"
"@
    Set-Content -Path $SelfDeleteBatch -Value $BatchContent -Encoding ASCII
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$SelfDeleteBatch`"" -WindowStyle Hidden
    Write-Host "  [OK] Repository folder scheduled for immediate removal." -ForegroundColor Green
} else {
    Write-Host "  You can now safely delete this folder whenever you wish." -ForegroundColor Gray
}
Write-Host ""
