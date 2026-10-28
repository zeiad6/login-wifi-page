#!/usr/bin/env node
// Basic structural validator for RouterOS .rsc files: catches the typos that make
// /import fail — unbalanced {} [] () and unterminated "..." strings — before upload.
// It is deliberately conservative: it understands \-continued lines, # comments,
// and \" escapes inside strings. It is a syntax smoke test, not a full parser.
// Usage: node scripts/check-rsc.mjs <file.rsc> [more.rsc ...]
import { readFile } from 'node:fs/promises';

async function check(file) {
  const text = await readFile(file, 'utf8');
  const lines = text.split('\n');
  const depth = { '[': 0, '{': 0, '(': 0 };
  const close = { ']': '[', '}': '{', ')': '(' };
  const problems = [];
  let buf = '', start = 0;

  lines.forEach((line, i) => {
    const lineNo = i + 1;
    if (!buf && line.trimStart().startsWith('#')) return; // whole-line comment
    if (!buf) start = lineNo;
    // backslash line continuation (but not an escaped backslash)
    if (line.endsWith('\\') && !line.endsWith('\\\\')) { buf += line.slice(0, -1); return; }
    buf += line;

    let inStr = false;
    for (let j = 0; j < buf.length; j++) {
      const c = buf[j];
      if (inStr) {
        if (c === '\\') { j++; continue; }   // skip escaped char (\" \\)
        if (c === '"') inStr = false;
        continue;
      }
      if (c === '"') { inStr = true; continue; }
      if (c === '[' || c === '{' || c === '(') depth[c]++;
      else if (close[c]) {
        depth[close[c]]--;
        if (depth[close[c]] < 0) { problems.push(`line ${start}: unexpected '${c}'`); depth[close[c]] = 0; }
      }
    }
    if (inStr) problems.push(`line ${start}: unterminated string`);
    buf = '';
  });

  for (const [open, n] of Object.entries(depth)) {
    if (n > 0) problems.push(`${n} unclosed '${open}'`);
  }
  return problems;
}

let failed = false;
for (const file of process.argv.slice(2)) {
  const problems = await check(file);
  if (problems.length) {
    failed = true;
    console.error(`✗ ${file}`);
    for (const p of problems) console.error(`    ${p}`);
  } else {
    console.log(`✓ ${file}`);
  }
}
if (!process.argv[2]) { console.error('Usage: node scripts/check-rsc.mjs <file.rsc> ...'); process.exit(2); }
process.exit(failed ? 1 : 0);
