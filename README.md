# DDS (Dev Server Stack) for Windows & Android

[![GitHub License](https://img.shields.io/github/license/dzshowrav/DZDEV-SERVER-dds?label=License)](https://github.com/dzshowrav/DZDEV-SERVER-dds/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011%20%7C%20Termux-blue.svg)](https://github.com/dzshowrav/DDS-WIN)
[![PHP](https://img.shields.io/badge/PHP-8.5%20(Latest%20Stable)-8892BF.svg)](https://windows.php.net/)
[![Apache](https://img.shields.io/badge/Apache-2.4.68%20(Win64)-red.svg)](https://www.apachelounge.com/)
[![MariaDB](https://img.shields.io/badge/MariaDB-10.11%20%2F%20MySQL-003545.svg)](https://mariadb.org/)
[![phpMyAdmin](https://img.shields.io/badge/phpMyAdmin-5.2.3-orange.svg)](https://www.phpmyadmin.net/)

<p align="center">
  <img src="https://raw.githubusercontent.com/dzshowrav/DDS-WIN/main/assets/logo.png" alt="DDS Brand Logo" width="200">
</p>

**DDS** is a modern, lightweight, visual CLI-based local web development stack for **Windows (CMD, PowerShell, Windows Terminal)** and **Android (Termux)**. It provides a complete WAMP/LAMP-like environment featuring **Apache 2.4**, **MariaDB 10.11 / MySQL**, **PHP 8.5 (Latest Stable NTS)**, **phpMyAdmin 5.2.3**, and an interactive animated terminal dashboard.

---

## ⚡ Easy Installation Methods

Choose any of the following options:

### 🌟 Option 1: 1-Click Batch Installer (`.bat` / Recommended)
1. Clone or download the repository ZIP.
2. Double-click **`setup.bat`** (or **`install.bat`**).
3. Everything (Node.js, Apache 2.4, MariaDB 10.11, PHP 8.5, phpMyAdmin 5.2.3) is downloaded, configured, and a Desktop shortcut is created automatically!

---

### 💻 Option 2: 1-Line PowerShell Web Installer
Open **PowerShell** and paste:
```powershell
irm https://raw.githubusercontent.com/dzshowrav/DDS-WIN/main/install.ps1 | iex
```

---

### 🐙 Option 3: Standard Git Clone & CLI Setup
```cmd
git clone https://github.com/dzshowrav/DDS-WIN.git dds
cd dds
setup.bat
```

*Then simply type `dds` in any terminal window to launch!*

---

## 📂 Windows `.bat` / `.cmd` Shortcuts Reference

| Batch File | How to Use | Purpose |
|---|---|---|
| **`setup.bat`** | Double-Click | 1-Click automated full stack installation and environment setup |
| **`install.bat`** | Double-Click | Standalone web downloader and installer |
| **`dds.bat`** / **`dds.cmd`** | Double-Click | Launch interactive visual CLI dashboard |
| **`uninstall.bat`** | Double-Click | 100% clean, deep uninstaller (removes services, binaries, and PATH) |
| **`update.bat`** | Double-Click | Pull latest GitHub updates and reload Apache virtual hosts |

---

## ✨ Features

- **Interactive Visual CLI** — Full-screen terminal dashboard with real-time animated service badges (no need to memorize commands).
- **Apache HTTP Server 2.4** — High-performance web server listening on port `8080` (HTTP) and `8443` (HTTPS / SSL).
- **MariaDB 10.11 / MySQL** — Fast SQL database on port `3306` with root access configured out of the box.
- **PHP 8.5 (Latest Stable)** — Pre-configured with `mysqli`, `pdo_mysql`, `mbstring`, `curl`, `gd`, `zip`, `openssl`, `fileinfo`, `sqlite3`, and `Zend OPcache`.
- **phpMyAdmin 5.2.3** — Web-based database management interface pre-configured at `/phpmyadmin/` with passwordless local login.
- **Virtual Host Manager** — Interactively add, edit, and delete multiple websites with custom ports and document roots.
- **PHP Info Endpoint** — Built-in diagnostics at `/phpinfo/` and `/phpinfo.php`.
- **Cross-Shell Support** — Native support for **CMD**, **PowerShell**, **Windows Terminal**, and **Git Bash**.
- **Persistent JSON Config** — Configuration saved in `hosts.json`.

---

## 🖥️ Visual CLI Interface

Running `dds` without arguments opens the full interactive visual terminal:

```text
██████╗ ██████╗ ███████╗
██╔══██╗██╔══██╗██╔════╝
██║  ██║██║  ██║███████╗
██║  ██║██║  ██║╚════██║
██████╔╝██████╔╝███████║
╚═════╝ ╚═════╝ ╚══════╝
═══════════════════════════════════════
   Windows · Apache · MariaDB · PHP 8.5
       ●  ACTIVE · Apache + MariaDB · ◜

  ❯ Start DDS
    Start SSL
    Stop DDS
    Restart DDS
    Status
    Host Manager
    Change Root
    phpMyAdmin
    Open in Explorer
    Update DDS
    Uninstall
    Exit
```

*Navigate with arrow keys and press Enter to select.*

---

## 📖 CLI Commands Reference

You can use the interactive menu or run direct subcommands from any directory:

| Command | Description |
|---|---|
| `dds` | Open interactive visual dashboard |
| `dds start` | Start all services (Apache on :8080, MariaDB on :3306, PHP 8.5) |
| `dds start-ssl` | Start with HTTPS SSL enabled (:8443) |
| `dds stop` | Gracefully stop all running services |
| `dds restart` | Gracefully restart all services |
| `dds status` | Display live status dashboard and quick browser links |
| `dds hosts` | Open interactive Virtual Host Manager |
| `dds root [path]` | Change the default document root path |
| `dds pma` | Directly open phpMyAdmin in your default browser |
| `dds open` | Open the current document root in Windows File Explorer |
| `dds update` | Update DDS configurations and dependencies |
| `dds uninstall` | 100% clean uninstallation (stops processes, removes files & PATH) |
| `dds help` | Display command help |

---

## 🌐 Virtual Hosts

DDS allows hosting multiple independent websites simultaneously on custom ports.

### Managing Hosts via CLI:
```cmd
dds hosts
```
Options available:
- **Create Host**: Specify site name, custom port (e.g. `8082`), and directory path (e.g. `C:/DDS/Projects/mysite`).
- **Edit Host**: Modify port or document root.
- **Delete Host**: Remove virtual host configuration.

Apache automatically reloads without interrupting active connections whenever changes are made.

---

## 🗄️ Database & phpMyAdmin

- **phpMyAdmin URL**: `http://localhost:8080/phpmyadmin/`
- **Database Server**: `127.0.0.1:3306`
- **User**: `root`
- **Password**: *(empty / no password needed by default)*

### Connecting from PHP:
```php
<?php
$conn = new mysqli('127.0.0.1', 'root', '', 'test_db');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to MariaDB / MySQL!";
?>
```

---

## 🗑️ Complete Uninstallation

To completely remove DDS and all its installed runtime binaries, services, caches, and Windows PATH entries:

1. **Via CLI**:
   ```cmd
   dds uninstall
   ```
2. **Via Batch File**:
   Double-click **`uninstall.bat`** in the DDS folder.

The uninstaller will:
- Terminate all running Apache, MariaDB, and PHP processes.
- Clean and restore the Windows User `PATH` environment variable.
- Delete `C:\DDS\Services`, `C:\DDS\Logs`, `C:\DDS\Certificates`, and `C:\DDS\tmp`.
- Ask if you want to wipe or preserve your website files in `C:\DDS\Projects`.

---

## 📁 Directory Structure

```
DDS/
├── assets/         # Brand logos & multi-res ICO files
├── dds.cmd         # CMD launcher wrapper
├── dds.bat         # Batch launcher wrapper
├── dds.ps1         # PowerShell launcher
├── dds             # Universal bash launcher (Git Bash / Linux / Termux)
├── setup.bat       # Windows 1-Click CMD / Explorer installer
├── setup.ps1       # Windows automated PowerShell installer
├── install.bat     # Windows easy batch installer
├── install.cmd     # Windows easy cmd installer
├── install.ps1     # Windows 1-line PowerShell web installer
├── update.bat      # Windows CMD updater
├── update.ps1      # Windows PowerShell updater
├── uninstall.bat   # Windows 1-Click clean uninstaller
├── uninstall.ps1   # Windows automated PowerShell uninstaller
├── httpd.conf      # Master Apache configuration template
├── config.inc.php  # phpMyAdmin configuration template
├── hosts.json      # Virtual host definition storage
├── dds-ui/         # Interactive Node.js CLI engine
│   ├── index.js    # Entry point & argument parser
│   ├── menu.js     # Inquirer interactive main menu
│   ├── logo.js     # ASCII banner & live pulse badge
│   ├── commands.js # All command implementations
│   ├── services.js # Process management & TCP health checks
│   ├── hosts.js    # Virtual host CRUD layer
│   ├── vhost.js    # Apache vhosts config generator
│   └── config.js   # Cross-platform path resolver
└── Projects/       # Default web root (htdocs)
```

---

## 🔒 HTTPS / SSL Support

Start DDS with SSL enabled:
```cmd
dds start-ssl
```
- **HTTP**: `http://localhost:8080/`
- **HTTPS**: `https://localhost:8443/`

---

## 🛠️ Troubleshooting

| Issue | Resolution |
|---|---|
| `dds` not recognized in new terminal | Re-open your terminal window so the updated User `PATH` takes effect, or run `setup.bat`. |
| Port 8080 or 3306 is in use | Stop any other local servers (e.g. IIS, old XAMPP) or create a custom host with a different port via `dds hosts`. |
| Execution Policy error in PowerShell | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` or use `dds.cmd` / `dds.bat`. |
| phpMyAdmin shows session error | Run `dds restart` to ensure `C:\DDS\tmp` is active. |

---

## 📄 License

DDS is licensed under the [GNU General Public License v3.0](LICENSE).
