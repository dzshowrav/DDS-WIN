# DDS (Dev Server Stack) for Windows & Termux

[![GitHub License](https://img.shields.io/github/license/dzshowrav/DZDEV-SERVER-dds?label=License)](https://github.com/dzshowrav/DZDEV-SERVER-dds/blob/main/LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/dzshowrav/DZDEV-SERVER-dds/main/assets/screenshot.jpg" alt="DDS Screenshot" width="600">
</p>

**DDS** is a modern, lightweight, visual CLI-based local web server management stack for **Windows (CMD & PowerShell)** and **Android (Termux)**. It provides a complete LAMP/WAMP-like environment featuring **Apache httpd**, **MariaDB / MySQL**, **PHP 8 (FastCGI)**, **phpMyAdmin**, and an interactive animated terminal interface.

---

## ✨ Features

- **Interactive Visual CLI** — Beautiful terminal menu with real-time animated service badges (no need to memorize commands)
- **Apache HTTP Server** — High-performance web server on port `8080` (HTTP) and `8443` (HTTPS / SSL)
- **MariaDB / MySQL Database** — Fast SQL database on port `3306` with root access configured out of the box
- **PHP 8 (FastCGI)** — FastCGI daemon on `127.0.0.1:9000` via `mod_proxy_fcgi` for high performance
- **phpMyAdmin** — Web-based database management interface pre-configured at `/phpmyadmin`
- **Virtual Host Manager** — Interactive management for multiple sites with custom ports and document roots
- **Live Status & Quick Links** — Real-time health monitoring with clickable browser launch actions
- **Cross-Shell Support** — Native support for Windows **CMD**, **PowerShell**, **Windows Terminal**, and **Git Bash**
- **Persistent JSON Config** — Configuration saved in `hosts.json`

---

## 🚀 Quick Start on Windows

### Prerequisites
- Windows 10 / 11
- [Node.js](https://nodejs.org/) (installed automatically by setup if missing)

### Installation

1. Open **Command Prompt (CMD)** or **PowerShell** as Administrator or regular user.
2. Navigate to the project directory:
   ```cmd
   cd "E:\DZDEV\DDS WIN"
   ```
3. Run the setup installer:
   - **In CMD:**
     ```cmd
     setup.bat
     ```
   - **In PowerShell:**
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\setup.ps1
     ```
4. Once completed, `dds` is registered in your User `PATH`. You can run `dds` from any folder!

5. Launch DDS:
   ```cmd
   dds
   ```

---

## 🖥️ Visual CLI Interface

Running `dds` without arguments opens the full interactive visual terminal:

```
██████╗ ██████╗ ███████╗
██╔══██╗██╔══██╗██╔════╝
██║  ██║██║  ██║███████╗
██║  ██║██║  ██║╚════██║
██████╔╝██████╔╝███████║
╚═════╝ ╚═════╝ ╚══════╝
═══════════════════════════
   Windows · Apache · MariaDB · PHP
       ●  ACTIVE · Apache + MariaDB + PHP · ◜

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

---

## 📖 CLI Commands Reference

You can use the interactive menu or run direct commands:

| Command | Description |
|---|---|
| `dds` | Open interactive visual menu |
| `dds start` | Start all services (Apache on :8080, MariaDB on :3306, PHP FastCGI) |
| `dds start-ssl` | Start with HTTPS SSL enabled (:8443) |
| `dds stop` | Gracefully stop all running services |
| `dds restart` | Gracefully restart all services |
| `dds status` | Display live status dashboard and quick browser links |
| `dds hosts` | Open interactive Virtual Host Manager |
| `dds root` | Change the default document root path |
| `dds pma` | Directly open phpMyAdmin in your default browser |
| `dds open` | Open the current document root in Windows File Explorer |
| `dds update` | Update DDS configurations and dependencies |
| `dds uninstall` | Stop all services and clean up temporary files |
| `dds help` | Display command help |

---

## 🌐 Virtual Hosts

DDS allows hosting multiple independent websites on custom ports.

### Managing Hosts via CLI:
```cmd
dds hosts
```
Options available:
- **Create Host**: Specify name, port (e.g. `8082`), and directory path (e.g. `C:/DDS/Projects/mysite`).
- **Edit Host**: Modify port or document root.
- **Delete Host**: Remove virtual host configuration.

Apache automatically reloads without service interruption whenever changes are made.

---

## 🗄️ Database & phpMyAdmin

- **phpMyAdmin URL**: `http://localhost:8080/phpmyadmin/`
- **Database Server**: `127.0.0.1:3306`
- **User**: `root`
- **Password**: *(empty / no password needed by default)*

To connect via PHP script:
```php
<?php
$conn = new mysqli('127.0.0.1', 'root', '', 'test_db');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to MariaDB/MySQL!";
?>
```

---

## 📁 Directory Structure

```
DDS/
├── dds.cmd         # CMD launcher wrapper
├── dds.bat         # Batch launcher wrapper
├── dds.ps1         # PowerShell launcher
├── dds             # Universal bash launcher (Git Bash / Linux / Termux)
├── setup.bat       # Windows CMD installer
├── setup.ps1       # Windows PowerShell installer
├── update.bat      # Windows CMD updater
├── update.ps1      # Windows PowerShell updater
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
| Port 8080 or 3306 is in use | Stop any other local servers (e.g. IIS, Skype, old XAMPP) or create a custom host with a different port via `dds hosts`. |
| Execution Policy error in PowerShell | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` or use `dds.cmd`. |
| phpMyAdmin shows connection error | Run `dds restart` to ensure MariaDB is running on port 3306. |

---

## 📄 License

DDS is licensed under the [GNU General Public License v3.0](LICENSE).
