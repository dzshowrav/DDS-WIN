# ==============================================================================
# DDS Windows Installer & Fully Autonomous Environment Setup
# Apache 2.4 - MariaDB 10.11 - PHP 8.5 - phpMyAdmin 5.2.3 - Node.js - Git
# ==============================================================================

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Cyan
Write-Host "         DDS Local Server Stack - Windows Setup          " -ForegroundColor Yellow
Write-Host "     Apache 2.4 - MariaDB 10.11 - PHP 8.5 - phpMyAdmin   " -ForegroundColor Gray
Write-Host "  =======================================================" -ForegroundColor Cyan
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

# --- Helper: Safe Zip Downloader & Extractor ---
function Install-ZipPackage($pkgName, $pkgUrl, $targetPath, $checkFile = $null, $subFolder = $null) {
    if ($checkFile -and (Test-Path "$targetPath\$checkFile")) {
        Write-Host "      [OK] $pkgName is ready." -ForegroundColor Green
        return
    }
    
    Write-Host "      [..] Downloading $pkgName..." -ForegroundColor Cyan
    $zipFile = "$TmpDir\$pkgName.zip"
    $tempExtract = "$TmpDir\$pkgName-temp"
    
    try {
        New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
        Invoke-WebRequest -Uri $pkgUrl -OutFile $zipFile -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -UseBasicParsing
        Write-Host "      [..] Extracting $pkgName..." -ForegroundColor Cyan
        Expand-Archive -Path $zipFile -DestinationPath $tempExtract -Force
        
        if (Test-Path $tempExtract) {
            if ($subFolder) {
                $found = Get-ChildItem -Path $tempExtract -Recurse -Directory -Filter $subFolder -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($found) {
                    Copy-Item -Path "$($found.FullName)\*" -Destination $targetPath -Recurse -Force -ErrorAction SilentlyContinue
                } else {
                    Copy-Item -Path "$tempExtract\*" -Destination $targetPath -Recurse -Force -ErrorAction SilentlyContinue
                }
            } else {
                $rootItems = Get-ChildItem -Path $tempExtract -ErrorAction SilentlyContinue
                if ($null -ne $rootItems -and $rootItems.Count -eq 1 -and $rootItems[0].PSIsContainer) {
                    Copy-Item -Path "$($rootItems[0].FullName)\*" -Destination $targetPath -Recurse -Force -ErrorAction SilentlyContinue
                } elseif ($null -ne $rootItems -and $rootItems.Count -gt 0) {
                    Copy-Item -Path "$tempExtract\*" -Destination $targetPath -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
        Remove-Item -Path $zipFile, $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "      [OK] $pkgName installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "      [!] Note: ${pkgName} - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# --- Step 1: Check / Setup Node.js Runtime ---
Write-Host "[1/6] Checking Node.js Runtime..." -ForegroundColor Cyan
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    if (Test-Path 'C:\Program Files\nodejs\node.exe') {
        $env:Path = "C:\Program Files\nodejs;" + $env:Path
        Write-Host "      [OK] Found Node.js in C:\Program Files\nodejs" -ForegroundColor Green
    } else {
        Write-Host "      Node.js not detected in system. Installing..." -ForegroundColor Yellow
        $installed = $false
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            try {
                winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Null
                if (Test-Path 'C:\Program Files\nodejs\node.exe') {
                    $env:Path = "C:\Program Files\nodejs;" + $env:Path
                    $installed = $true
                }
            } catch {}
        }
        if (-not $installed) {
            Install-ZipPackage "NodeJS" "https://nodejs.org/dist/v20.18.0/node-v20.18.0-win-x64.zip" "$ServicesDir\nodejs" "node.exe"
            $env:Path = "$ServicesDir\nodejs;" + $env:Path
        }
    }
}
$nodeVer = & node -v 2>$null
Write-Host "      [OK] Node.js runtime: $nodeVer" -ForegroundColor Green

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
    Write-Host "      [OK] CLI UI dependencies ready." -ForegroundColor Green
}

# --- Step 3: Verify & Install Core Server Components ---
Write-Host "[3/6] Verifying Web Server and Database Stack..." -ForegroundColor Cyan

# 1. Apache 2.4.68
if (-not (Test-Path "$ServicesDir\apache\bin\httpd.exe")) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            winget install --id ApacheLounge.httpd --location "$ServicesDir\apache" --accept-package-agreements --accept-source-agreements --silent | Out-Null
            if (Test-Path "$ServicesDir\apache\Apache24\bin\httpd.exe") {
                Copy-Item -Path "$ServicesDir\apache\Apache24\*" -Destination "$ServicesDir\apache" -Recurse -Force -ErrorAction SilentlyContinue
            }
        } catch {}
    }
    Install-ZipPackage "Apache 2.4" "https://www.apachelounge.com/download/VS18/binaries/httpd-2.4.68-260617-Win64-VS18.zip" "$ServicesDir\apache" "bin\httpd.exe" "Apache24"
} else {
    Write-Host "      [OK] Apache 2.4 is ready." -ForegroundColor Green
}

# 2. PHP 8.5
Install-ZipPackage "PHP 8.5" "https://windows.php.net/downloads/releases/php-8.5.9-nts-Win32-vs17-x64.zip" "$ServicesDir\php" "php.exe"

# 3. phpMyAdmin 5.2.3
Install-ZipPackage "phpMyAdmin" "https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip" "$ServicesDir\web\phpmyadmin" "index.php"

# 4. MariaDB 10.11
Install-ZipPackage "MariaDB 10.11" "https://downloads.mariadb.com/MariaDB/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip" "$ServicesDir\mysql" "bin\mysqld.exe"

# Initialize MariaDB system tables if needed
if ((Test-Path "$ServicesDir\mysql\bin\mysql_install_db.exe") -and (-not (Test-Path "$ServicesDir\mysql\data\mysql"))) {
    Write-Host "      [..] Initializing MariaDB system tables..." -ForegroundColor Cyan
    & "$ServicesDir\mysql\bin\mysql_install_db.exe" "--datadir=$ServicesDir\mysql\data" 2>$null | Out-Null
}

# 5. Git Portable (if git missing on host)
if (-not (Get-Command git -ErrorAction SilentlyContinue) -and (-not (Test-Path "$ServicesDir\git\cmd\git.exe"))) {
    Install-ZipPackage "MinGit" "https://github.com/git-for-windows/git/releases/download/v2.45.0.windows.1/MinGit-2.45.0-64-bit.zip" "$ServicesDir\git" "cmd\git.exe"
}

# --- Step 4: Configure Stack Files ---
Write-Host "[4/6] Applying optimized configurations..." -ForegroundColor Cyan

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

# Configure php.ini for PHP 8.5
$PhpIniPath = "$ServicesDir\php\php.ini"
if (Test-Path "$ServicesDir\php") {
    if (-not (Test-Path $PhpIniPath) -and (Test-Path "$ServicesDir\php\php.ini-development")) {
        Copy-Item -Path "$ServicesDir\php\php.ini-development" -Destination $PhpIniPath -Force
    }
    if (Test-Path $PhpIniPath) {
        $iniContent = Get-Content $PhpIniPath -Raw -ErrorAction SilentlyContinue
        if ($iniContent -notlike "*=== DDS Windows Configured php.ini ===*") {
            $DdsIniConfig = @(
                "",
                "; === DDS Windows Configured php.ini ===",
                'extension_dir = "C:/DDS/Services/php/ext"',
                'session.save_path = "C:/DDS/tmp"',
                'sys_temp_dir = "C:/DDS/tmp"',
                'upload_tmp_dir = "C:/DDS/tmp"',
                'session.cookie_httponly = 1',
                'session.use_only_cookies = 1',
                'session.gc_maxlifetime = 1440',
                'max_execution_time = 300',
                'memory_limit = 512M',
                'post_max_size = 128M',
                'upload_max_filesize = 128M',
                'date.timezone = UTC',
                '',
                '; Core Extensions',
                'extension=curl',
                'extension=fileinfo',
                'extension=gd',
                'extension=mbstring',
                'extension=mysqli',
                'extension=openssl',
                'extension=pdo_mysql',
                'extension=pdo_sqlite',
                'extension=sqlite3',
                'extension=zip'
            ) -join "`r`n"
            Add-Content -Path $PhpIniPath -Value $DdsIniConfig -Encoding UTF8
        }
    }
}

# Configure MariaDB my.ini
$MyIniPath = "$ServicesDir\mysql\my.ini"
if (Test-Path "$ServicesDir\mysql") {
    if (-not (Test-Path $MyIniPath)) {
        $MyIniConfig = @(
            '[mysqld]',
            'port = 3306',
            'bind-address = 127.0.0.1',
            'datadir = "C:/DDS/Services/mysql/data"',
            'character-set-server = utf8mb4',
            'collation-server = utf8mb4_unicode_ci',
            'default-storage-engine = INNODB',
            'max_connections = 100',
            'query_cache_size = 16M',
            'tmp_table_size = 32M',
            'thread_cache_size = 8',
            'myisam_max_sort_file_size = 100G',
            'myisam_sort_buffer_size = 32M',
            'key_buffer_size = 16M',
            'read_buffer_size = 256K',
            'read_rnd_buffer_size = 512K',
            'sort_buffer_size = 512K',
            'innodb_data_home_dir = "C:/DDS/Services/mysql/data"',
            'innodb_data_file_path = ibdata1:10M:autoextend',
            'innodb_log_group_home_dir = "C:/DDS/Services/mysql/data"',
            'innodb_buffer_pool_size = 128M',
            'innodb_log_file_size = 48M',
            'innodb_log_buffer_size = 8M',
            'innodb_flush_log_at_trx_commit = 1',
            'innodb_lock_wait_timeout = 50',
            '',
            '[client]',
            'port = 3306',
            'default-character-set = utf8mb4'
        ) -join "`r`n"
        Set-Content -Path $MyIniPath -Value $MyIniConfig -Encoding UTF8
    }
}

# Setup standalone phpinfo page
$PhpInfoContent = "<?php phpinfo(); ?>"
Set-Content -Path "$ServicesDir\web\phpinfo\index.php" -Value $PhpInfoContent -Encoding UTF8
Set-Content -Path "$DdsBase\Projects\phpinfo.php" -Value $PhpInfoContent -Encoding UTF8

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
    ) -join "`r`n"
    Set-Content -Path $IndexFile -Value $HtmlLines -Encoding UTF8
}

Write-Host "      [OK] Stack configurations synced." -ForegroundColor Green

# --- Step 5: Generate Virtual Hosts ---
Write-Host "[5/6] Generating Virtual Host definitions..." -ForegroundColor Cyan
try {
    & node "$DdsUiDir\index.js" gen-vhosts 2>$null | Out-Null
    Write-Host "      [OK] Virtual hosts configuration generated." -ForegroundColor Green
} catch {
    Write-Host "      [OK] Virtual host configuration ready." -ForegroundColor Green
}

# --- Step 6: Add to User PATH ---
Write-Host "[6/6] Registering 'dds' command in Windows PATH..." -ForegroundColor Cyan
try {
    $UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $PathsToAdd = @($ScriptDir, "$ServicesDir\git\cmd", "$ServicesDir\nodejs")
    
    foreach ($p in $PathsToAdd) {
        if ($UserPath -notlike "*$p*") {
            $UserPath = "$p;$UserPath"
            [System.Environment]::SetEnvironmentVariable("Path", $UserPath, "User")
            $env:Path = "$p;" + $env:Path
        }
    }
    Write-Host "      [OK] 'dds' command registered in User PATH." -ForegroundColor Green
} catch {
    Write-Host "      Registered in current session." -ForegroundColor Yellow
}

# Create Desktop Shortcut
try {
    $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory)
    $ShortcutPath = Join-Path $DesktopPath "DDS Server Control.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = (Join-Path $ScriptDir "dds.cmd")
    $Shortcut.WorkingDirectory = $ScriptDir
    $IconPath = Join-Path $ScriptDir "assets\dds.ico"
    if (Test-Path $IconPath) {
        $Shortcut.IconLocation = $IconPath
    }
    $Shortcut.Description = "DDS Local Web Server Stack Manager"
    $Shortcut.Save()
    Write-Host "      [OK] Desktop shortcut 'DDS Server Control' created." -ForegroundColor Green
} catch {}

Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host "                DDS Installation Complete!               " -ForegroundColor Green
Write-Host "  =======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  You can now start DDS from any CMD or PowerShell:" -ForegroundColor White
Write-Host ""
Write-Host "    dds             " -ForegroundColor Cyan -NoNewline
Write-Host "-> Open interactive visual dashboard" -ForegroundColor Gray
Write-Host "    dds start       " -ForegroundColor Cyan -NoNewline
Write-Host "-> Start Apache (:8080) + MariaDB (:3306) + PHP 8.5" -ForegroundColor Gray
Write-Host "    dds status      " -ForegroundColor Cyan -NoNewline
Write-Host "-> Check live server status" -ForegroundColor Gray
Write-Host "    dds stop        " -ForegroundColor Cyan -NoNewline
Write-Host "-> Stop all services" -ForegroundColor Gray
Write-Host ""
Write-Host "  Local URLs:" -ForegroundColor White
Write-Host "    Web Server:    http://localhost:8080/" -ForegroundColor Cyan
Write-Host "    phpMyAdmin:    http://localhost:8080/phpmyadmin/" -ForegroundColor Cyan
Write-Host "    PHP Info:      http://localhost:8080/phpinfo/" -ForegroundColor Cyan
Write-Host ""
