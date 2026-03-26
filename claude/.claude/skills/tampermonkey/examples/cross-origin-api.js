// ==UserScript==
// @name         Example: Cross-Origin API Client
// @namespace    https://github.com/example
// @version      1.0.0
// @description  Fetch data from an external API and display it on the page
// @author       Example
// @license      MIT
// @match        https://www.example.com/products/*
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @grant        GM_registerMenuCommand
// @grant        GM_addStyle
// @connect      api.pricecheck.example.com
// @run-at       document-idle
// @noframes
// ==/UserScript==

(function() {
    'use strict';

    // --- Configuration ---
    const API_BASE = 'https://api.pricecheck.example.com/v1';
    const REQUEST_TIMEOUT = 15000;

    // --- API Key Management ---
    // GM_setValue is plaintext storage -- acceptable for low-risk, rotatable tokens only.
    // For high-value secrets, prompt per-session without persisting, or use a server proxy.
    function getApiKey() {
        let key = GM_getValue('api_key', '');
        if (!key) {
            key = prompt(
                '[Price Checker] Enter your API key.\n\n' +
                'Note: stored in Tampermonkey local storage (plaintext). ' +
                'If you use sync/export, this key may be included.'
            );
            if (key) {
                GM_setValue('api_key', key);
            }
        }
        return key;
    }

    // Menu command to reset API key
    GM_registerMenuCommand('Reset API Key', () => {
        const newKey = prompt('Enter new API key:');
        if (newKey) {
            GM_setValue('api_key', newKey);
            alert('API key updated. Reload the page to apply.');
        }
    });

    // --- GM_xmlhttpRequest wrapper with full error handling ---
    function apiRequest(endpoint, options = {}) {
        return new Promise((resolve, reject) => {
            const apiKey = getApiKey();
            if (!apiKey) {
                reject(new Error('No API key configured'));
                return;
            }

            GM_xmlhttpRequest({
                method: options.method || 'GET',
                url: `${API_BASE}${endpoint}`,
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json',
                    ...options.headers,
                },
                data: options.body ? JSON.stringify(options.body) : undefined,
                responseType: 'json',
                timeout: REQUEST_TIMEOUT,
                anonymous: options.anonymous || false,

                onload: (response) => {
                    if (response.status >= 200 && response.status < 300) {
                        resolve(response.response);
                    } else if (response.status === 401) {
                        GM_setValue('api_key', ''); // Clear invalid key
                        reject(new Error('Invalid API key. Please reload and enter a new one.'));
                    } else {
                        reject(new Error(`HTTP ${response.status}: ${response.statusText}`));
                    }
                },
                onerror: (err) => reject(new Error(`Network error: ${err.error || 'Unknown'}`)),
                ontimeout: () => reject(new Error(`Request timed out after ${REQUEST_TIMEOUT}ms`)),
                onabort: () => reject(new Error('Request was aborted')),
            });
        });
    }

    // --- UI ---
    GM_addStyle(`
        .price-checker-badge {
            display: inline-block;
            padding: 4px 8px;
            margin-left: 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .price-checker-badge--good { background: #e8f5e9; color: #2e7d32; }
        .price-checker-badge--bad { background: #ffebee; color: #c62828; }
        .price-checker-badge--loading { background: #e3f2fd; color: #1565c0; }
        .price-checker-badge--error { background: #fff3e0; color: #e65100; }
    `);

    function createBadge(text, type) {
        const badge = document.createElement('span');
        badge.className = `price-checker-badge price-checker-badge--${type}`;
        badge.textContent = text;
        return badge;
    }

    // --- Main ---
    async function main() {
        const priceElement = document.querySelector('.product-price');
        if (!priceElement) return;

        const productId = location.pathname.split('/').pop();
        const badge = createBadge('Checking price...', 'loading');
        priceElement.appendChild(badge);

        try {
            const data = await apiRequest(`/products/${encodeURIComponent(productId)}/price-history`);

            if (data.currentPrice < data.averagePrice) {
                badge.textContent = `${Math.round((1 - data.currentPrice / data.averagePrice) * 100)}% below avg`;
                badge.className = 'price-checker-badge price-checker-badge--good';
            } else {
                badge.textContent = `${Math.round((data.currentPrice / data.averagePrice - 1) * 100)}% above avg`;
                badge.className = 'price-checker-badge price-checker-badge--bad';
            }
        } catch (err) {
            console.error('[Price Checker]', err);
            badge.textContent = 'Price check failed';
            badge.className = 'price-checker-badge price-checker-badge--error';
        }
    }

    main();
})();
