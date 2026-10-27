// Regenerates previews/<theme>.png (still) and previews/<theme>.webp (animated) for every theme.
//
// Requirements (run once):
//   npm i --no-save playwright && npx playwright install chromium
//   ffmpeg in PATH (with libwebp)
// Usage:
//   node scripts/make-previews.mjs            # all themes
//   node scripts/make-previews.mjs luxury-gold oled-matrix
import { chromium } from 'playwright';
import { createServer } from 'node:http';
import { readFile, readdir, mkdtemp, rm } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const VIEWPORT = { width: 390, height: 844 };
const TYPES = { '.html': 'text/html; charset=utf-8', '.woff2': 'font/woff2', '.svg': 'image/svg+xml', '.js': 'text/javascript' };

// Local static server: the pages load fonts with relative URLs, exactly as on the router.
const server = createServer(async (req, res) => {
  const file = path.join(ROOT, decodeURIComponent(new URL(req.url, 'http://local').pathname));
  if (!file.startsWith(ROOT + path.sep)) { res.writeHead(403).end(); return; }
  try {
    const body = await readFile(file);
    res.writeHead(200, { 'content-type': TYPES[path.extname(file)] || 'application/octet-stream' });
    res.end(req.method === 'HEAD' ? undefined : body);
  } catch {
    res.writeHead(404).end();
  }
}).listen(0, '127.0.0.1');
await new Promise((r) => server.once('listening', r));
const base = `http://127.0.0.1:${server.address().port}`;

const all = (await readdir(path.join(ROOT, 'themes'), { withFileTypes: true }))
  .filter((d) => d.isDirectory() && d.name !== 'fonts').map((d) => d.name);
const themes = process.argv.length > 2 ? process.argv.slice(2) : all;
for (const t of themes) if (!all.includes(t)) throw new Error(`Unknown theme: ${t}`);

const browser = await chromium.launch();
try {
  for (const theme of themes) {
    const url = `${base}/themes/${theme}/login.html`;

    // Still image: the settled first screen.
    const still = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: 1 });
    const sp = await still.newPage();
    await sp.goto(url);
    await sp.evaluate(() => document.fonts.ready);
    await sp.waitForTimeout(1800);
    await sp.screenshot({ path: path.join(ROOT, 'previews', `${theme}.png`) });
    await still.close();

    // Animated: empty-submit error, typing with 4-digit grouping, sales points sheet with search.
    const dir = await mkdtemp(path.join(tmpdir(), `preview-${theme}-`));
    const ctx = await browser.newContext({ viewport: VIEWPORT, recordVideo: { dir, size: VIEWPORT } });
    const page = await ctx.newPage();
    await page.goto(url);
    await page.evaluate(() => document.fonts.ready);
    await page.waitForTimeout(1600);
    await page.click('#btnSubmit');
    await page.waitForTimeout(1300);
    await page.click('#voucherCode');
    await page.keyboard.type('4821930571', { delay: 110 });
    await page.waitForTimeout(900);
    const pos = page.locator('[data-open="posModal"]').first();
    if (await pos.count()) {
      await pos.click();
      await page.waitForTimeout(1100);
      await page.locator('#posSearch').pressSequentially('صيدلية', { delay: 130 });
      await page.waitForTimeout(1100);
      await page.keyboard.press('Escape');
      await page.waitForTimeout(800);
    }
    const video = await page.video().path();
    await ctx.close();

    // Skip the blank first frames while the page loads; 12 fps keeps the file small.
    execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-ss', '0.5', '-i', video,
      '-vf', 'fps=12,scale=390:-1:flags=lanczos', '-loop', '0', '-c:v', 'libwebp',
      '-q:v', '62', '-compression_level', '6', path.join(ROOT, 'previews', `${theme}.webp`)]);
    await rm(dir, { recursive: true, force: true });
    console.log(`✓ ${theme}`);
  }
} finally {
  await browser.close();
  server.close();
}
