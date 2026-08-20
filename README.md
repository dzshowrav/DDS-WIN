# DDS (Dev Server Stack) for Windows

[![GitHub License](https://img.shields.io/github/license/dzshowrav/DZDEV-SERVER-dds?label=License)](https://github.com/dzshowrav/DZDEV-SERVER-dds/blob/main/LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/dzshowrav/DZDEV-SERVER-dds/main/assets/screenshot.jpg" alt="DDS Screenshot" width="600">
</p>

**DDS** is a modern, lightweight, visual CLI-based local web server management stack for **Windows (CMD, PowerShell, Windows Terminal)** and **Android (Termux)**. It provides a complete WAMP/LAMP-like environment featuring **Apache 2.4**, **MariaDB 10.11 / MySQL**, **PHP 8.5 (Latest Stable)**, **phpMyAdmin 5.2.3**, and an interactive animated terminal dashboard.

---

## ⚡ 3-Step Quick Install (For Beginners)

Prequites: install git before start setup.

No complex setup or manual package downloads required. The installer handles everything automatically:

### 1. Clone the repository
Open **Command Prompt (CMD)** or **PowerShell** and run:
```cmd
git clone https://github.com/dzshowrav/DDS-WIN.git dds
cd dds
```

### 2. Run the one-click installer
- **In CMD (or Double-Click in File Explorer)**:
  ```cmd
  setup.bat
  ```
- **In PowerShell**:
  ```powershell
  .\setup.ps1
  ```

### 3. Launch DDS!
```cmd
dds
```

---

## ✨ Features

- **Interactive Visual CLI** — Beautiful full-screen terminal UI with real-time animated service badges (no need to memorize commands).
- **Apache HTTP Server 2.4** — High-performance web server listening on port `8080` (HTTP) and `8443` (HTTPS / SSL).
- **MariaDB 10.11 / MySQL** — Fast SQL database on port `3306` with root access configured out of the box.
- **PHP 8.5 (Latest Stable)** — Pre-configured with `mysqli`, `pdo_mysql`, `mbstring`, `curl`, `gd`, `zip`, `openssl`, and `Zend OPcache`.
- **phpMyAdmin 5.2.3** — Web-based database management interface pre-configured at `/phpmyadmin` with passwordless local login.
- **Virtual Host Manager** — Interactively add, edit, and delete multiple websites with custom ports and document roots.
- **PHP Info Endpoint** — Built-in diagnostics at `/phpinfo/` and `/phpinfo.php`.
- **Cross-Shell Support** — Native support for **CMD**, **PowerShell**, **Windows Terminal**, and **Git Bash**.
- **Persistent JSON Config** — Configuration saved in `hosts.json`.

---

## 🖥️ Visual CLI Interface

Running `dds` without arguments opens the interactive terminal dashboard:

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

You can use the interactive menu or run direct subcommands from any folder:

| Command | Description |
|---|---|
| `dds` | Open interactive visual dashboard |
| `dds start` | Start all services (Apache on :8080, MariaDB on :3306, PHP 8.5) |
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

To connect from PHP:
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

## 📁 Directory Structure

```
DDS/
├── dds.cmd         # CMD launcher wrapper
├── dds.bat         # Batch launcher wrapper
├── dds.ps1         # PowerShell launcher
├── dds             # Universal bash launcher (Git Bash / Linux / Termux)
├── setup.bat       # Windows 1-Click CMD / Explorer installer
├── setup.ps1       # Windows automated PowerShell installer
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
| Port 8080 or 3306 is in use | Stop any other local servers (e.g. IIS, old XAMPP) or create a custom host with a different port via `dds hosts`. |
| Execution Policy error in PowerShell | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` or use `dds.cmd`. |
| phpMyAdmin shows session error | Run `dds restart` to ensure `C:\DDS\tmp` is active. |

---

## 📄 License

DDS is licensed under the [GNU General Public License v3.0](LICENSE).
