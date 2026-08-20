import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const isWindows = process.platform === 'win32';

// Determine root directory for DDS
function resolveDdsRoot() {
  if (process.env.DDS_ROOT && fs.existsSync(process.env.DDS_ROOT)) {
    return path.resolve(process.env.DDS_ROOT);
  }
  if (process.env.DDS_DIR && fs.existsSync(process.env.DDS_DIR)) {
    return path.resolve(process.env.DDS_DIR);
  }
  if (isWindows) {
    if (fs.existsSync('C:/DDS')) {
      return 'C:/DDS';
    }
  }
  // Default to parent directory of dds-ui
  return path.resolve(__dirname, '..');
}

export const DDS_ROOT = resolveDdsRoot();
export const APP_DIR = path.resolve(__dirname, '..');

// Helper to normalize path with forward slashes for Apache configs
export function toApachePath(p) {
  return p.replace(/\\/g, '/');
}

// Ensure directory exists
export function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    try {
      fs.mkdirSync(dirPath, { recursive: true });
    } catch {}
  }
  return dirPath;
}

// Find existing executable from candidate paths
function findExecutable(candidates, fallback) {
  for (const c of candidates) {
    if (c && fs.existsSync(c)) return c;
  }
  return fallback;
}

// Service Paths
export const PATHS = {
  root: DDS_ROOT,
  appDir: APP_DIR,
  logs: isWindows ? ensureDir(path.join(DDS_ROOT, 'Logs')) : ensureDir(path.join(DDS_ROOT, 'logs')),
  certificates: isWindows ? ensureDir(path.join(DDS_ROOT, 'Certificates')) : ensureDir(path.join(DDS_ROOT, 'certs')),
  projects: isWindows ? ensureDir(path.join(DDS_ROOT, 'Projects')) : ensureDir(path.join(DDS_ROOT, 'htdocs')),
  hostsJson: path.join(APP_DIR, 'hosts.json'),
  
  // Apache paths
  apacheBin: isWindows
    ? findExecutable([
        path.join(DDS_ROOT, 'Services/apache/bin/httpd.exe'),
        path.join(DDS_ROOT, 'Services/apache/Apache24/bin/httpd.exe'),
        'C:/DDS/Services/apache/bin/httpd.exe',
        'C:/DDS/Services/apache/Apache24/bin/httpd.exe',
        'C:/Program Files/Apache/bin/httpd.exe',
        'C:/Apache24/bin/httpd.exe'
      ], 'C:/DDS/Services/apache/bin/httpd.exe')
    : 'apachectl',
  apacheConf: isWindows
    ? (fs.existsSync(path.join(DDS_ROOT, 'Services/apache/conf/httpd.conf'))
      ? path.join(DDS_ROOT, 'Services/apache/conf/httpd.conf')
      : path.join(APP_DIR, 'httpd.conf'))
    : (fs.existsSync('/data/data/com.termux/files/usr/etc/apache2/httpd.conf')
      ? '/data/data/com.termux/files/usr/etc/apache2/httpd.conf'
      : path.join(APP_DIR, 'httpd.conf')),
  vhostConf: isWindows
    ? (fs.existsSync(path.join(DDS_ROOT, 'Services/apache/conf/extra'))
      ? path.join(DDS_ROOT, 'Services/apache/conf/extra/httpd-vhosts.conf')
      : path.join(DDS_ROOT, 'Services/apache/conf/dds-vhosts.conf'))
    : (fs.existsSync('/data/data/com.termux/files/usr/etc/apache2/conf.d')
      ? '/data/data/com.termux/files/usr/etc/apache2/conf.d/dds-vhosts.conf'
      : path.join(APP_DIR, 'dds-vhosts.conf')),
  sslCert: isWindows
    ? path.join(DDS_ROOT, 'Certificates/localhost.crt')
    : '/data/data/com.termux/files/usr/etc/apache2/server.crt',
  sslKey: isWindows
    ? path.join(DDS_ROOT, 'Certificates/localhost.key')
    : '/data/data/com.termux/files/usr/etc/apache2/server.key',

  // PHP paths
  phpBin: isWindows
    ? findExecutable([
        path.join(DDS_ROOT, 'Services/php/php.exe'),
        'C:/DDS/Services/php/php.exe',
        'C:/Program Files/PHP/php.exe'
      ], 'C:/DDS/Services/php/php.exe')
    : 'php',
  phpCgiBin: isWindows
    ? findExecutable([
        path.join(DDS_ROOT, 'Services/php/php-cgi.exe'),
        'C:/DDS/Services/php/php-cgi.exe'
      ], 'C:/DDS/Services/php/php-cgi.exe')
    : 'php-fpm',
  phpIni: isWindows
    ? path.join(DDS_ROOT, 'Services/php/php.ini')
    : '/data/data/com.termux/files/usr/etc/php/php.ini',

  // MySQL / MariaDB paths
  mysqlBin: isWindows
    ? findExecutable([
        path.join(DDS_ROOT, 'Services/mysql/bin/mysqld.exe'),
        'C:/DDS/Services/mysql/bin/mysqld.exe'
      ], 'C:/DDS/Services/mysql/bin/mysqld.exe')
    : 'mariadbd-safe',
  mysqlAdminBin: isWindows
    ? findExecutable([
        path.join(DDS_ROOT, 'Services/mysql/bin/mysqladmin.exe'),
        'C:/DDS/Services/mysql/bin/mysqladmin.exe'
      ], 'C:/DDS/Services/mysql/bin/mysqladmin.exe')
    : 'mysqladmin',
  mysqlCliBin: isWindows
    ? findExecutable([
        path.join(DDS_ROOT, 'Services/mysql/bin/mysql.exe'),
        'C:/DDS/Services/mysql/bin/mysql.exe'
      ], 'C:/DDS/Services/mysql/bin/mysql.exe')
    : 'mariadb',
  mysqlIni: isWindows
    ? path.join(DDS_ROOT, 'Services/mysql/my.ini')
    : '/data/data/com.termux/files/usr/etc/my.cnf.d/dds-server.cnf',
  mysqlPidFile: isWindows
    ? path.join(DDS_ROOT, 'Services/mysql/data/mysqld.pid')
    : '/data/data/com.termux/files/usr/var/run/mariadb.pid',

  // phpMyAdmin
  phpmyadminDir: isWindows
    ? (fs.existsSync(path.join(DDS_ROOT, 'Services/web/phpmyadmin'))
      ? path.join(DDS_ROOT, 'Services/web/phpmyadmin')
      : path.join(DDS_ROOT, 'Projects/phpmyadmin'))
    : '/sdcard/htdocs/phpmyadmin',
  phpmyadminConfig: path.join(APP_DIR, 'config.inc.php'),
};

// Ports
export const PORTS = {
  apache: 8080,
  apacheSsl: 8443,
  mysql: 3306,
  phpFcg: 9000,
};
