# Security Guide

## unsafeWindow

### What It Does

`unsafeWindow` provides direct access to the page's `window` object, bypassing the sandbox. This means:
- The page can detect your script
- The page can access your GM_* functions if you expose them
- Malicious pages can exploit this to escalate privileges

### Rules

1. **Never use `unsafeWindow` unless absolutely necessary**
2. **Never pass GM_* function references through `unsafeWindow`**
3. **Never store sensitive data on `unsafeWindow`**
4. If you must use it, document the justification clearly

### Safer Alternatives

| Need | Instead of unsafeWindow | Use |
|------|------------------------|-----|
| Read page variable | `unsafeWindow.someVar` | Inject a `<script>` via `GM_addElement` that sends data via `CustomEvent` |
| Call page function | `unsafeWindow.someFn()` | `GM_addElement('script', { textContent: 'someFn()' })` |
| DOM-only access | `unsafeWindow.document` | Just use `document` (it's the same DOM) |

### Firefox-specific: cloneInto / exportFunction

On Firefox with `@sandbox JavaScript`, sharing objects with the page requires:

```javascript
// Sharing an object
unsafeWindow.myData = cloneInto({ key: 'value' }, unsafeWindow);

// Sharing a function
unsafeWindow.myCallback = exportFunction(function(arg) {
    // Safe: this function runs in userscript context
    return arg.toUpperCase();
}, unsafeWindow);
```

## Subresource Integrity (SRI)

### Why

`@require` and `@resource` load external files. Without SRI, a compromised CDN could serve malicious code.

### How

```javascript
// Generate hash:
// curl -s https://cdn.example.com/lib.js | openssl dgst -sha256 -binary | openssl base64

// @require https://cdn.example.com/lib.js#sha256=BASE64_HASH_HERE
// @resource myCSS https://cdn.example.com/style.css#sha256=BASE64_HASH_HERE
```

### Supported Algorithms

- **SHA-256** (recommended)
- Multiple algorithms can be specified comma-separated: `#sha256=ABC,md5=DEF`
- Consult Tampermonkey documentation for the full list of supported hash algorithms

## Input Validation

### Never Trust Page Data

```javascript
// BAD: XSS vulnerability
const username = document.querySelector('.username').innerHTML;
document.querySelector('#display').innerHTML = `Hello, ${username}`;

// GOOD: Safe text insertion
const username = document.querySelector('.username').textContent;
document.querySelector('#display').textContent = `Hello, ${username}`;
```

### Sanitize Before DOM Insertion

```javascript
// BAD: Direct HTML insertion of external data
GM_xmlhttpRequest({
    url: 'https://api.example.com/data',
    onload: (res) => {
        document.body.innerHTML += res.responseText; // XSS!
    }
});

// GOOD: Parse and insert safely
GM_xmlhttpRequest({
    url: 'https://api.example.com/data',
    responseType: 'json',
    onload: (res) => {
        const data = res.response;
        const el = document.createElement('div');
        el.textContent = data.message; // Safe
        document.body.appendChild(el);
    }
});
```

### Validate postMessage Data

```javascript
window.addEventListener('message', (event) => {
    // Always check origin
    if (event.origin !== 'https://trusted-site.com') return;

    // Validate data structure
    if (typeof event.data !== 'object' || !event.data.type) return;

    // Process only known message types
    switch (event.data.type) {
        case 'update':
            handleUpdate(event.data.payload);
            break;
        // Ignore unknown types
    }
});
```

## GM_xmlhttpRequest Security

### Cross-Origin Power = Cross-Origin Risk

`GM_xmlhttpRequest` bypasses CORS. This is powerful but dangerous:

```javascript
// GOOD: Strip cookies for anonymous requests
GM_xmlhttpRequest({
    url: 'https://api.example.com/data',
    anonymous: true, // Strips cookies
    onload: (res) => { /* ... */ }
});

// GOOD: Always handle errors
GM_xmlhttpRequest({
    url: 'https://api.example.com/data',
    timeout: 10000,
    onload: (res) => {
        if (res.status !== 200) {
            console.error('Unexpected status:', res.status);
            return;
        }
        // Process response
    },
    onerror: (err) => console.error('Request failed:', err),
    ontimeout: () => console.error('Request timed out'),
    onabort: () => console.warn('Request aborted'),
});
```

### anonymous Mode Details

Setting `anonymous: true` strips cookies and HTTP auth from the request. Note that this also forces a different fetch mode internally, which may affect:
- CORS preflight behavior
- Server-side session detection
- Response caching

### Never Send Credentials to Untrusted Domains

```javascript
// DANGEROUS: Sending cookies to unknown domain
GM_xmlhttpRequest({
    url: userProvidedURL, // Could be attacker's server
    // cookies are sent by default!
});

// SAFE: Strip cookies for user-provided URLs
GM_xmlhttpRequest({
    url: userProvidedURL,
    anonymous: true,
});
```

## Secret Management

```javascript
// BAD: Hardcoded API key
const API_KEY = 'sk-abc123';

// ACCEPTABLE for low-risk tokens (free-tier, rate-limited, easily rotated)
// See "Secrets & Token Threat Model" below for risks and alternatives
let apiKey = GM_getValue('api_key', '');
if (!apiKey) {
    apiKey = prompt('Enter your API key:');
    if (apiKey) GM_setValue('api_key', apiKey);
}
```

## Secrets & Token Threat Model

### GM_setValue Is NOT a Secure Vault

`GM_setValue` stores data in **plaintext** in the browser's extension storage. Risks:
- Anyone with local machine access can read browser extension storage
- Tampermonkey's sync/export feature may send stored values to cloud services
- Tampermonkey's dashboard exposes all stored values in plaintext
- Backup/migration tools may include stored values in plaintext exports

### When GM_setValue Is Acceptable

- **Low-risk convenience tokens**: API keys that are free-tier, rate-limited, or easily rotated
- **User preferences and settings**: Non-sensitive configuration
- **Session-scoped data**: Temporary state that expires naturally

### When GM_setValue Is NOT Enough

For high-value, long-lived secrets:
1. **Use short-lived / low-privilege tokens** -- minimize blast radius if leaked
2. **Use revocable tokens** -- so the user can invalidate a compromised key
3. **Prompt per-session** -- ask the user each browser session, don't persist
4. **Server-side proxy** -- keep the real API key on your server, expose a proxy endpoint
5. **Never store** OAuth tokens, payment credentials, or admin API keys in GM_setValue

### Warn Users About Sync/Export

```javascript
// If persisting a token, warn the user about sync risk
GM_registerMenuCommand('Set API Token', () => {
    const token = prompt(
        'Enter your API token.\n\n' +
        'Note: This will be stored in Tampermonkey\'s local storage (plaintext). ' +
        'If you use Tampermonkey sync/export, this token may be included.'
    );
    if (token) GM_setValue('api_token', token);
});
```

## Content Security Policy (CSP)

Some sites have strict CSP that blocks inline scripts and styles. Use GM_* APIs to bypass:

```javascript
// GM_addStyle bypasses CSP for CSS
GM_addStyle('.my-class { color: red; }');

// GM_addElement bypasses CSP for scripts
GM_addElement('script', { textContent: 'console.log("bypassed CSP")' });
```

## @grant: Omitted vs `none`

### Omitting @grant (Empty Grant List)

When no `@grant` line appears in the metadata, Tampermonkey treats this as an empty grant list. The actual behavior depends on Tampermonkey's settings and version -- it may or may not sandbox the script.

### @grant none (Explicit No-Sandbox)

`@grant none` explicitly requests:
- Script runs in the page's JavaScript context with no sandbox
- **No** GM_* APIs available (except `GM_info`)
- Page scripts CAN detect and interfere with your script
- Page scripts could override `Array.prototype.forEach`, `JSON.parse`, etc.

These are **different**. The official documentation states: "an empty `@grant` list is different from using `none`."

### Recommendation

- If you need GM_* APIs: grant them explicitly
- If you only need DOM access and want isolation: use `@grant GM_info` (minimal grant to enable sandbox)
- If you truly want page-context execution: use `@grant none` and accept the risks
- **Never mix `@grant none` with other grants** -- `none` takes precedence silently
