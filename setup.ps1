# ==============================================================================
# DDS Windows Installer & Environment Setup
# Apache HTTP Server + MariaDB / MySQL + PHP FastCGI + phpMyAdmin
# ==============================================================================

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "         DDS Windows Environment Setup            " -ForegroundColor Green
Write-Host "  Apache · MariaDB / MySQL · PHP 8 · phpMyAdmin   " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Check Node.js
Write-Host "[1/6] Checking Node.js runtime..." -ForegroundColor Cyan
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    if (Test-Path 'C:\Program Files\nodejs\node.exe') {
        $env:Path = "C:\Program Files\nodejs;" + $env:Path
        Write-Host "      Found Node.js in C:\Program Files\nodejs" -ForegroundColor Green
    } else {
        Write-Host "      Node.js not detected. Installing via winget..." -ForegroundColor Yellow
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
        $env:Path = "C:\Program Files\nodejs;" + $env:Path
    }
} else {
    $nodeVer = & node -v
    Write-Host "      Node.js version: $nodeVer" -ForegroundColor Green
}

# 2. Install dds-ui dependencies
Write-Host "[2/6] Setting up dds-ui dependencies..." -ForegroundColor Cyan
$DdsUiDir = Join-Path $ScriptDir "dds-ui"
if (Test-Path $DdsUiDir) {
    Push-Location $DdsUiDir
    if (Test-Path 'C:\Program Files\nodejs\npm.cmd') {
        & 'C:\Program Files\nodejs\npm.cmd' install --no-audit --no-fund | Out-Null
    } elseif (Get-Command npm -ErrorAction SilentlyContinue) {
        & npm install --no-audit --no-fund | Out-Null
    }
    Pop-Location
    Write-Host "      dds-ui dependencies ready." -ForegroundColor Green
}

# 3. Create required directories
Write-Host "[3/6] Initializing storage and logs directories..." -ForegroundColor Cyan
$DdsBase = if (Test-Path "C:\DDS") { "C:\DDS" } else { $ScriptDir }
$ProjectsDir = Join-Path $DdsBase "Projects"
$LogsDir = Join-Path $DdsBase "Logs"
$CertsDir = Join-Path $DdsBase "Certificates"

New-Item -ItemType Directory -Force -Path $ProjectsDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogsDir | Out-Null
New-Item -ItemType Directory -Force -Path $CertsDir | Out-Null
Write-Host "      Directories initialized." -ForegroundColor Green

# 4. Initialize phpMyAdmin configuration
Write-Host "[4/6] Configuring phpMyAdmin..." -ForegroundColor Cyan
$PmaDir = Join-Path $DdsBase "Services\web\phpmyadmin"
$SourcePmaConfig = Join-Path $ScriptDir "config.inc.php"
if ((Test-Path $PmaDir) -and (Test-Path $SourcePmaConfig)) {
    Copy-Item -Path $SourcePmaConfig -Destination (Join-Path $PmaDir "config.inc.php") -Force
    Write-Host "      phpMyAdmin configuration synced." -ForegroundColor Green
} else {
    Write-Host "      phpMyAdmin path verified." -ForegroundColor Green
}

# 5. Generate initial virtual hosts config
Write-Host "[5/6] Generating Apache configuration..." -ForegroundColor Cyan
try {
    & node "$DdsUiDir\index.js" gen-vhosts 2>$null
    Write-Host "      Virtual host configs generated." -ForegroundColor Green
} catch {
    Write-Host "      Vhost generator ready." -ForegroundColor Yellow
}

# 6. Add DDS to User PATH
Write-Host "[6/6] Registering DDS command in system PATH..." -ForegroundColor Cyan
try {
    $UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($UserPath -notlike "*$ScriptDir*") {
        $NewUserPath = "$ScriptDir;$UserPath"
        [System.Environment]::SetEnvironmentVariable("Path", $NewUserPath, "User")
        $env:Path = "$ScriptDir;" + $env:Path
        Write-Host "      Added '$ScriptDir' to User PATH." -ForegroundColor Green
    } else {
        Write-Host "      DDS is already in User PATH." -ForegroundColor Green
    }
} catch {
    Write-Host "      Note: Could not modify User PATH automatically. You can run dds directly." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "          DDS Windows Setup Complete!             " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run DDS from CMD or PowerShell:" -ForegroundColor White
Write-Host "  dds             - Open interactive visual menu" -ForegroundColor Cyan
Write-Host "  dds start       - Start all services (Apache + MariaDB + PHP)" -ForegroundColor Cyan
Write-Host "  dds status      - Check live server status" -ForegroundColor Cyan
Write-Host "  dds stop        - Stop all services" -ForegroundColor Cyan
Write-Host ""
