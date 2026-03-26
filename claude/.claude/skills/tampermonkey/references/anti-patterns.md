# Anti-Patterns and Fixes

## Metadata Anti-Patterns

### 1. Overly Broad URL Matching

```javascript
// BAD
// @match        *://*/*
// @include      *

// GOOD
// @match        https://www.example.com/*
// @match        https://app.example.com/dashboard/*
```

### 2. Mixing @grant none with Other Grants

```javascript
// BUG: @grant none silently overrides -- GM_addStyle won't work
// @grant        none
// @grant        GM_addStyle

// FIX: Remove @grant none
// @grant        GM_addStyle
```

### 3. Missing @connect for GM_xmlhttpRequest

```javascript
// BAD: Will prompt user every time
// @grant        GM_xmlhttpRequest

// GOOD: Declare domains explicitly
// @grant        GM_xmlhttpRequest
// @connect      api.example.com
// @connect      cdn.example.com
```

### 4. No SRI on @require / @resource

```javascript
// BAD: Vulnerable to CDN compromise
// @require      https://cdn.jsdelivr.net/npm/lodash@4/lodash.min.js

// GOOD: SRI hash verifies integrity
// @require      https://cdn.jsdelivr.net/npm/lodash@4/lodash.min.js#sha256=GwIlPPiTk...
```

### 5. Missing @noframes

```javascript
// BAD: Script runs in every iframe on the page (duplicate execution, errors)
// @match        https://example.com/*

// GOOD: Skip iframes unless you need them
// @match        https://example.com/*
// @noframes
```

## Code Anti-Patterns

### 6. Polling for Elements

```javascript
// BAD: Wastes CPU, unreliable timing, significantly less efficient than MutationObserver
const interval = setInterval(() => {
    const el = document.querySelector('.target');
    if (el) {
        clearInterval(interval);
        processElement(el);
    }
}, 100);

// GOOD: Event-driven, efficient
function waitForElement(selector) {
    return new Promise(resolve => {
        const el = document.querySelector(selector);
        if (el) { resolve(el); return; }
        const observer = new MutationObserver((_, obs) => {
            const el = document.querySelector(selector);
            if (el) { obs.disconnect(); resolve(el); }
        });
        observer.observe(document.body, { childList: true, subtree: true });
    });
}
```

### 7. innerHTML with Untrusted Data

```javascript
// BAD: XSS vulnerability
const name = document.querySelector('.user-name').innerHTML;
myDiv.innerHTML = `Welcome, ${name}!`;

// GOOD: Safe text insertion
const name = document.querySelector('.user-name').textContent;
myDiv.textContent = `Welcome, ${name}!`;
```

### 8. Hardcoded API Keys

```javascript
// BAD
const API_KEY = 'sk-abc123def456';

// ACCEPTABLE: Stored per-user (plaintext -- only for low-risk, rotatable tokens)
let apiKey = GM_getValue('api_key', '');
if (!apiKey) {
    apiKey = prompt('Please enter your API key:');
    if (apiKey) GM_setValue('api_key', apiKey);
}
// For high-value secrets, see references/security-guide.md "Secrets & Token Threat Model"
```

### 9. No Error Handling on GM_xmlhttpRequest

```javascript
// BAD: Silent failures
GM_xmlhttpRequest({
    url: 'https://api.example.com/data',
    onload: (res) => { processData(res.responseText); }
});

// GOOD: Handle all error states
GM_xmlhttpRequest({
    url: 'https://api.example.com/data',
    responseType: 'json',
    timeout: 15000,
    onload: (res) => {
        if (res.status < 200 || res.status >= 300) {
            console.error(`[Script] HTTP ${res.status}:`, res.statusText);
            return;
        }
        processData(res.response);
    },
    onerror: (err) => console.error('[Script] Request error:', err),
    ontimeout: () => console.error('[Script] Request timed out'),
    onabort: () => console.warn('[Script] Request aborted'),
});
```

### 10. Unnecessary jQuery Dependency

```javascript
// BAD: Loading 90KB for simple DOM queries
// @require      https://code.jquery.com/jquery-3.7.1.min.js
$('.target').text('Hello');
$('.list li').each(function() { /* ... */ });

// GOOD: Native APIs (zero overhead)
document.querySelector('.target').textContent = 'Hello';
document.querySelectorAll('.list li').forEach(el => { /* ... */ });
```

### 11. No Global Scope Protection

```javascript
// BAD: Pollutes global scope, conflicts with page scripts
var myVar = 'hello';
function myFunc() { /* ... */ }

// GOOD: IIFE encapsulation
(function() {
    'use strict';
    const myVar = 'hello';
    function myFunc() { /* ... */ }
})();
```

### 12. Relying Only on @run-at for SPAs

```javascript
// BAD: Only runs once on initial load
// @run-at       document-idle
function modifyContent() {
    const el = document.querySelector('.dynamic-content');
    if (el) el.style.color = 'red';
}
modifyContent();

// GOOD: Re-run on SPA navigation
// @grant        window.onurlchange
function modifyContent() { /* ... */ }
modifyContent();
window.addEventListener('urlchange', () => modifyContent());
```

### 13. Unnecessary unsafeWindow Usage

```javascript
// BAD: Exposing script context to page
unsafeWindow.myHelper = function() {
    GM_setValue('key', 'value'); // Page can now access GM_setValue!
};

// GOOD: Use CustomEvent for page communication
window.addEventListener('my-script-event', (e) => {
    const data = e.detail;
    // Process in userscript context (safe)
});

// From page context (injected via GM_addElement):
GM_addElement('script', {
    textContent: `
        window.dispatchEvent(new CustomEvent('my-script-event', {
            detail: { action: 'getData' }
        }));
    `
});
```

### 14. Not Using Batch Storage Operations

```javascript
// BAD: Multiple round-trips (pre-v5.3 style)
const a = GM_getValue('setting_a', '');
const b = GM_getValue('setting_b', '');
const c = GM_getValue('setting_c', '');

// GOOD: Single batch operation (v5.3+)
const values = GM_getValues(['setting_a', 'setting_b', 'setting_c']);
// Or with defaults:
const values = GM_getValues({
    setting_a: 'default_a',
    setting_b: 'default_b',
    setting_c: 'default_c',
});
```

### 15. Forgetting to Disconnect MutationObserver

```javascript
// BAD: Observer runs forever, leaking memory
new MutationObserver((mutations) => {
    mutations.forEach(m => { /* process */ });
}).observe(document.body, { childList: true, subtree: true });

// GOOD: Disconnect when task is complete
const observer = new MutationObserver((mutations, obs) => {
    if (taskComplete()) {
        obs.disconnect();
    }
    // process mutations
});
observer.observe(document.body, { childList: true, subtree: true });
```
