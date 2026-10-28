#!/usr/bin/env node
// Cross-platform theme switcher (Windows/Linux/macOS, no Git Bash needed).
// Copies a theme's four pages to the repo root. Resolves every path from this
// file's own location, so it works when run from any working directory.
// Usage: node scripts/switch-theme.mjs <theme-id>
import { copyFile, access } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const THEMES = ['oled-matrix', 'spatial-glass', 'nordic-studio', 'cyberpunk',
  'swiss-minimal', 'aurora-glass', 'neo-brutalist', 'luxury-gold'];
const PAGES = ['login.html', 'status.html', 'alogin.html', 'logout.html'];

const theme = process.argv[2];
if (!theme || !THEMES.includes(theme)) {
  console.error(`Usage: node scripts/switch-theme.mjs <${THEMES.join(' | ')}>`);
  process.exit(1);
}

const themeDir = path.join(ROOT, 'themes', theme);
try {
  for (const page of PAGES) await access(path.join(themeDir, page));
} catch {
  console.error(`Error: theme "${theme}" is missing a page in ${themeDir}`);
  process.exit(1);
}

for (const page of PAGES) {
  await copyFile(path.join(themeDir, page), path.join(ROOT, page));
}
console.log(`>>> Theme switched to "${theme}". Root pages updated: ${PAGES.join(', ')}`);
