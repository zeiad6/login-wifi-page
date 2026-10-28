#!/usr/bin/env node
// Minify pipeline for small MikroTik routers: shrinks every theme page (inline
// CSS + JS minified too) into dist/, and copies the fonts and the voucher tool
// unchanged. localStorage logic is left exactly as-is.
//
// Point the router at the minified copies with ebUseMinified=true in the .rsc,
// after committing dist/.
//
// Usage: node scripts/build.mjs
import { minify } from 'html-minifier-terser';
import { readFile, writeFile, mkdir, copyFile, readdir, rm } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const DIST = path.join(ROOT, 'dist');
const PAGES = ['login.html', 'status.html', 'alogin.html', 'logout.html'];

// RouterOS renders $(error), $(chap-id), $(link-redirect)… server-side before
// serving the page. Keep attribute quotes and never rewrite URLs, so those
// placeholders survive minification intact.
const HTML_OPTS = {
  collapseWhitespace: true,
  conservativeCollapse: false,
  removeComments: true,
  removeAttributeQuotes: false,
  minifyURLs: false,
  minifyCSS: true,
  minifyJS: { compress: true, mangle: true },
  // keep the <!DOCTYPE html> and charset; drop nothing structural
  removeOptionalTags: false,
};

async function minifyPage(src, dst) {
  const html = await readFile(src, 'utf8');
  const out = await minify(html, HTML_OPTS);
  await writeFile(dst, out);
  return { before: Buffer.byteLength(html), after: Buffer.byteLength(out) };
}

await rm(DIST, { recursive: true, force: true });
await mkdir(DIST, { recursive: true });

let totalBefore = 0, totalAfter = 0;
const themes = (await readdir(path.join(ROOT, 'themes'), { withFileTypes: true }))
  .filter((d) => d.isDirectory() && d.name !== 'fonts').map((d) => d.name);

for (const theme of themes) {
  const srcDir = path.join(ROOT, 'themes', theme);
  const dstDir = path.join(DIST, 'themes', theme);
  await mkdir(path.join(dstDir, 'assets'), { recursive: true });
  for (const page of PAGES) {
    const { before, after } = await minifyPage(path.join(srcDir, page), path.join(dstDir, page));
    totalBefore += before; totalAfter += after;
  }
  // logo.svg is tiny and hand-optimized; copy as-is
  await copyFile(path.join(srcDir, 'assets', 'logo.svg'), path.join(dstDir, 'assets', 'logo.svg'));
  console.log(`${theme}: minified ${PAGES.length} pages`);
}

// Fonts and the voucher tool are already optimized / needed verbatim.
await mkdir(path.join(DIST, 'fonts'), { recursive: true });
for (const f of await readdir(path.join(ROOT, 'fonts'))) {
  await copyFile(path.join(ROOT, 'fonts', f), path.join(DIST, 'fonts', f));
}

const pct = totalBefore ? ((1 - totalAfter / totalBefore) * 100).toFixed(1) : '0';
console.log(`\nPages: ${(totalBefore / 1024).toFixed(1)}KB -> ${(totalAfter / 1024).toFixed(1)}KB  (-${pct}%)`);
console.log(`Output: ${path.relative(ROOT, DIST)}/`);
