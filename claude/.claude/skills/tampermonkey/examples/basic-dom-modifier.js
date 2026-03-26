// ==UserScript==
// @name         Example: Basic DOM Modifier
// @namespace    https://github.com/example
// @version      1.0.0
// @description  Hide annoying elements and restyle a page
// @author       Example
// @license      MIT
// @match        https://www.example.com/*
// @exclude      https://www.example.com/admin/*
// @grant        GM_addStyle
// @run-at       document-start
// @noframes
// ==/UserScript==

(function() {
    'use strict';

    // --- Inject CSS early to prevent FOUC ---
    GM_addStyle(`
        .ad-banner,
        .popup-overlay,
        .newsletter-signup {
            display: none !important;
        }

        .main-content {
            max-width: 800px;
            margin: 0 auto;
            font-size: 16px;
            line-height: 1.6;
        }
    `);

    // --- Wait for DOM to be ready ---
    function waitForElement(selector, timeout = 10000) {
        return new Promise((resolve, reject) => {
            const el = document.querySelector(selector);
            if (el) { resolve(el); return; }
            const observer = new MutationObserver((_, obs) => {
                const el = document.querySelector(selector);
                if (el) { obs.disconnect(); resolve(el); }
            });
            observer.observe(document.documentElement, { childList: true, subtree: true });
            if (timeout > 0) {
                setTimeout(() => { observer.disconnect(); reject(new Error(`Timeout: ${selector}`)); }, timeout);
            }
        });
    }

    // --- Main logic (deferred until DOM is ready despite document-start) ---
    async function main() {
        try {
            const content = await waitForElement('.main-content');

            // Add a custom header
            const header = document.createElement('div');
            header.textContent = 'Enhanced by userscript';
            header.style.cssText = 'padding: 4px 8px; background: #e8f5e9; border-radius: 4px; font-size: 12px; margin-bottom: 8px;';
            content.prepend(header);

            // Remove specific elements safely
            document.querySelectorAll('.tracking-pixel').forEach(el => el.remove());

            console.log('[DOM Modifier] Page enhanced successfully');
        } catch (err) {
            console.error('[DOM Modifier]', err);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', main);
    } else {
        main();
    }
})();
