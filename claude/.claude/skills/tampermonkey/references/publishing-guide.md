# Publishing & Distribution Guide

## Greasy Fork Rules

### Code Requirements

1. **No obfuscated or minified code** -- all code must be human-readable
2. **Primary functionality must be in the script** -- not loaded from external sources at runtime
3. **Maximum 2 MB** script size

### External Code Rules

Greasy Fork distinguishes between executable and non-executable external resources:

| Type | Rule |
|------|------|
| **@require (executable)** | Must come from: Greasy Fork libraries, approved CDNs (cdnjs, jsdelivr, unpkg, etc.), or URLs with Tampermonkey SRI hash |
| **@resource (non-executable)** | Data files (CSS, JSON, images) have fewer restrictions but must be disclosed |
| **Same-origin injection** | Scripts that inject code from the same Greasy Fork author are allowed |
| **Runtime-loaded code** | `eval()`, `new Function()`, or fetching JS at runtime is **prohibited** |

See [Greasy Fork external scripts policy](https://greasyfork.org/en/help/external-scripts) for the full allowlist.

### Disclosure Requirements

Use `@antifeature` to disclose:

```javascript
// @antifeature  tracking    Uses Google Analytics
// @antifeature  ads         Shows banner advertisements
// @antifeature  miner       Mines cryptocurrency (will be scrutinized heavily)
```

### Licensing

Always specify a license for public scripts:

```javascript
// @license      MIT
// @license      GPL-3.0-only
// @license      Apache-2.0
```

## Auto-Update Configuration

### For Greasy Fork

Greasy Fork handles updates automatically. Just increment `@version`:

```javascript
// @version      1.0.0  →  1.0.1
```

### For Self-Hosted Scripts

```javascript
// @updateURL    https://raw.githubusercontent.com/user/repo/main/script.meta.js
// @downloadURL  https://raw.githubusercontent.com/user/repo/main/script.user.js
```

- `@updateURL` points to a metadata-only file (lightweight version check)
- `@downloadURL` points to the full script (downloaded when version differs)

### Meta File (for @updateURL)

Create a `.meta.js` file containing only the metadata block:

```javascript
// ==UserScript==
// @name         My Script
// @version      1.2.3
// @updateURL    https://raw.githubusercontent.com/user/repo/main/script.meta.js
// @downloadURL  https://raw.githubusercontent.com/user/repo/main/script.user.js
// ==/UserScript==
```

## Distribution Channels

| Channel | Pros | Cons |
|---------|------|------|
| Greasy Fork | Largest userscript community, auto-update | Code rules, no minification |
| OpenUserJS | Open-source focused | Smaller community |
| GitHub | Full version control, CI/CD | Manual installation for users |
| Direct URL | Full control | No discoverability |

## GitHub-Based Workflow

### Repository Structure

```
my-userscript/
├── src/
│   └── script.user.js      # Main script
├── dist/
│   ├── script.user.js      # Built/released version
│   └── script.meta.js      # Metadata-only for update checks
├── package.json             # For build tools (optional)
├── README.md
└── LICENSE
```

### Installation URL

Users can install directly from GitHub raw URLs ending in `.user.js`:

```
https://raw.githubusercontent.com/user/repo/main/dist/script.user.js
```

Tampermonkey recognizes `.user.js` URLs and prompts for installation.

## TypeScript Development

For complex scripts, use a TypeScript + bundler setup:

### Type Definitions

```bash
npm install -D @types/tampermonkey
```

This provides types for all GM_* APIs.

### Build Pipeline

```json
// package.json
{
  "scripts": {
    "build": "webpack --mode production",
    "dev": "webpack --mode development --watch"
  }
}
```

### Webpack + Banner Plugin

Use `webpack-userscript` or manually prepend the metadata block:

```javascript
// webpack.config.js
const { BannerPlugin } = require('webpack');
const metadata = require('./src/metadata');

module.exports = {
    entry: './src/index.ts',
    output: { filename: 'script.user.js' },
    plugins: [
        new BannerPlugin({ banner: metadata, raw: true }),
    ],
};
```

## Testing Userscripts

### Local Development

1. Enable Tampermonkey's "Allow access to file URLs" in browser extension settings
2. Create a script with `@require file:///path/to/local/script.js`
3. Or use Tampermonkey's built-in editor for quick iteration

### Automated Testing

For complex scripts, extract logic into testable modules:

```javascript
// utils.js (testable with Jest/Vitest)
export function parseData(html) { /* ... */ }
export function formatOutput(data) { /* ... */ }

// script.user.js (integration)
import { parseData, formatOutput } from './utils';
```
