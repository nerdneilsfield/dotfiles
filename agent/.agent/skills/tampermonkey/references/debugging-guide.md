# Debugging Guide

## Tampermonkey's Built-in Editor

Tampermonkey includes a code editor with:
- Syntax highlighting
- Basic error detection
- Direct save and test cycle
- Access via Tampermonkey dashboard → script → Edit

### Quick Iteration Workflow

1. Open Tampermonkey dashboard
2. Edit script in built-in editor
3. Save (Ctrl+S)
4. Reload target page
5. Check browser console for output

## Local Development with file://

For faster development, use `@require` with local files:

```javascript
// @require      file:///home/user/dev/my-script.js
```

**Setup:**
1. Enable "Allow access to file URLs" in browser extension settings (Chrome: `chrome://extensions` → Tampermonkey → Details)
2. Create a stub userscript with metadata + `@require file://` pointing to your local file
3. Edit the local file in your preferred editor
4. Reload the target page to pick up changes

**Limitations:**
- File path format varies by OS (`file:///C:/...` on Windows, `file:///home/...` on Linux)
- Some browsers restrict file:// access for security
- SRI hashes are not checked for file:// URLs

## Console Debugging

### Prefix All Output

```javascript
const TAG = '[MyScript]';
console.log(TAG, 'Initialized');
console.warn(TAG, 'Element not found:', selector);
console.error(TAG, 'Request failed:', error);
```

### GM_log

`GM_log` writes to the browser console, equivalent to `console.log` but with script attribution:

```javascript
// @grant        GM_log
GM_log('Script started');
```

### GM_info for Diagnostics

`GM_info` is always available (no `@grant` needed) and provides:

```javascript
console.log('Script:', GM_info.script.name, GM_info.script.version);
console.log('Tampermonkey:', GM_info.version);
console.log('Browser:', GM_info.platform?.browserName);
console.log('Script handler:', GM_info.scriptHandler);
```

## Debugging MutationObserver

MutationObserver issues are common. Debug with verbose logging:

```javascript
const observer = new MutationObserver((mutations) => {
    console.group('[MyScript] Mutations');
    mutations.forEach(m => {
        console.log('Type:', m.type, 'Target:', m.target.tagName,
                    'Added:', m.addedNodes.length, 'Removed:', m.removedNodes.length);
    });
    console.groupEnd();
});
```

### Common MutationObserver Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Callback never fires | Wrong observe target or options | Check that the observed element exists and options include the right mutation types |
| Callback fires too often | Observing too broad a subtree | Narrow the observe target; add debouncing |
| Callback fires but element not found | Race condition with virtual DOM | Add `requestAnimationFrame` or small delay before querying |
| Memory leak / page slowdown | Observer never disconnected | Always `disconnect()` when done |

## Debugging GM_xmlhttpRequest

### Log Request and Response

```javascript
function debugRequest(details) {
    const start = Date.now();
    console.log('[MyScript] Request:', details.method || 'GET', details.url);

    const originalOnload = details.onload;
    details.onload = (res) => {
        console.log('[MyScript] Response:', res.status, `(${Date.now() - start}ms)`,
                    'Size:', res.responseText?.length || 0);
        originalOnload?.(res);
    };

    const originalOnerror = details.onerror;
    details.onerror = (err) => {
        console.error('[MyScript] Request error:', err);
        originalOnerror?.(err);
    };

    return GM_xmlhttpRequest(details);
}
```

### Common Request Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `onerror` fires immediately | Missing `@connect` declaration | Add `@connect domain.com` to metadata |
| 403/401 response | Missing or wrong cookies | Check `anonymous` flag; verify auth headers |
| CORS error despite GM_xmlhttpRequest | Using `fetch()` instead of GM API | Replace with `GM_xmlhttpRequest` |
| Response is empty | Wrong `responseType` | Match `responseType` to expected content |

## ESLint for Userscripts

### Configuration

```json
// .eslintrc.json
{
    "env": {
        "browser": true,
        "greasemonkey": true,
        "es2021": true
    },
    "globals": {
        "GM_info": "readonly",
        "GM_getValue": "readonly",
        "GM_setValue": "readonly",
        "GM_xmlhttpRequest": "readonly",
        "GM_addStyle": "readonly",
        "GM_addElement": "readonly",
        "GM_registerMenuCommand": "readonly",
        "GM_unregisterMenuCommand": "readonly",
        "GM_notification": "readonly",
        "GM_setClipboard": "readonly",
        "GM_openInTab": "readonly",
        "GM_download": "readonly",
        "GM_log": "readonly",
        "GM_getResourceText": "readonly",
        "GM_getResourceURL": "readonly",
        "GM_listValues": "readonly",
        "GM_deleteValue": "readonly",
        "GM_addValueChangeListener": "readonly",
        "GM_removeValueChangeListener": "readonly",
        "GM_cookie": "readonly",
        "GM_getTab": "readonly",
        "GM_saveTab": "readonly",
        "unsafeWindow": "readonly"
    },
    "rules": {
        "no-eval": "error",
        "no-implied-eval": "error",
        "no-new-func": "error"
    }
}
```

### TypeScript Type Definitions

```bash
npm install -D @types/tampermonkey
```

This provides complete type definitions for all GM_* APIs, enabling IDE autocompletion and type checking.

## Debugging Checklist

When a userscript doesn't work:

1. **Check Tampermonkey dashboard** -- is the script enabled? Does it match the current URL?
2. **Check browser console** -- any errors? Filter by your script's `[TAG]` prefix
3. **Check @match pattern** -- does it actually match the current page URL?
4. **Check @grant** -- are all used APIs granted? Is `@grant none` accidentally present?
5. **Check @run-at timing** -- is the script running before the DOM is ready?
6. **Check @noframes** -- should the script run in an iframe on this page?
7. **Check element existence** -- use `document.querySelector` in console to verify selectors
8. **Check for SPA navigation** -- does the page use client-side routing?
9. **Check for CSP** -- open DevTools Network tab, look for CSP headers blocking inline scripts/styles
10. **Check Tampermonkey version** -- some APIs require specific minimum versions
