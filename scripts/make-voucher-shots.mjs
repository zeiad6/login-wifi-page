#!/usr/bin/env node
// Renders the voucher studio for the README: one PNG per card design (a 3-card
// row) and an animated GIF of the studio in use.
//
// Requirements: npm i --no-save playwright && npx playwright install chromium ; ffmpeg in PATH
// Usage: node scripts/make-voucher-shots.mjs
import { chromium } from 'playwright';
import { createServer } from 'node:http';
import { readFile, mkdir, mkdtemp, rm } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const OUT = path.join(ROOT, 'docs', 'img');
const DESIGNS = ['classic', 'ticket', 'minimal', 'premium'];
const TYPES = { '.html': 'text/html; charset=utf-8', '.woff2': 'font/woff2', '.svg': 'image/svg+xml', '.js': 'text/javascript' };

const server = createServer(async (req, res) => {
  const file = path.join(ROOT, decodeURIComponent(new URL(req.url, 'http://local').pathname));
  if (!file.startsWith(ROOT + path.sep)) { res.writeHead(403).end(); return; }
  try {
    const body = await readFile(file);
    res.writeHead(200, { 'content-type': TYPES[path.extname(file)] || 'application/octet-stream' });
    res.end(req.method === 'HEAD' ? undefined : body);
  } catch { res.writeHead(404).end(); }
}).listen(0, '127.0.0.1');
await new Promise((r) => server.once('listening', r));
const base = `http://127.0.0.1:${server.address().port}`;
const url = `${base}/vouchers/vouchers.html`;

await mkdir(OUT, { recursive: true });
const browser = await chromium.launch();
try {
  // One PNG per design: a 3-card preview row (one card per default category).
  for (const design of DESIGNS) {
    const ctx = await browser.newContext({ viewport: { width: 1180, height: 900 }, deviceScaleFactor: 2 });
    const page = await ctx.newPage();
    await page.goto(url);
    await page.evaluate(() => document.fonts.ready);
    await page.selectOption('#design', design);
    await page.click('#btnPreview');
    await page.waitForTimeout(700);
    await page.locator('#preview').screenshot({ path: path.join(OUT, `cards-${design}.png`) });
    await ctx.close();
  }

  // Animated studio walkthrough: change design, edit a price, preview.
  const dir = await mkdtemp(path.join(tmpdir(), 'vstudio-'));
  const ctx = await browser.newContext({ viewport: { width: 1180, height: 820 }, recordVideo: { dir, size: { width: 1180, height: 820 } } });
  const page = await ctx.newPage();
  await page.goto(url);
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(800);
  for (const design of ['ticket', 'premium', 'minimal', 'classic']) {
    await page.selectOption('#design', design);
    await page.click('#btnPreview');
    await page.waitForTimeout(1100);
  }
  const video = await page.video().path();
  await ctx.close();

  execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', video,
    '-vf', 'fps=10,scale=760:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse',
    '-loop', '0', path.join(OUT, 'voucher-studio.gif')]);
  await rm(dir, { recursive: true, force: true });
  console.log('✓ voucher shots + GIF written to docs/img/');
} finally {
  await browser.close();
  server.close();
}
