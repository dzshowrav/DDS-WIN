import { execSync, spawn } from 'child_process';
import net from 'net';
import fs from 'fs';
import path from 'path';
import { isWindows, PATHS, PORTS, toApachePath, ensureDir } from './config.js';

// Check if a TCP port is actively listening
export function isPortInUse(port, host = '127.0.0.1') {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    socket.setTimeout(400);

    socket.on('connect', () => {
      socket.destroy();
      resolve(true);
    });

    socket.on('timeout', () => {
      socket.destroy();
      resolve(false);
    });

    socket.on('error', () => {
      socket.destroy();
      resolve(false);
    });

    socket.connect(port, host);
  });
}

// Get process list for image name
export function getProcessList(imageName) {
  try {
    if (isWindows) {
      const out = execSync(`tasklist /FI "IMAGENAME eq ${imageName}" /FO CSV /NH`, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
      const lines = out.trim().split('\n').filter(l => l.includes(imageName));
      return lines.map(line => {
        const parts = line.split(',').map(p => p.replace(/"/g, '').trim());
        return parts[1] || '';
      }).filter(Boolean);
    } else {
      const cmdName = imageName.replace(/\.exe$/, '');
      const out = execSync(`pgrep -f ${cmdName}`, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
      return out ? out.split('\n').map(s => s.trim()) : [];
    }
  } catch {
    return [];
  }
}

// Kill process by name
export function killProcessByName(imageName) {
  try {
    if (isWindows) {
      execSync(`taskkill /F /IM ${imageName}`, { stdio: 'ignore' });
    } else {
      const cmdName = imageName.replace(/\.exe$/, '');
      execSync(`pkill -9 ${cmdName} 2>/dev/null || true`, { stdio: 'ignore' });
    }
    return true;
  } catch {
    return false;
  }
}

// ==========================================
// Apache HTTP Server + PHP Module Service
// ==========================================
export async function isApacheRunning() {
  const portUsed = await isPortInUse(PORTS.apache);
  if (portUsed) return true;
  const pids = getProcessList(isWindows ? 'httpd.exe' : 'httpd');
  return pids.length > 0;
}

export function getApachePids() {
  return getProcessList(isWindows ? 'httpd.exe' : 'httpd');
}

export async function isPhpRunning() {
  return await isApacheRunning();
}

export function getPhpPids() {
  return getApachePids();
}

export async function startApache(ssl = false) {
  if (await isApacheRunning()) return true;

  if (isWindows) {
    const apacheBin = PATHS.apacheBin;
    const apacheConf = PATHS.apacheConf;
    
    if (!fs.existsSync(apacheBin)) {
      throw new Error(`Apache binary not found at "${apacheBin}". Please run setup.bat to install.`);
    }

    // Test config syntax first
    try {
      execSync(`"${apacheBin}" -t -f "${apacheConf}"`, { stdio: 'pipe' });
    } catch (err) {
      const msg = (err.stderr || err.stdout || err.message || '').toString();
      throw new Error(`Apache configuration error: ${msg.trim()}`);
    }

    const child = spawn(apacheBin, ['-f', apacheConf], {
      detached: true,
      stdio: 'ignore',
      windowsHide: true,
    });
    child.unref();
  } else {
    try {
      execSync('apachectl start 2>/dev/null', { stdio: 'ignore' });
    } catch {
      throw new Error('Apache failed to start');
    }
  }

  // Poll until active
  for (let i = 0; i < 15; i++) {
    await new Promise(r => setTimeout(r, 400));
    if (await isApacheRunning()) return true;
  }
  return false;
}

export async function stopApache() {
  if (isWindows) {
    killProcessByName('httpd.exe');
  } else {
    try { execSync('apachectl stop 2>/dev/null', { stdio: 'ignore' }); } catch {}
  }

  for (let i = 0; i < 8; i++) {
    await new Promise(r => setTimeout(r, 300));
    if (!(await isApacheRunning())) return true;
  }
  return true;
}

export async function restartApache() {
  await stopApache();
  await new Promise(r => setTimeout(r, 600));
  return await startApache();
}

export async function reloadApache() {
  return await restartApache();
}

// ==========================================
// MySQL / MariaDB Service
// ==========================================
export async function isMysqlRunning() {
  const portUsed = await isPortInUse(PORTS.mysql);
  if (portUsed) return true;
  const pids = getProcessList(isWindows ? 'mysqld.exe' : 'mariadbd');
  return pids.length > 0;
}

export function getMysqlPids() {
  const list = getProcessList(isWindows ? 'mysqld.exe' : 'mariadbd');
  if (list.length === 0 && isWindows) {
    return getProcessList('mariadbd.exe');
  }
  return list;
}

export async function startMysql() {
  if (await isMysqlRunning()) return true;

  if (isWindows) {
    const mysqlBin = PATHS.mysqlBin;
    const mysqlIni = PATHS.mysqlIni;
    if (!fs.existsSync(mysqlBin)) {
      throw new Error(`MariaDB binary not found at "${mysqlBin}". Please run setup.bat to install.`);
    }
    const args = fs.existsSync(mysqlIni) ? [`--defaults-file=${mysqlIni}`] : [];
    const child = spawn(mysqlBin, args, {
      detached: true,
      stdio: 'ignore',
      windowsHide: true,
    });
    child.unref();
  } else {
    try {
      execSync(`mariadbd-safe --pid-file="${PATHS.mysqlPidFile}" &`, { stdio: 'ignore' });
    } catch {}
  }

  // Poll until active
  for (let i = 0; i < 20; i++) {
    await new Promise(r => setTimeout(r, 500));
    if (await isMysqlRunning()) return true;
  }
  return false;
}

export async function stopMysql() {
  try {
    if (isWindows && fs.existsSync(PATHS.mysqlAdminBin)) {
      execSync(`"${PATHS.mysqlAdminBin}" -u root shutdown`, { stdio: 'ignore', timeout: 3000 });
    }
  } catch {}

  killProcessByName('mysqld.exe');
  killProcessByName('mariadbd.exe');
  killProcessByName('mariadb.exe');

  for (let i = 0; i < 8; i++) {
    await new Promise(r => setTimeout(r, 300));
    if (!(await isMysqlRunning())) return true;
  }
  return true;
}

// ==========================================
// Browser & System Helpers
// ==========================================
export function openUrl(url) {
  try {
    if (isWindows) {
      spawn('cmd.exe', ['/c', 'start', '', url], { detached: true, stdio: 'ignore' }).unref();
    } else {
      try {
        execSync(`termux-open-url "${url}"`, { stdio: 'ignore' });
      } catch {
        try {
          execSync(`xdg-open "${url}"`, { stdio: 'ignore' });
        } catch {
          execSync(`open "${url}"`, { stdio: 'ignore' });
        }
      }
    }
    return true;
  } catch {
    return false;
  }
}

export function openFolder(dirPath) {
  try {
    if (isWindows) {
      spawn('explorer.exe', [dirPath], { detached: true, stdio: 'ignore' }).unref();
    } else {
      try {
        execSync(`xdg-open "${dirPath}"`, { stdio: 'ignore' });
      } catch {
        execSync(`open "${dirPath}"`, { stdio: 'ignore' });
      }
    }
    return true;
  } catch {
    return false;
  }
}
