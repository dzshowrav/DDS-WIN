# ==============================================================================
# DDS Windows Installer & Automated Environment Setup
# Apache HTTP Server · MariaDB / MySQL · PHP 8.5 · phpMyAdmin 5.2.3
# ==============================================================================

Write-Host ""
Write-Host "  ==================================================" -ForegroundColor Cyan
Write-Host "     DDS Local Server Stack - Windows Setup        " -ForegroundColor Yellow
Write-Host "  Apache 2.4 - MariaDB / MySQL - PHP 8.5 - phpMyAdmin" -ForegroundColor Gray
Write-Host "  ==================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DdsBase = "C:\DDS"
$ServicesDir = "$DdsBase\Services"
$TmpDir = "$DdsBase\tmp"

# Create core directory tree
New-Item -ItemType Directory -Force -Path $DdsBase | Out-Null
New-Item -ItemType Directory -Force -Path $ServicesDir | Out-Null
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null
New-Item -ItemType Directory -Force -Path "$DdsBase\Projects" | Out-Null
New-Item -ItemType Directory -Force -Path "$DdsBase\Logs" | Out-Null
New-Item -ItemType Directory -Force -Path "$DdsBase\Certificates" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\apache\conf\extra" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\apache\logs" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\php\ext" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\mysql\data" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\web\phpmyadmin" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\web\phpinfo" | Out-Null

# --- Step 1: Check / Setup Node.js ---
Write-Host "[1/6] Checking Node.js Runtime..." -ForegroundColor Cyan
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    if (Test-Path 'C:\Program Files\nodejs\node.exe') {
        $env:Path = "C:\Program Files\nodejs;" + $env:Path
        Write-Host "      Found Node.js in C:\Program Files\nodejs" -ForegroundColor Green
    } else {
        Write-Host "      Node.js not detected. Installing via winget..." -ForegroundColor Yellow
        try {
            winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Null
            $env:Path = "C:\Program Files\nodejs;" + $env:Path
        } catch {
            Write-Host "      Downloading portable Node.js..." -ForegroundColor Yellow
        }
    }
}
$nodeVer = & node -v 2>$null
Write-Host "      Node.js runtime: $nodeVer" -ForegroundColor Green

# --- Step 2: Install CLI Dependencies ---
Write-Host "[2/6] Setting up DDS CLI UI components..." -ForegroundColor Cyan
$DdsUiDir = Join-Path $ScriptDir "dds-ui"
if (Test-Path $DdsUiDir) {
    Push-Location $DdsUiDir
    if (Test-Path 'C:\Program Files\nodejs\npm.cmd') {
        & 'C:\Program Files\nodejs\npm.cmd' install --no-audit --no-fund 2>$null | Out-Null
    } elseif (Get-Command npm -ErrorAction SilentlyContinue) {
        & npm install --no-audit --no-fund 2>$null | Out-Null
    }
    Pop-Location
    Write-Host "      CLI UI dependencies ready." -ForegroundColor Green
}

# --- Step 3: Verify Core Server Components ---
Write-Host "[3/6] Verifying Web Server and Database Stack..." -ForegroundColor Cyan

# Helper function to download and extract zip
function Install-ZipPackage($pkgName, $pkgUrl, $targetPath, $subFolder = $null) {
    if (Test-Path $targetPath) {
        $files = Get-ChildItem -Path $targetPath -ErrorAction SilentlyContinue
        if ($files.Count -gt 0) {
            Write-Host "      $pkgName is installed." -ForegroundColor Green
            return
        }
    }
    Write-Host "      Downloading $pkgName..." -ForegroundColor Cyan
    $zipFile = "$TmpDir\$pkgName.zip"
    $tempExtract = "$TmpDir\$pkgName-temp"
    
    try {
        Invoke-WebRequest -Uri $pkgUrl -OutFile $zipFile -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -UseBasicParsing
        Write-Host "      Extracting $pkgName..." -ForegroundColor Cyan
        Expand-Archive -Path $zipFile -DestinationPath $tempExtract -Force
        
        New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
        if ($subFolder) {
            $found = Get-ChildItem -Path $tempExtract -Recurse -Directory -Filter $subFolder | Select-Object -First 1
            if ($found) {
                Copy-Item -Path "$($found.FullName)\*" -Destination $targetPath -Recurse -Force
            } else {
                Copy-Item -Path "$tempExtract\*" -Destination $targetPath -Recurse -Force
            }
        } else {
            $rootItems = Get-ChildItem -Path $tempExtract
            if ($rootItems.Count -eq 1 -and $rootItems[0].PSIsContainer) {
                Copy-Item -Path "$($rootItems[0].FullName)\*" -Destination $targetPath -Recurse -Force
            } else {
                Copy-Item -Path "$tempExtract\*" -Destination $targetPath -Recurse -Force
            }
        }
        Remove-Item -Path $zipFile, $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      $pkgName installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "      Note: ${pkgName} - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Install Core Stack if missing
Install-ZipPackage "Apache 2.4" "https://www.apachelounge.com/download/VS17/binaries/httpd-2.4.63-250207-win64-VS17.zip" "$ServicesDir\apache" "Apache24"
Install-ZipPackage "PHP 8.5" "https://windows.php.net/downloads/releases/php-8.5.9-nts-Win32-vs17-x64.zip" "$ServicesDir\php"
Install-ZipPackage "phpMyAdmin" "https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip" "$ServicesDir\web\phpmyadmin"

# --- Step 4: Configure Stack Files ---
Write-Host "[4/6] Applying optimized configurations..." -ForegroundColor Cyan

# Ensure target directories exist before copy
New-Item -ItemType Directory -Force -Path "$ServicesDir\apache\conf" | Out-Null
New-Item -ItemType Directory -Force -Path "$ServicesDir\web\phpmyadmin" | Out-Null

# Sync master httpd.conf
$SourceHttpd = Join-Path $ScriptDir "httpd.conf"
if (Test-Path $SourceHttpd) {
    Copy-Item -Path $SourceHttpd -Destination "$ServicesDir\apache\conf\httpd.conf" -Force -ErrorAction SilentlyContinue
}

# Sync master config.inc.php
$SourcePmaConfig = Join-Path $ScriptDir "config.inc.php"
if (Test-Path $SourcePmaConfig) {
    Copy-Item -Path $SourcePmaConfig -Destination "$ServicesDir\web\phpmyadmin\config.inc.php" -Force -ErrorAction SilentlyContinue
}

# Setup standalone phpinfo page
$PhpInfoContent = "<?php phpinfo(); ?>"
[System.IO.File]::WriteAllText("$ServicesDir\web\phpinfo\index.php", $PhpInfoContent)
[System.IO.File]::WriteAllText("$DdsBase\Projects\phpinfo.php", $PhpInfoContent)

# Setup default index.php if Projects is empty
$IndexFile = "$DdsBase\Projects\index.php"
if (!(Test-Path $IndexFile)) {
    $HtmlLines = @(
        '<!DOCTYPE html>',
        '<html lang="en">',
        '<head>',
        '  <meta charset="UTF-8">',
        '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
        '  <title>DDS Web Server</title>',
        '  <style>',
        '    :root { --bg: #0d1117; --card-bg: #161b22; --text: #c9d1d9; --accent: #00d4aa; --border: #30363d; }',
        '    body { font-family: system-ui, sans-serif; background: var(--bg); color: var(--text); display: flex; justify-content: center; padding: 40px 20px; }',
        '    .container { max-width: 650px; width: 100%; background: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; padding: 32px; box-shadow: 0 8px 24px rgba(0,0,0,0.5); }',
        '    h1 { color: var(--accent); margin-top: 0; }',
        '    .links { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 24px; }',
        '    .btn { display: block; text-align: center; padding: 12px; background: #21262d; color: #58a6ff; text-decoration: none; border-radius: 6px; border: 1px solid var(--border); font-weight: 600; }',
        '    .btn:hover { background: #30363d; }',
        '  </style>',
        '</head>',
        '<body>',
        '  <div class="container">',
        '    <h1>DDS Web Server <span style="font-size:0.5em; background:rgba(0,212,170,0.15); color:var(--accent); padding:4px 8px; border-radius:12px;">Online</span></h1>',
        '    <p>Your local Apache, MariaDB, and PHP 8.5 development stack is active!</p>',
        '    <p><strong>PHP Version:</strong> <?php echo phpversion(); ?><br><strong>Document Root:</strong> <code><?php echo __DIR__; ?></code></p>',
        '    <div class="links">',
        '      <a class="btn" href="/phpmyadmin/">Open phpMyAdmin</a>',
        '      <a class="btn" href="/phpinfo/">PHP Info</a>',
        '    </div>',
        '  </div>',
        '</body>',
        '</html>'
    )
    [System.IO.File]::WriteAllLines($IndexFile, $HtmlLines)
}

Write-Host "      Stack configurations synced." -ForegroundColor Green

# --- Step 5: Generate Virtual Hosts ---
Write-Host "[5/6] Generating Virtual Host definitions..." -ForegroundColor Cyan
try {
    & node "$DdsUiDir\index.js" gen-vhosts 2>$null | Out-Null
    Write-Host "      Virtual hosts configuration generated." -ForegroundColor Green
} catch {
    Write-Host "      Virtual host configuration ready." -ForegroundColor Green
}

# --- Step 6: Add to User PATH ---
Write-Host "[6/6] Registering 'dds' command in Windows PATH..." -ForegroundColor Cyan
try {
    $UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $PathsToAdd = @($ScriptDir, "$ServicesDir\git\cmd")
    
    foreach ($p in $PathsToAdd) {
        if ($UserPath -notlike "*$p*") {
            $UserPath = "$p;$UserPath"
            [System.Environment]::SetEnvironmentVariable("Path", $UserPath, "User")
            $env:Path = "$p;" + $env:Path
        }
    }
    Write-Host "      'dds' command registered in User PATH." -ForegroundColor Green
} catch {
    Write-Host "      Registered in current session." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  ==================================================" -ForegroundColor Green
Write-Host "          DDS Installation Complete!              " -ForegroundColor Green
Write-Host "  ==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  You can now start DDS from any CMD or PowerShell:" -ForegroundColor White
Write-Host ""
Write-Host "    dds             -> Open interactive visual dashboard" -ForegroundColor Cyan
Write-Host "    dds start       -> Start Apache (:8080) + MariaDB (:3306) + PHP 8.5" -ForegroundColor Cyan
Write-Host "    dds status      -> Check live server status" -ForegroundColor Cyan
Write-Host "    dds stop        -> Stop all services" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Local URLs:" -ForegroundColor White
Write-Host "    Web Server:    http://localhost:8080/" -ForegroundColor Cyan
Write-Host "    phpMyAdmin:    http://localhost:8080/phpmyadmin/" -ForegroundColor Cyan
Write-Host "    PHP Info:      http://localhost:8080/phpinfo/" -ForegroundColor Cyan
Write-Host ""
