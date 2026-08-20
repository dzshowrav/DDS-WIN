#!/usr/bin/env node

import chalk from 'chalk';
import { renderLogo, renderBadgeSync } from './logo.js';
import { showMenu } from './menu.js';
import {
  doStart,
  doStop,
  doStatus,
  doRestart,
  doUpdate,
  doUninstall,
  doRoot,
  doHostManager,
  doPma,
  doExplorer,
} from './commands.js';
import {
  isApacheRunning,
  isMysqlRunning,
  isPhpRunning,
} from './services.js';
import { isWindows } from './config.js';

const args = process.argv.slice(2);

async function main() {
  if (args.length > 0) {
    return await runDirect(args[0], args.slice(1));
  }

  let frame = 0;
  let running = true;
  while (running) {
    console.clear();
    const { logo, tagline } = renderLogo();
    console.log(logo);
    console.log(tagline);

    // Live status check for the badge
    const [apache, mysql, php] = await Promise.all([
      isApacheRunning(),
      isMysqlRunning(),
      isPhpRunning(),
    ]);

    const badge = renderBadgeSync(apache, mysql, php, frame++);
    console.log(badge);
    console.log();

    const action = await showMenu();

    switch (action) {
      case 'start':     await doStart(false); break;
      case 'start-ssl': await doStart(true); break;
      case 'stop':      await doStop(); break;
      case 'restart':   await doRestart(); break;
      case 'status':    await doStatus(); break;
      case 'hosts':     await doHostManager(); break;
      case 'root':      await doRoot(); break;
      case 'pma':       doPma(); break;
      case 'explorer':  doExplorer(); break;
      case 'update':    doUpdate(); break;
      case 'uninstall': await doUninstall(); break;
      case 'exit':
        running = false;
        console.log(chalk.dim('\n  Goodbye!\n'));
        break;
    }
  }
}

async function runDirect(cmd, extraArgs = []) {
  cmd = cmd.replace(/^--?/, '').toLowerCase();
  switch (cmd) {
    case 'start':       return await doStart(false);
    case 'start-ssl':
    case 'ssl':         return await doStart(true);
    case 'stop':        return await doStop();
    case 'restart':     return await doRestart();
    case 'status':      return await doStatus();
    case 'hosts':
    case 'vhosts':      return await doHostManager();
    case 'gen-vhosts':
    case 'vhosts-gen': {
      const { generateVhostConfig } = await import('./vhost.js');
      generateVhostConfig();
      console.log(chalk.green('  ✓ Virtual host configuration generated.'));
      return;
    }
    case 'root':        return await doRoot();
    case 'pma':
    case 'db':          return doPma();
    case 'explore':
    case 'open':
    case 'folder':      return doExplorer();
    case 'update':      return doUpdate();
    case 'uninstall':   return await doUninstall();
    case 'help':
    case 'h':
      printHelp();
      break;
    default:
      console.log(chalk.red(`\n  Unknown command: ${cmd}`));
      printHelp();
  }
}

function printHelp() {
  const sysTag = isWindows ? 'Windows' : 'Termux / Linux';
  console.log(chalk.bold.hex('#00d4aa')(`\n  DDS — Local Web Server Stack (${sysTag})`));
  console.log(chalk.dim('  Apache HTTP Server · MariaDB / MySQL · PHP FastCGI · phpMyAdmin\n'));
  console.log(chalk.bold('  Usage:'));
  console.log(chalk.cyan('    dds                 ') + chalk.dim('Launch interactive visual menu'));
  console.log(chalk.cyan('    dds start           ') + chalk.dim('Start Apache (:8080) + MariaDB + PHP'));
  console.log(chalk.cyan('    dds start-ssl       ') + chalk.dim('Start with SSL HTTPS (:8443)'));
  console.log(chalk.cyan('    dds stop            ') + chalk.dim('Stop all services gracefully'));
  console.log(chalk.cyan('    dds restart         ') + chalk.dim('Restart all services'));
  console.log(chalk.cyan('    dds status          ') + chalk.dim('Show live status & host links'));
  console.log(chalk.cyan('    dds hosts           ') + chalk.dim('Manage virtual hosts'));
  console.log(chalk.cyan('    dds root [path]     ') + chalk.dim('Change default document root'));
  console.log(chalk.cyan('    dds pma             ') + chalk.dim('Open phpMyAdmin in browser'));
  console.log(chalk.cyan('    dds open            ') + chalk.dim('Open document root folder'));
  console.log(chalk.cyan('    dds update          ') + chalk.dim('Update DDS configuration'));
  console.log(chalk.cyan('    dds uninstall       ') + chalk.dim('Reset and remove services\n'));
}

main().catch(err => {
  console.error(chalk.red('\n  ERROR:'), err.message);
  process.exit(1);
});
