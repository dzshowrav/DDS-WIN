<?php
declare(strict_types=1);

/**
 * DDS phpMyAdmin Configuration (v5.2.3)
 * Direct connection to MySQL / MariaDB Server
 */

$cfg['blowfish_secret'] = 'e26e14a19075b8e122a59e006916a7c032byteskey!';

/* Primary Local Database Server */
$i = 1;
$cfg['Servers'][$i]['auth_type'] = 'config';
$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = '';
$cfg['Servers'][$i]['host'] = '127.0.0.1';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = true;
$cfg['Servers'][$i]['verbose'] = 'DDS MariaDB / MySQL';

/* Directories & Sessions */
$cfg['TempDir'] = 'C:/DDS/tmp';
$cfg['SessionSavePath'] = 'C:/DDS/tmp';

/* General Configuration */
$cfg['SendErrorReports'] = 'never';
$cfg['CheckConfigurationPermissions'] = false;
$cfg['VersionCheck'] = false;
$cfg['ShowPhpInfo'] = true;
$cfg['ThemeDefault'] = 'pmahomme';
