# Metadata Block Guide

## @match vs @include

**Always prefer `@match`** -- it follows Chrome's [match patterns spec](https://developer.chrome.com/docs/extensions/mv2/match_patterns/) and is stricter about wildcards.

### @match Syntax

```
<scheme>://<host><path>
```

| Pattern | Matches |
|---------|---------|
| `https://www.example.com/*` | All pages on example.com |
| `https://*.example.com/*` | All subdomains of example.com |
| `*://example.com/api/*` | Both HTTP and HTTPS on /api/ |
| `https://example.com/page?id=*` | Query string matching |

### Why not @include

`@include` with `://` can match unintended URLs. For example:
- `*://tmnk.net/*` also matches `https://example.com/?http://tmnk.net/`

`@match` is preferred over `@include` due to its stricter, more predictable matching semantics. Both remain functional.

### Limitations

Neither `@match` nor `@include` can match URL hash fragments (`#`), which is important for SPAs. Use script-level checks for hash-based routing.

## @grant Patterns

### Principle of Least Privilege

```javascript
// GOOD: Only grant what you use
// @grant        GM_addStyle
// @grant        GM_xmlhttpRequest

// BAD: Granting everything
// @grant        GM_addStyle
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @grant        GM_notification
// @grant        GM_setClipboard
```

### Critical Rule: @grant none

`@grant none` means:
- Script runs in the page's JavaScript context
- **No** GM_* APIs available (except `GM_info`)
- Page scripts CAN detect and interfere with your script
- Page scripts could override `window` methods your script depends on

**Never mix `@grant none` with other grants** -- `none` takes precedence silently:

```javascript
// BUG: GM_addStyle will NOT work because @grant none overrides
// @grant        none
// @grant        GM_addStyle
```

## @run-at Timing

| Value | When | Use Case |
|-------|------|----------|
| `document-start` | ASAP, before DOM exists | CSS injection, early interception |
| `document-body` | When `<body>` exists | Early DOM manipulation |
| `document-end` | At/after DOMContentLoaded | Most scripts |
| `document-idle` | After DOMContentLoaded (default) | Non-time-critical scripts |
| `context-menu` | On right-click | Context menu actions only |

### Timing for CSS Injection (Prevent FOUC)

```javascript
// @run-at       document-start
// @grant        GM_addStyle

GM_addStyle(`
    .annoying-element { display: none !important; }
`);
```

## @connect

Required for `GM_xmlhttpRequest`. Both the initial URL and final redirect URL are checked.

```javascript
// GOOD: Specific domains first, then wildcard fallback
// @connect      api.example.com
// @connect      cdn.example.com
// @connect      *

// BAD: Only wildcard (user gets no useful prompt)
// @connect      *
```

## @resource with SRI

```javascript
// @resource     myCSS https://cdn.example.com/style.css#sha256=abc123
// @resource     myJSON https://cdn.example.com/data.json#sha256=def456

// Usage:
const css = GM_getResourceText('myCSS');
GM_addStyle(css);

const dataURL = GM_getResourceURL('myJSON');
```

## @require with SRI

```javascript
// @require      https://cdn.jsdelivr.net/npm/lodash@4.17.21/lodash.min.js#sha256=abc123

// Multiple hashes (comma-separated):
// @require      https://example.com/lib.js#sha256=abc123,md5=def456
```

## @noframes

Prevents script execution in `<iframe>` elements. Add unless your script specifically needs to run in frames.

```javascript
// @noframes
```

## @sandbox

Controls the **desired** execution context. The actual behavior depends on the browser and Tampermonkey version -- these are hints, not guarantees.

| Value | Desired Behavior | Notes |
|-------|-----------------|-------|
| `raw` | Page context (MAIN_WORLD) | Default; full access to page JS |
| `JavaScript` | Needs `unsafeWindow` access | On Firefox, may create a separate USERSCRIPT_WORLD |
| `DOM` | DOM-only, no page JS interaction | On supported browsers, runs in ISOLATED_WORLD |

**Important caveats:**
- The mapping above is the *intended* behavior; browsers may fall back to a different world if the requested one is unavailable
- On Chrome with CSP restrictions, `raw` may not work as expected
- On Firefox, `JavaScript` mode requires `cloneInto`/`exportFunction` to share data with the page
- Always test your script's sandbox behavior on each target browser

## @antifeature (for Greasy Fork)

Required to disclose tracking, ads, or miners:

```javascript
// @antifeature  tracking  Uses Google Analytics for usage stats
// @antifeature  ads       Shows a small banner ad
```

## Version Best Practices

Use semantic versioning for auto-update:

```javascript
// @version      1.2.3
// Major.Minor.Patch
// Major: Breaking changes
// Minor: New features
// Patch: Bug fixes
```

## Internationalization

```javascript
// @name         My Script
// @name:zh-CN   我的脚本
// @name:ja      私のスクリプト
// @description  Does something cool
// @description:zh-CN 做一些很酷的事情
```
