import chalk from 'chalk';
import { isWindows } from './config.js';

function getWidth() {
  return process.stdout.columns || 80;
}

const pulse = ['#00d4aa', '#00c4a0', '#00b496', '#00a48c', '#009482', '#008478', '#00746e', '#008478', '#009482', '#00a48c', '#00b496', '#00c4a0'];
const spinners = ['◜', '◝', '◞', '◟'];

export function renderBadgeSync(apache, mysql, php, frame = 0) {
  const w = getWidth();

  if (!apache && !mysql && !php) {
    const txt = chalk.red('●') + '  ' + chalk.dim('Server Offline');
    return '\n' + centerPad(txt, w);
  }

  if (apache && !mysql) {
    const txt = chalk.yellow('●') + '  ' + chalk.bold.yellow('DEGRADED') + chalk.dim('  Apache only (MariaDB down)');
    return '\n' + centerPad(txt, w);
  }

  if (mysql && !apache) {
    const txt = chalk.yellow('●') + '  ' + chalk.bold.yellow('DEGRADED') + chalk.dim('  MariaDB only (Apache down)');
    return '\n' + centerPad(txt, w);
  }

  const dot = chalk.hex(pulse[frame % pulse.length])('●');
  const spin = chalk.hex('#00d4aa')(spinners[frame % spinners.length]);
  const platformTag = isWindows ? 'Apache + MariaDB + PHP' : 'Apache + MariaDB';
  const txt = `${dot}  ${chalk.bold('ACTIVE')} ${chalk.dim('·')} ${chalk.green(platformTag)} ${chalk.dim('·')} ${spin}`;
  return '\n' + centerPad(txt, w);
}

export function renderLogo() {
  const w = getWidth();
  const lines = [
    chalk.hex('#00d4aa')('██████╗ ██████╗ ███████╗'),
    chalk.hex('#00c4a0')('██╔══██╗██╔══██╗██╔════╝'),
    chalk.hex('#00b496')('██║  ██║██║  ██║███████╗'),
    chalk.hex('#00a48c')('██║  ██║██║  ██║╚════██║'),
    chalk.hex('#009482')('██████╔╝██████╔╝███████║'),
    chalk.hex('#008478')('╚═════╝ ╚═════╝ ╚══════╝'),
    chalk.hex('#00746e')('═══════════════════════════'),
  ];

  const logo = '\n' + lines.map(l => centerPad(l, w)).join('\n') + '\n';
  const sysName = isWindows ? 'Windows' : 'Termux';

  const tagline = centerPad(
    chalk.dim(`${sysName} • Apache • MariaDB • PHP`) + '  ' + chalk.hex('#00d4aa')('█'),
    w,
  );

  return { logo, tagline };
}

export function centerPad(str, width) {
  const visible = str.replace(/\u001b\[[0-9;]*m/g, '');
  if (visible.length <= 0) return str;
  const pad = Math.max(0, Math.floor((width - visible.length) / 2));
  return ' '.repeat(pad) + str;
}

export function renderHeader(title) {
  const w = getWidth();
  const line = chalk.hex('#00d4aa')('━'.repeat(50));
  console.log(`\n${centerPad(line, w)}`);
  console.log(centerPad(chalk.bold(title), w));
  console.log(`${centerPad(line, w)}\n`);
}
