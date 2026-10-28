// Lints the Node build scripts (ESM). The theme pages' inline JS targets old
// phone browsers and is checked separately with `new Function()` in CI, not here.
import js from '@eslint/js';

export default [
  js.configs.recommended,
  {
    files: ['scripts/*.mjs'],
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: 'module',
      // document appears only inside Playwright page.evaluate() callbacks (browser context).
      globals: { process: 'readonly', console: 'readonly', Buffer: 'readonly', URL: 'readonly', document: 'readonly' },
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'no-undef': 'error',
    },
  },
  { ignores: ['dist/', 'themes/', 'fonts/', 'previews/', '*.html', 'vouchers/'] },
];
