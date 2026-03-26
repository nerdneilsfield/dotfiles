# Cross-Browser Compatibility Guide

## Browser Extension Manifest Versions

### Chrome / Edge / Opera (Manifest V3)

Since Tampermonkey 5.0+, Chrome-based browsers use Manifest V3. The MV3 migration is ongoing and behavior may change between Tampermonkey releases. Key areas to test:

- **GM.xmlHttpRequest (Promise version)**: May be unavailable or limited in some MV3 builds
- **Background service worker**: Replaces persistent background pages; may affect long-running operations
- **Content Security Policy**: Tends to be stricter; `GM_addElement` and `GM_addStyle` can help bypass
- **DeclarativeNetRequest**: Replaces webRequest blocking; may affect scripts that intercept network requests
- **Storage quota**: May differ from MV2

**Practical advice (verify on your target Tampermonkey version):**
- Prefer callback-based `GM_xmlhttpRequest` over Promise-based `GM.xmlHttpRequest` for wider compatibility
- Test `GM_download` behavior -- it may differ under MV3
- Test `@run-at document-start` timing -- it may be slightly delayed compared to MV2

### Firefox (Manifest V2)

Firefox still uses Manifest V2 for Tampermonkey:

- GM_* APIs are generally well-supported; test specific APIs you depend on
- `unsafeWindow` behavior differs: use `cloneInto` and `exportFunction` to share objects with page
- `@sandbox JavaScript` creates a true USERSCRIPT_WORLD on Firefox
- Content scripts have Xray vision by default (can see through page object wrappers)

**Firefox-specific patterns:**
```javascript
// Sharing data with page on Firefox
unsafeWindow.myData = cloneInto({ key: 'value' }, unsafeWindow);

// Sharing a callback with page on Firefox
unsafeWindow.myCallback = exportFunction((arg) => {
    return arg.toUpperCase();
}, unsafeWindow);
```

### Safari (macOS / iOS)

Tampermonkey is available on Safari with limitations:

- **iOS**: Requires Tampermonkey from App Store; more restrictive than desktop
- **macOS**: Generally compatible but may lag behind Chrome/Firefox feature support
- `GM_download` may not be available
- `window.onurlchange` support may vary
- Test SPA detection mechanisms on Safari specifically

### Violentmonkey / Greasemonkey Compatibility

If targeting multiple userscript managers:

| Feature | Tampermonkey | Violentmonkey | Greasemonkey 4 |
|---------|-------------|---------------|----------------|
| `GM_xmlhttpRequest` | Yes | Yes | `GM.xmlHttpRequest` only |
| `GM_addElement` | Yes (experimental) | No | No |
| `GM_cookie` | Yes (experimental) | No | No |
| `GM_getValues/setValues` | Yes (v5.3+) | No | No |
| `window.onurlchange` | Yes | No | No |
| `@sandbox` | Yes | Partial | No |
| `GM_download` | Yes | Yes | No |
| Promise-based APIs (`GM.*`) | Yes | Yes | Yes (primary) |
| Callback-based APIs (`GM_*`) | Yes | Yes | No (removed in v4) |

**Writing portable scripts:**
- Use callback-based `GM_*` APIs for widest compatibility
- Feature-detect Tampermonkey-specific APIs before using them
- Provide fallbacks for `window.onurlchange`, `GM_addElement`, etc.

```javascript
// Feature detection pattern
if (typeof GM_addElement === 'function') {
    GM_addElement('style', { textContent: css });
} else {
    const style = document.createElement('style');
    style.textContent = css;
    document.head.appendChild(style);
}
```

## API Availability Matrix

| API | Chrome MV3 | Firefox MV2 | Safari | Notes |
|-----|-----------|-------------|--------|-------|
| `GM_xmlhttpRequest` | Yes | Yes | Yes | Core API |
| `GM.xmlHttpRequest` | Limited | Yes | Varies | Prefer callback version on Chrome |
| `GM_setValue/getValue` | Yes | Yes | Yes | Core API |
| `GM_addStyle` | Yes | Yes | Yes | Core API |
| `GM_addElement` | Yes | Yes | Varies | Experimental |
| `GM_registerMenuCommand` | Yes | Yes | Yes | Core API |
| `GM_notification` | Yes | Yes | Limited | Safari may not support |
| `GM_download` | Yes | Yes | Limited | Safari restrictions |
| `GM_cookie` | Yes | Limited | No | Experimental |
| `GM_openInTab` | Yes | Yes | Yes | Core API |
| `window.onurlchange` | Yes | Yes | Varies | Tampermonkey-specific |

## Testing Across Browsers

1. **Always test on Chrome AND Firefox** -- they have fundamentally different extension architectures
2. **Test @run-at timing** -- MV3 may delay `document-start` scripts
3. **Test GM_xmlhttpRequest** -- especially timeout and progress events
4. **Test unsafeWindow** -- behavior differs significantly between browsers
5. **Test SPA detection** -- `window.onurlchange` is Tampermonkey-specific
