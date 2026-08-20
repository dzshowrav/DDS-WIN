import { execSync } from 'child_process';
import { existsSync, mkdirSync, copyFileSync, promises as fs } from 'fs';
import path from 'path';
import chalk from 'chalk';
import inquirer from 'inquirer';
import { withSpinner } from './spinner.js';
import { renderLogo, renderHeader } from './logo.js';
import { getHosts, addHost, removeHost, editHost, setDefaultRoot, loadHosts } from './hosts.js';
import { generateVhostConfig } from './vhost.js';
import {
  isWindows,
  PATHS,
  PORTS,
  ensureDir,
  toApachePath
} from './config.js';
import {
  isApacheRunning,
  getApachePids,
  startApache,
  stopApache,
  reloadApache,
  isMysqlRunning,
  getMysqlPids,
  startMysql,
  stopMysql,
  isPhpRunning,
  getPhpPids,
  openUrl,
  openFolder
} from './services.js';

export async function doStart(ssl = false) {
  const hostsData = loadHosts();
  const defaultRoot = hostsData.defaultRoot || PATHS.projects;
  ensureDir(defaultRoot);

  // Sync phpMyAdmin configuration if needed
  if (existsSync(PATHS.phpmyadminDir) && existsSync(PATHS.phpmyadminConfig)) {
    try {
      const targetPmaConfig = path.join(PATHS.phpmyadminDir, 'config.inc.php');
      copyFileSync(PATHS.phpmyadminConfig, targetPmaConfig);
    } catch {}
  }

  // Create default index.php if root directory is empty
  try {
    const indexFile = path.join(defaultRoot, 'index.php');
    if (!existsSync(indexFile)) {
      const welcomeContent = `<?php
/**
 * DDS Local Development Server
 */
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DDS Web Server</title>
  <style>
    :root {
      --bg: #0d1117;
      --card-bg: #161b22;
      --text: #c9d1d9;
      --accent: #00d4aa;
      --border: #30363d;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text);
      margin: 0;
      padding: 40px 20px;
      display: flex;
      justify-content: center;
    }
    .container {
      max-width: 700px;
      width: 100%;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.5);
    }
    h1 {
      color: var(--accent);
      margin-top: 0;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .badge {
      display: inline-block;
      padding: 4px 10px;
      background: rgba(0,212,170,0.15);
      color: var(--accent);
      border-radius: 20px;
      font-size: 0.85rem;
      font-weight: bold;
    }
    .links {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-top: 24px;
    }
    .link-btn {
      display: block;
      text-align: center;
      padding: 12px;
      background: #21262d;
      color: #58a6ff;
      text-decoration: none;
      border-radius: 6px;
      border: 1px solid var(--border);
      font-weight: 500;
      transition: background 0.2s;
    }
    .link-btn:hover {
      background: #30363d;
    }
    .info-table {
      width: 100%;
      margin-top: 24px;
      border-collapse: collapse;
    }
    .info-table td {
      padding: 8px 0;
      border-bottom: 1px solid #21262d;
    }
    .info-table td:first-child {
      color: #8b949e;
      width: 140px;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>DDS Web Server <span class="badge">Online</span></h1>
    <p>Your local Apache, MariaDB, and PHP development stack is running successfully.</p>
    
    <table class="info-table">
      <tr><td>PHP Version</td><td><strong><?php echo phpversion(); ?></strong></td></tr>
      <tr><td>Document Root</td><td><code><?php echo __DIR__; ?></code></td></tr>
      <tr><td>Server Software</td><td><?php echo $_SERVER['SERVER_SOFTWARE']; ?></td></tr>
      <tr><td>Database</td><td>MariaDB / MySQL (:3306)</td></tr>
    </table>

    <div class="links">
      <a class="link-btn" href="/phpmyadmin/">Open phpMyAdmin</a>
      <a class="link-btn" href="/phpinfo/">PHP Info</a>
    </div>
  </div>
</body>
</html>`;
      fs.writeFile(indexFile, welcomeContent, 'utf8').catch(() => {});
    }
  } catch {}

  // Generate Apache Virtual Hosts configuration
  try {
    generateVhostConfig();
  } catch (err) {
    console.log(chalk.yellow(`  Warning: Virtual host generation: ${err.message}`));
  }

  // Start Apache HTTP Server + PHP Module
  await withSpinner('Starting Apache HTTP Server + PHP 8...', async () => {
    const ok = await startApache(ssl);
    if (!ok && !(await isApacheRunning())) {
      throw new Error('Apache failed to start. Check configuration.');
    }
    return true;
  });

  // Start MariaDB / MySQL
  await withSpinner('Starting MariaDB / MySQL...', async () => {
    const ok = await startMysql();
    if (!ok && !(await isMysqlRunning())) {
      console.log(chalk.yellow('  Warning: MariaDB took longer to start or is already managed.'));
    }
    return true;
  });

  const port = ssl ? PORTS.apacheSsl : PORTS.apache;
  const proto = ssl ? 'https' : 'http';
  const url = `${proto}://localhost:${port}/`;

  console.log(chalk.green('\n  ✓ DDS is running successfully!'));
  console.log(chalk.dim(`  Document Root: ${chalk.white(defaultRoot)}`));
  console.log(chalk.dim(`  Web Server:    ${chalk.underline(url)}`));
  console.log(chalk.dim(`  phpMyAdmin:    ${chalk.underline(`http://localhost:${PORTS.apache}/phpmyadmin/`)}\n`));

  openUrl(url);
}

export async function doStop() {
  await withSpinner('Stopping Apache...', async () => {
    await stopApache();
    return true;
  });

  await withSpinner('Stopping MariaDB / MySQL...', async () => {
    await stopMysql();
    return true;
  });

  console.log(chalk.green('\n  ✓ All DDS services stopped\n'));
}

export async function doRestart() {
  renderHeader('Restarting DDS');
  await doStop();
  await new Promise(r => setTimeout(r, 800));
  await doStart();
}

export async function doStatus() {
  let back = false;
  while (!back) {
    console.clear();

    const { logo } = renderLogo();
    console.log(logo);
    renderHeader('DDS Live Status');

    const [apacheOnline, mysqlOnline, phpOnline] = await Promise.all([
      isApacheRunning(),
      isMysqlRunning(),
      isPhpRunning(),
    ]);

    const apachePids = getApachePids();
    const mysqlPids = getMysqlPids();
    const phpPids = getPhpPids();
    const pmaInstalled = existsSync(PATHS.phpmyadminDir);
    const hostsData = loadHosts();
    const hosts = getHosts();

    const apacheStatus = apacheOnline
      ? chalk.bold.green('● RUNNING') + chalk.dim(`  (${apachePids.length || 1} processes, port ${PORTS.apache})`)
      : chalk.bold.red('● STOPPED');

    const mysqlStatus = mysqlOnline
      ? chalk.bold.green('● RUNNING') + chalk.dim(`  (PID ${mysqlPids[0] || 'active'}, port ${PORTS.mysql})`)
      : chalk.bold.red('● STOPPED');

    const phpStatus = phpOnline
      ? chalk.bold.green('● RUNNING') + chalk.dim(`  (${phpPids.length || 1} processes, port ${PORTS.phpFcg})`)
      : chalk.bold.red('● STOPPED');

    const pmaStatus = pmaInstalled
      ? chalk.bold.green('● INSTALLED') + chalk.dim('  /phpmyadmin/')
      : chalk.bold.yellow('● NOT FOUND');

    console.log(`  ${chalk.hex('#00d4aa')('▸')} Apache HTTP   ${apacheStatus}`);
    console.log(`  ${chalk.hex('#00d4aa')('▸')} MariaDB/MySQL ${mysqlStatus}`);
    console.log(`  ${chalk.hex('#00d4aa')('▸')} PHP FastCGI   ${phpStatus}`);
    console.log(`  ${chalk.hex('#00d4aa')('▸')} phpMyAdmin    ${pmaStatus}`);
    console.log();

    if (hosts.length > 0) {
      console.log(chalk.dim('  ── Virtual Hosts ──'));
      for (const h of hosts) {
        const icon = apacheOnline ? chalk.green('●') : chalk.dim('○');
        const root = h.root || '(none)';
        console.log(`  ${icon} ${chalk.bold(h.name)} ${chalk.dim('→')} :${h.port} ${chalk.dim('[' + root + ']')}`);
      }
      console.log();
    }

    const choices = [];

    if (pmaInstalled && apacheOnline) {
      choices.push({
        name: `${chalk.hex('#00d4aa')('○')}  ${chalk.bold('Open phpMyAdmin')} ${chalk.dim(`http://localhost:${PORTS.apache}/phpmyadmin/`)}`,
        value: 'pma',
      });
    }

    if (apacheOnline) {
      choices.push({
        name: `${chalk.green('○')}  ${chalk.bold('Open HTTP')}      ${chalk.dim(`http://localhost:${PORTS.apache}/`)}`,
        value: 'http',
      });
      choices.push({
        name: `${chalk.green('○')}  ${chalk.bold('Open HTTPS')}     ${chalk.dim(`https://localhost:${PORTS.apacheSsl}/`)}`,
        value: 'https',
      });

      for (const h of hosts) {
        if (h.port == PORTS.apache) continue;
        choices.push(new inquirer.Separator());
        choices.push({
          name: `${chalk.hex('#5599ff')('○')}  ${chalk.bold(h.name)} HTTP  ${chalk.dim(`http://localhost:${h.port}/`)}`,
          value: `host_${h.port}`,
        });
      }
    }

    choices.push(new inquirer.Separator());
    choices.push({
      name: `${chalk.hex('#d4a000')('📂')} ${chalk.bold(isWindows ? 'Open Document Root in Explorer' : 'Open Projects Folder')}`,
      value: 'explorer',
    });
    choices.push({
      name: `${chalk.dim('←')}  ${chalk.bold('Back to Home')}`,
      value: 'back',
    });

    const { action } = await inquirer.prompt([{
      type: 'list',
      name: 'action',
      message: chalk.hex('#00d4aa')('Quick actions:'),
      choices,
      pageSize: Math.min(hosts.length + 8, 20),
      loop: false,
    }]);

    switch (action) {
      case 'http':
        openUrl(`http://localhost:${PORTS.apache}/`);
        break;
      case 'https':
        openUrl(`https://localhost:${PORTS.apacheSsl}/`);
        break;
      case 'pma':
        openUrl(`http://localhost:${PORTS.apache}/phpmyadmin/`);
        break;
      case 'explorer':
        openFolder(hostsData.defaultRoot || PATHS.projects);
        break;
      case 'back':
        back = true;
        break;
      default:
        if (action && action.startsWith('host_')) {
          const port = action.slice(5);
          openUrl(`http://localhost:${port}/`);
        }
        break;
    }
  }
}

export function doPma() {
  const url = `http://localhost:${PORTS.apache}/phpmyadmin/`;
  console.log(chalk.dim(`\n  Opening phpMyAdmin: ${chalk.underline(url)}\n`));
  openUrl(url);
}

export function doExplorer() {
  const hostsData = loadHosts();
  const rootPath = hostsData.defaultRoot || PATHS.projects;
  console.log(chalk.dim(`\n  Opening folder: ${rootPath}\n`));
  openFolder(rootPath);
}

export async function doRoot() {
  const data = loadHosts();
  const { newRoot } = await inquirer.prompt([{
    type: 'input',
    name: 'newRoot',
    message: 'Enter new document root path:',
    default: data.defaultRoot,
    validate: v => v.trim() ? true : 'Path cannot be empty',
  }]);

  const cleanRoot = newRoot.trim();
  ensureDir(cleanRoot);
  setDefaultRoot(cleanRoot);
  generateVhostConfig();
  await reloadApache();
  console.log(chalk.green(`\n  ✓ Default document root changed to: ${cleanRoot}\n`));
}

export async function doHostManager() {
  let back = false;
  while (!back) {
    console.clear();
    const { logo } = renderLogo();
    console.log(logo);
    renderHeader('Host Manager');

    const hosts = getHosts();
    console.log('  ' + chalk.bold('Configured Hosts:'));
    console.log();
    for (const h of hosts) {
      const icon = chalk.hex('#00d4aa')('>');
      console.log(`    ${icon}  ${chalk.bold(h.name.padEnd(16))} ${chalk.dim(':' + h.port)}  ${h.root}`);
    }
    console.log();

    const { action } = await inquirer.prompt([{
      type: 'list',
      name: 'action',
      message: 'Host Manager Options:',
      choices: [
        { name: '+  Create Host', value: 'create' },
        { name: '~  Edit Host', value: 'edit' },
        { name: '-  Delete Host', value: 'delete' },
        new inquirer.Separator(),
        { name: '←  Back to Home', value: 'back' },
      ],
      pageSize: 8,
      loop: false,
    }]);

    switch (action) {
      case 'create':
        await doHostCreate();
        break;
      case 'edit':
        await doHostEdit();
        break;
      case 'delete':
        await doHostDelete();
        break;
      case 'back':
        back = true;
        break;
    }
  }
}

async function doHostCreate() {
  const hostsData = loadHosts();
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: 'Host name (e.g. blog, api, shop):',
      validate: v => /^[a-zA-Z0-9_-]+$/.test(v.trim()) ? true : 'Use only letters, numbers, hyphens, underscores',
    },
    {
      type: 'input',
      name: 'port',
      message: 'Port number:',
      default: () => {
        const hosts = getHosts();
        const used = new Set(hosts.map(h => h.port));
        for (let p = 8081; p < 9000; p++) {
          if (!used.has(p) && p !== PORTS.apacheSsl && p !== PORTS.phpFcg) return p;
        }
        return 8081;
      },
      validate: v => {
        const n = parseInt(v);
        if (isNaN(n) || n < 80 || n > 65535) return 'Use a port between 80 and 65535';
        const hosts = getHosts();
        if (hosts.find(h => h.port === n)) return `Port ${n} is already in use`;
        return true;
      },
    },
    {
      type: 'input',
      name: 'root',
      message: 'Document root path:',
      default: (ans) => {
        return toApachePath(path.join(hostsData.defaultRoot || PATHS.projects, ans.name || 'site'));
      },
      validate: v => v.trim() ? true : 'Path cannot be empty',
    },
  ]);

  const cleanName = answers.name.trim();
  const cleanPort = parseInt(answers.port);
  const cleanRoot = answers.root.trim();

  ensureDir(cleanRoot);

  try {
    addHost(cleanName, cleanPort, cleanRoot);
    generateVhostConfig();
    await reloadApache();
    console.log(chalk.green(`\n  ✓ Host "${cleanName}" created on port ${cleanPort}`));
    console.log(chalk.dim(`  URL: http://localhost:${cleanPort}/\n`));
  } catch (err) {
    console.log(chalk.red(`\n  ERROR: ${err.message}\n`));
  }
}

async function doHostEdit() {
  const hosts = getHosts();
  if (hosts.length <= 1) {
    console.log(chalk.yellow('\n  No custom hosts to edit.\n'));
    await new Promise(r => setTimeout(r, 1200));
    return;
  }

  const { name } = await inquirer.prompt([{
    type: 'list',
    name: 'name',
    message: 'Select host to edit:',
    choices: hosts.map(h => ({ name: `${h.name.padEnd(14)} :${h.port}  ${h.root}`, value: h.name })),
  }]);

  const host = hosts.find(h => h.name === name);
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'port',
      message: `New port (leave blank to keep ${host.port}):`,
      default: String(host.port),
      validate: v => {
        if (!v.trim()) return true;
        const n = parseInt(v);
        if (isNaN(n) || n < 80 || n > 65535) return 'Use a port between 80 and 65535';
        return true;
      },
    },
    {
      type: 'input',
      name: 'root',
      message: `New root path:`,
      default: host.root,
      validate: v => v.trim() ? true : 'Path cannot be empty',
    },
  ]);

  const updates = {};
  if (answers.port && parseInt(answers.port) !== host.port) updates.port = parseInt(answers.port);
  if (answers.root && answers.root.trim() !== host.root) updates.root = answers.root.trim();

  if (Object.keys(updates).length === 0) {
    console.log(chalk.yellow('\n  No changes made.\n'));
    return;
  }

  try {
    editHost(name, updates);
    generateVhostConfig();
    await reloadApache();
    console.log(chalk.green(`\n  ✓ Host "${name}" updated successfully.\n`));
  } catch (err) {
    console.log(chalk.red(`\n  ERROR: ${err.message}\n`));
  }
}

async function doHostDelete() {
  const hosts = getHosts();
  if (hosts.length <= 1) {
    console.log(chalk.yellow('\n  No custom hosts to delete.\n'));
    await new Promise(r => setTimeout(r, 1200));
    return;
  }

  const { name, confirm } = await inquirer.prompt([
    {
      type: 'list',
      name: 'name',
      message: 'Select host to delete:',
      choices: hosts.filter(h => h.name !== 'default').map(h => ({
        name: `${h.name.padEnd(14)} :${h.port}  ${h.root}`,
        value: h.name,
      })),
    },
    {
      type: 'confirm',
      name: 'confirm',
      message: 'Are you sure you want to remove this host?',
      default: false,
    },
  ]);

  if (!confirm) {
    console.log(chalk.dim('\n  Action cancelled.\n'));
    return;
  }

  try {
    removeHost(name);
    generateVhostConfig();
    await reloadApache();
    console.log(chalk.green(`\n  ✓ Host "${name}" deleted.\n`));
  } catch (err) {
    console.log(chalk.red(`\n  ERROR: ${err.message}\n`));
  }
}

export function doUpdate() {
  renderHeader('Update DDS');
  try {
    execSync('git remote update 2>/dev/null', { stdio: 'ignore' });
    const status = execSync('git status -uno', { encoding: 'utf8' });
    if (status.includes('up to date') || status.includes('Your branch is up to date')) {
      console.log(chalk.yellow('  DDS is already up to date.\n'));
      return;
    }
  } catch {}

  withSpinner('Updating DDS...', () => {
    try {
      execSync('git pull', { stdio: 'inherit' });
      generateVhostConfig();
    } catch {}
    return true;
  });
  console.log(chalk.green('  DDS updated successfully.\n'));
}

export async function doUninstall() {
  renderHeader('Uninstall DDS');

  const { confirmUninstall } = await inquirer.prompt([{
    type: 'confirm',
    name: 'confirmUninstall',
    message: chalk.red.bold('Are you sure you want to completely uninstall DDS from your computer?\n') +
      chalk.dim('  This will stop all servers, remove runtime binaries, and clean your Windows PATH.\n'),
    default: false,
  }]);

  if (!confirmUninstall) {
    console.log(chalk.dim('\n  Uninstallation cancelled.\n'));
    return;
  }

  const { wipeProjects } = await inquirer.prompt([{
    type: 'confirm',
    name: 'wipeProjects',
    message: chalk.yellow('Do you also want to delete all website project files in C:\\DDS\\Projects?'),
    default: false,
  }]);

  await doStop();

  if (isWindows) {
    const uninstallScript = path.join(APP_DIR, 'uninstall.ps1');
    if (existsSync(uninstallScript)) {
      const wipeFlag = wipeProjects ? '-WipeProjects' : '';
      try {
        execSync(`powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${uninstallScript}" -Force ${wipeFlag}`, {
          stdio: 'inherit',
        });
      } catch {}
    }
  } else {
    // Termux / POSIX cleanup
    try {
      execSync('rm -rf /data/data/com.termux/files/usr/etc/apache2/conf.d/dds-vhosts.conf', { stdio: 'ignore' });
      execSync('rm -rf /sdcard/htdocs/phpmyadmin', { stdio: 'ignore' });
    } catch {}
    console.log(chalk.green('\n  ✓ DDS services have been uninstalled and cleaned.\n'));
  }

  process.exit(0);
}
