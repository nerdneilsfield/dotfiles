# SPA (Single Page Application) Patterns

## The Problem

SPAs dynamically change page content without full page reloads. This means:
- `@run-at` fires only once (on initial page load)
- Content may not exist when your script runs
- URL changes don't trigger script re-execution

## URL Change Detection

### Option A: Tampermonkey's Built-in API (Preferred)

```javascript
// @grant        window.onurlchange

// Always check availability first
if (window.onurlchange === null) {
    window.addEventListener('urlchange', (info) => {
        console.log('URL changed to:', info.url);
        handlePageChange();
    });
} else {
    // Fallback: use Option B or C
    console.warn('window.onurlchange not available, using fallback');
}
```

### Option B: History API Interception

```javascript
// Intercept pushState and replaceState
const originalPushState = history.pushState;
const originalReplaceState = history.replaceState;

history.pushState = function(...args) {
    originalPushState.apply(this, args);
    handlePageChange();
};

history.replaceState = function(...args) {
    originalReplaceState.apply(this, args);
    handlePageChange();
};

window.addEventListener('popstate', handlePageChange);
```

### Option C: DOM-driven URL Watching (Last Resort)

Only use if Options A and B are unavailable:

```javascript
let lastURL = location.href;
new MutationObserver(() => {
    if (location.href !== lastURL) {
        lastURL = location.href;
        handlePageChange();
    }
}).observe(document.body, { childList: true, subtree: true });
```

## Waiting for Dynamic Elements

### The waitForElement Pattern

```javascript
function waitForElement(selector, { timeout = 10000, root = document.body } = {}) {
    return new Promise((resolve, reject) => {
        const existing = root.querySelector(selector);
        if (existing) { resolve(existing); return; }

        const observer = new MutationObserver((_, obs) => {
            const el = root.querySelector(selector);
            if (el) {
                obs.disconnect();
                resolve(el);
            }
        });

        observer.observe(root, { childList: true, subtree: true });

        if (timeout > 0) {
            setTimeout(() => {
                observer.disconnect();
                reject(new Error(`waitForElement timeout: ${selector}`));
            }, timeout);
        }
    });
}

// Usage
const sidebar = await waitForElement('.sidebar-content');
```

### Wait for Multiple Elements

```javascript
function waitForElements(selectors, { timeout = 10000 } = {}) {
    return Promise.all(selectors.map(sel => waitForElement(sel, { timeout })));
}

const [header, sidebar, content] = await waitForElements([
    '.header', '.sidebar', '.main-content'
]);
```

### Wait for Element Removal

```javascript
function waitForRemoval(selector, { timeout = 10000 } = {}) {
    return new Promise((resolve, reject) => {
        if (!document.querySelector(selector)) { resolve(); return; }

        const observer = new MutationObserver((_, obs) => {
            if (!document.querySelector(selector)) {
                obs.disconnect();
                resolve();
            }
        });

        observer.observe(document.body, { childList: true, subtree: true });

        if (timeout > 0) {
            setTimeout(() => {
                observer.disconnect();
                reject(new Error(`waitForRemoval timeout: ${selector}`));
            }, timeout);
        }
    });
}

// Wait for loading spinner to disappear
await waitForRemoval('.loading-spinner');
```

## MutationObserver Best Practices

### Observe Minimal Subtree

```javascript
// BAD: Observing entire document
observer.observe(document.body, { childList: true, subtree: true });

// GOOD: Observing specific container
const appRoot = document.querySelector('#app');
observer.observe(appRoot, { childList: true, subtree: true });
```

### Use Specific Options

```javascript
// BAD: Observing everything
observer.observe(target, {
    childList: true,
    subtree: true,
    attributes: true,
    characterData: true,
});

// GOOD: Only what you need
// For new elements:
observer.observe(target, { childList: true, subtree: true });

// For attribute changes (e.g., class changes):
observer.observe(target, { attributes: true, attributeFilter: ['class'] });

// For text content changes:
observer.observe(target, { characterData: true, subtree: true });
```

### Always Disconnect

```javascript
// GOOD: Clean up when done
const observer = new MutationObserver((mutations, obs) => {
    const el = document.querySelector('.target');
    if (el) {
        obs.disconnect(); // Clean up!
        processElement(el);
    }
});
```

### Debounce Rapid Mutations

```javascript
let debounceTimer;
const observer = new MutationObserver(() => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
        // Handle mutations after they settle
        processChanges();
    }, 100);
});
```

## Common SPA Frameworks

### React / Next.js

- Content root is usually `#root` or `#__next`
- React uses virtual DOM, so mutations can be frequent
- Debounce MutationObserver callbacks

### Vue / Nuxt

- Content root is usually `#app`
- Vue's reactivity can trigger many mutations
- Watch for `v-if` / `v-show` attribute changes

### Angular

- Content root is usually `app-root` element
- Angular uses zones that batch DOM updates
- `MutationObserver` works well after zone stabilization

## Full SPA-Aware Script Template

```javascript
// ==UserScript==
// @name         SPA-Aware Script
// @match        https://spa-site.example.com/*
// @grant        window.onurlchange
// @grant        GM_addStyle
// @run-at       document-idle
// @noframes
// ==/UserScript==

(function() {
    'use strict';

    const SELECTORS = {
        content: '.main-content',
        target: '.target-element',
    };

    let processed = new WeakSet();

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

    async function processPage() {
        try {
            const content = await waitForElement(SELECTORS.content);
            const targets = content.querySelectorAll(SELECTORS.target);
            targets.forEach(el => {
                if (processed.has(el)) return;
                processed.add(el);
                // Your modification logic here
            });
        } catch (err) {
            console.error('[SPA Script]', err);
        }
    }

    // Initial run
    processPage();

    // Re-run on URL change (SPA navigation)
    if (window.onurlchange === null) {
        window.addEventListener('urlchange', () => {
            processPage();
        });
    } else {
        // Fallback: detect URL changes via DOM mutations
        let lastURL = location.href;
        new MutationObserver(() => {
            if (location.href !== lastURL) {
                lastURL = location.href;
                processPage();
            }
        }).observe(document.body, { childList: true, subtree: true });
    }
})();
```
