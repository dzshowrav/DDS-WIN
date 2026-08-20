import { readFileSync, writeFileSync, existsSync } from 'fs';
import { PATHS, ensureDir, toApachePath } from './config.js';

function getDefaultHosts() {
  const root = toApachePath(PATHS.projects);
  return {
    defaultRoot: root,
    hosts: [
      { name: 'default', port: 8080, root: root, ssl: false },
    ],
  };
}

export function loadHosts() {
  if (!existsSync(PATHS.hostsJson)) {
    const data = getDefaultHosts();
    saveHosts(data);
    return data;
  }
  try {
    const data = JSON.parse(readFileSync(PATHS.hostsJson, 'utf8'));
    if (!data.defaultRoot) data.defaultRoot = toApachePath(PATHS.projects);
    if (!Array.isArray(data.hosts) || data.hosts.length === 0) {
      data.hosts = [{ name: 'default', port: 8080, root: data.defaultRoot, ssl: false }];
    }
    return data;
  } catch {
    const data = getDefaultHosts();
    saveHosts(data);
    return data;
  }
}

export function saveHosts(data) {
  writeFileSync(PATHS.hostsJson, JSON.stringify(data, null, 2), 'utf8');
}

export function getHosts() {
  return loadHosts().hosts;
}

export function addHost(name, port, root) {
  const data = loadHosts();
  const normalizedRoot = toApachePath(root);
  
  if (data.hosts.find(h => h.name.toLowerCase() === name.toLowerCase())) {
    throw new Error(`Host "${name}" already exists`);
  }
  if (data.hosts.find(h => h.port === port)) {
    const existing = data.hosts.find(h => h.port === port);
    throw new Error(`Port ${port} is already in use by host "${existing.name}"`);
  }

  ensureDir(normalizedRoot);
  data.hosts.push({ name, port, root: normalizedRoot, ssl: false });
  saveHosts(data);
  return data.hosts;
}

export function removeHost(name) {
  const data = loadHosts();
  if (name === 'default') {
    throw new Error('Cannot delete the default host');
  }
  const idx = data.hosts.findIndex(h => h.name === name);
  if (idx === -1) throw new Error(`Host "${name}" not found`);
  data.hosts.splice(idx, 1);
  saveHosts(data);
  return data.hosts;
}

export function editHost(name, updates) {
  const data = loadHosts();
  const host = data.hosts.find(h => h.name === name);
  if (!host) throw new Error(`Host "${name}" not found`);

  if (updates.port && updates.port !== host.port) {
    const existing = data.hosts.find(h => h.port === updates.port);
    if (existing) throw new Error(`Port ${updates.port} is already in use by host "${existing.name}"`);
  }

  if (updates.root) {
    updates.root = toApachePath(updates.root);
    ensureDir(updates.root);
  }

  Object.assign(host, updates);
  saveHosts(data);
  return data.hosts;
}

export function setDefaultRoot(newRootPath) {
  const data = loadHosts();
  const normalized = toApachePath(newRootPath);
  ensureDir(normalized);
  data.defaultRoot = normalized;
  const def = data.hosts.find(h => h.name === 'default');
  if (def) def.root = normalized;
  saveHosts(data);
  return data;
}
