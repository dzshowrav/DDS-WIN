import inquirer from 'inquirer';
import chalk from 'chalk';
import { PORTS, isWindows } from './config.js';

const choices = [
  {
    name: `${chalk.green('●')}  ${chalk.bold('Start DDS')}        ${chalk.dim(`Start Apache (:8080) + MariaDB + PHP`)}`,
    value: 'start',
    short: 'Start',
  },
  {
    name: `${chalk.green('●')}  ${chalk.bold('Start SSL')}        ${chalk.dim(`Start DDS with HTTPS (:8443)`)}`,
    value: 'start-ssl',
    short: 'Start SSL',
  },
  {
    name: `${chalk.red('●')}  ${chalk.bold('Stop DDS')}         ${chalk.dim('Stop all services gracefully')}`,
    value: 'stop',
    short: 'Stop',
  },
  {
    name: `${chalk.yellow('●')}  ${chalk.bold('Restart DDS')}      ${chalk.dim('Restart all services')}`,
    value: 'restart',
    short: 'Restart',
  },
  {
    name: `${chalk.cyan('●')}  ${chalk.bold('Status')}           ${chalk.dim('Show live status & quick actions')}`,
    value: 'status',
    short: 'Status',
  },
  new inquirer.Separator(),
  {
    name: `${chalk.hex('#d4a000')('●')}  ${chalk.bold('Host Manager')}     ${chalk.dim('Create / edit / delete virtual hosts')}`,
    value: 'hosts',
    short: 'Hosts',
  },
  {
    name: `${chalk.hex('#d4a000')('●')}  ${chalk.bold('Change Root')}      ${chalk.dim('Set default document root')}`,
    value: 'root',
    short: 'Root',
  },
  {
    name: `${chalk.hex('#00d4aa')('●')}  ${chalk.bold('phpMyAdmin')}       ${chalk.dim('Open database manager in browser')}`,
    value: 'pma',
    short: 'phpMyAdmin',
  },
  {
    name: `${chalk.hex('#5599ff')('●')}  ${chalk.bold(isWindows ? 'Open in Explorer' : 'Open Projects')} ${chalk.dim('Open document root folder')}`,
    value: 'explorer',
    short: 'Open Folder',
  },
  new inquirer.Separator(),
  {
    name: `${chalk.blue('●')}  ${chalk.bold('Update DDS')}       ${chalk.dim('Pull latest version & re-apply config')}`,
    value: 'update',
    short: 'Update',
  },
  {
    name: `${chalk.red('●')}  ${chalk.bold('Uninstall')}        ${chalk.dim('Remove DDS configuration')}`,
    value: 'uninstall',
    short: 'Uninstall',
  },
  new inquirer.Separator(),
  {
    name: `${chalk.dim('✕')}  Exit`,
    value: 'exit',
    short: 'Exit',
  },
];

export async function showMenu() {
  const { action } = await inquirer.prompt([
    {
      type: 'list',
      name: 'action',
      message: chalk.hex('#00d4aa')('Select an action:'),
      choices,
      pageSize: 14,
      loop: false,
    },
  ]);
  return action;
}
