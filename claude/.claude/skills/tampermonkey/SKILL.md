---
name: tampermonkey
description: Tampermonkey userscript development assistant. Use when writing, reviewing, debugging, or optimizing Tampermonkey/Greasemonkey userscripts for browser automation and page customization.
metadata:
  category: browser-scripting
  tags: [tampermonkey, greasemonkey, userscript, browser, automation]
---

# Tampermonkey Userscript Assistant

## Overview

Help users write, review, debug, and optimize Tampermonkey userscripts following best practices for security, performance, and maintainability.

## Working Rules

1. **Security first** -- never use `unsafeWindow` unless absolutely necessary; always validate external data
2. **Principle of least privilege** -- only `@grant` APIs actually used; prefer `@match` over `@include`
3. **No polling by default** -- use `MutationObserver` instead of `setInterval`/`setTimeout` loops; polling acceptable only with documented justification
4. **IIFE + strict mode** -- all scripts wrapped in `(function() { 'use strict'; ... })();`
5. **SRI hashes by default** -- add integrity hashes to `@require` and `@resource`; omit only for local development with `file://`
6. **Specific URL patterns** -- never use `@match *://*/*` unless the script genuinely targets all pages

## Inputs to Gather

- **Target site(s)**: URL patterns the script should run on
- **Goal**: What the script should do (DOM modification, data extraction, UI enhancement, etc.)
- **GM APIs needed**: Cross-origin requests, persistent storage, notifications, etc.
- **SPA handling**: Whether the target site is a Single Page Application
- **Publishing intent**: Greasy Fork, private use, or team distribution

## Workflow

### 1. Generate Metadata Block

Build the `==UserScript==` header following these rules:

**Core fields (required):**

| Field | Rule |
|-------|------|
| `@name` | Clear, descriptive; add `@name:zh-CN` for Chinese localization |
| `@namespace` | Unique URI (e.g., `https://github.com/username`) |
| `@version` | Semver (`1.0.0`) |
| `@description` | Brief summary; add localized variants |
| `@author` | Attribution |
| `@license` | Always specify for public scripts (MIT, GPL-3.0, etc.) |
| `@match` | Most specific patterns possible; combine with `@exclude` |
| `@grant` | Only what's used; **never** mix `@grant none` with other grants |
| `@run-at` | `document-idle` (default) unless earlier timing needed |
| `@noframes` | Add when script should not run in iframes |

**Common optional fields:**

| Field | Rule |
|-------|------|
| `@icon` / `@icon64` | Script icon for dashboard display |
| `@connect` | Declare all domains for `GM_xmlhttpRequest`; list specific domains before `*` |
| `@require` | Always append `#sha256=HASH` for SRI |
| `@resource` | Always append `#sha256=HASH` for SRI |
| `@sandbox` | Execution context hint (`raw`, `JavaScript`, `DOM`); behavior varies by browser |
| `@updateURL` / `@downloadURL` | For self-hosted auto-update |
| `@supportURL` | Link to issue tracker or support page |
| `@homepageURL` | Project homepage |

### 2. Write Script Body

Follow the template structure:

```javascript
// ==UserScript==
// @name         Script Name
// @namespace    https://github.com/username
// @version      1.0.0
// @description  Brief description
// @author       Author
// @license      MIT
// @match        https://www.example.com/*
// @grant        GM_addStyle
// @run-at       document-idle
// @noframes
// ==/UserScript==

(function() {
    'use strict';

    // --- Constants ---
    const SELECTORS = {
        target: '#main .content',
    };

    // --- Utilities ---
    function waitForElement(selector, timeout = 10000) {
        return new Promise((resolve, reject) => {
            const el = document.querySelector(selector);
            if (el) { resolve(el); return; }
            const observer = new MutationObserver((_, obs) => {
                const el = document.querySelector(selector);
                if (el) { obs.disconnect(); resolve(el); }
            });
            observer.observe(document.body, { childList: true, subtree: true });
            if (timeout > 0) {
                setTimeout(() => { observer.disconnect(); reject(new Error(`Timeout: ${selector}`)); }, timeout);
            }
        });
    }

    // --- Main ---
    async function main() {
        try {
            const target = await waitForElement(SELECTORS.target);
            // Script logic here
        } catch (err) {
            console.error('[Script Name]', err);
        }
    }

    main();
})();
```

### 3. Review Checklist

Before delivering any userscript, verify:

- [ ] `@match` patterns are as specific as possible
- [ ] `@grant` lists only APIs actually used
- [ ] `@connect` covers all `GM_xmlhttpRequest` domains
- [ ] No `unsafeWindow` usage (or documented justification)
- [ ] SRI hashes on all `@require` / `@resource`
- [ ] `@noframes` added if iframes are irrelevant
- [ ] MutationObserver used instead of polling
- [ ] Error handling on all GM_xmlhttpRequest calls (`onerror`, `ontimeout`)
- [ ] `textContent` used over `innerHTML` for untrusted data
- [ ] IIFE wrapper with `'use strict'`
- [ ] No hardcoded secrets (use `GM_setValue` for convenience storage; see `references/security-guide.md` for threat model)

### 4. SPA Handling (if applicable)

For Single Page Applications, add URL change detection:

```javascript
// Option A: Tampermonkey's built-in API (preferred)
// @grant        window.onurlchange
if (window.onurlchange === null) {
    window.addEventListener('urlchange', (info) => {
        // Re-run logic for new URL
        main();
    });
}

// Option B: MutationObserver on content container
const appRoot = document.querySelector('#app');
new MutationObserver(() => {
    // Check if relevant content changed
}).observe(appRoot, { childList: true, subtree: true });
```

### 5. Performance Guidelines

- Inject CSS early: `@run-at document-start` + `GM_addStyle` to prevent FOUC
- Observe minimal subtree in MutationObserver (not always `document.body`)
- Always `disconnect()` observers when done
- Use `@require` for libraries (cached at install) instead of runtime fetching
- Prefer native APIs over jQuery (~90KB overhead)
- Use `GM_getValues`/`GM_setValues` (v5.3+) for batch storage operations
- Use `DocumentFragment` for inserting multiple elements

## GM_* API Quick Reference

**Storage:**

| API | Purpose | Notes |
|-----|---------|-------|
| `GM_setValue/getValue` | Persistent key-value storage | Supports objects, strings, numbers, booleans; **plaintext, not a secure vault** |
| `GM_listValues` | List all stored keys | Returns array of key names |
| `GM_deleteValue` | Delete a stored key | |
| `GM_getValues/setValues` | Batch storage (v5.3+) | More efficient than multiple single calls |
| `GM_addValueChangeListener` | Cross-tab sync | Listen for storage changes across tabs |

**DOM & UI:**

| API | Purpose | Notes |
|-----|---------|-------|
| `GM_addStyle` | Inject CSS | Adds to `<head>`; won't work in Shadow DOM |
| `GM_addElement` | Add DOM elements | Bypasses CSP; works in Shadow DOM; **experimental API** |
| `GM_registerMenuCommand` | Add menu items | Returns ID for `GM_unregisterMenuCommand` |
| `GM_unregisterMenuCommand` | Remove menu item | Pass the ID from register |
| `GM_notification` | Desktop notifications | Use `tag` to update existing notifications |
| `GM_setClipboard` | Copy to clipboard | Requires `@grant` |

**Network:**

| API | Purpose | Notes |
|-----|---------|-------|
| `GM_xmlhttpRequest` | Cross-origin HTTP (callback) | Must declare `@connect`; handle all error callbacks |
| `GM.xmlHttpRequest` | Cross-origin HTTP (Promise) | Capital H; unavailable in some MV3 builds |

**Navigation & Tabs:**

| API | Purpose | Notes |
|-----|---------|-------|
| `GM_openInTab` | Open URL in new tab | Returns tab object; options: `active`, `insert`, `setParent` |
| `GM_download` | Download a URL | Options: `url`, `name`, `headers`, `saveAs`, `onerror` |
| `GM_getTab` / `GM_saveTab` | Per-tab persistent data | Survives page reload within same tab |

**Info & Logging:**

| API | Purpose | Notes |
|-----|---------|-------|
| `GM_info` / `GM.info` | Script metadata object | Always available without `@grant` |
| `GM_log` | Log to console | Equivalent to `console.log` with script prefix |
| `GM_cookie` | Cookie management | Experimental; `list`, `set`, `delete` operations |

## References

- `references/metadata-guide.md` -- detailed `@match`, `@grant`, `@run-at` patterns
- `references/security-guide.md` -- `unsafeWindow` risks, SRI, input validation, CSP
- `references/spa-patterns.md` -- SPA detection, URL change handling, MutationObserver patterns
- `references/anti-patterns.md` -- common mistakes and their fixes
- `references/publishing-guide.md` -- Greasy Fork rules, distribution, auto-update
- `references/compatibility-guide.md` -- Chrome MV3 vs Firefox MV2, Safari, API availability matrix
- `references/debugging-guide.md` -- Tampermonkey editor, console debugging, local development, ESLint

## Examples

- `examples/basic-dom-modifier.js` -- simple DOM modification script
- `examples/cross-origin-api.js` -- GM_xmlhttpRequest with error handling
- `examples/spa-aware.js` -- SPA-compatible script with URL change detection
