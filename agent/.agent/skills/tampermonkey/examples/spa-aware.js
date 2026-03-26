// ==UserScript==
// @name         Example: SPA-Aware Script
// @namespace    https://github.com/example
// @version      1.0.0
// @description  Enhance a React/Vue SPA with persistent modifications across navigation
// @author       Example
// @license      MIT
// @match        https://app.example.com/*
// @grant        GM_addStyle
// @grant        window.onurlchange
// @run-at       document-idle
// @noframes
// ==/UserScript==

(function() {
    'use strict';

    // --- Constants ---
    const SCRIPT_TAG = '[SPA Script]';
    const SELECTORS = {
        appRoot: '#app',
        taskList: '.task-list',
        taskItem: '.task-item',
        taskTitle: '.task-item__title',
    };

    // --- State ---
    const processed = new WeakSet();

    // --- Utilities ---
    function waitForElement(selector, { timeout = 10000, root = document.body } = {}) {
        return new Promise((resolve, reject) => {
            const el = document.querySelector(selector);
            if (el) { resolve(el); return; }
            const observer = new MutationObserver((_, obs) => {
                const el = document.querySelector(selector);
                if (el) { obs.disconnect(); resolve(el); }
            });
            observer.observe(root, { childList: true, subtree: true });
            if (timeout > 0) {
                setTimeout(() => {
                    observer.disconnect();
                    reject(new Error(`${SCRIPT_TAG} Timeout waiting for: ${selector}`));
                }, timeout);
            }
        });
    }

    // --- Styles ---
    GM_addStyle(`
        .task-item--enhanced {
            position: relative;
        }
        .task-item__word-count {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 11px;
            color: #999;
            background: #f5f5f5;
            padding: 2px 6px;
            border-radius: 3px;
        }
    `);

    // --- Core Logic ---
    function enhanceTask(taskEl) {
        if (processed.has(taskEl)) return;
        processed.add(taskEl);

        taskEl.classList.add('task-item--enhanced');

        const titleEl = taskEl.querySelector(SELECTORS.taskTitle);
        if (!titleEl) return;

        // Add word count badge
        const trimmed = (titleEl.textContent || '').trim();
        const wordCount = trimmed ? trimmed.split(/\s+/).length : 0;
        const badge = document.createElement('span');
        badge.className = 'task-item__word-count';
        badge.textContent = `${wordCount} words`;
        taskEl.appendChild(badge);
    }

    async function processPage() {
        // Check if current page has task list
        if (!location.pathname.startsWith('/tasks')) return;

        try {
            const taskList = await waitForElement(SELECTORS.taskList, { timeout: 5000 });
            const tasks = taskList.querySelectorAll(SELECTORS.taskItem);
            tasks.forEach(enhanceTask);

            // Watch for dynamically added tasks (infinite scroll, real-time updates)
            const listObserver = new MutationObserver((mutations) => {
                for (const mutation of mutations) {
                    for (const node of mutation.addedNodes) {
                        if (node.nodeType !== Node.ELEMENT_NODE) continue;
                        if (node.matches(SELECTORS.taskItem)) {
                            enhanceTask(node);
                        }
                        // Also check children (e.g., if a wrapper div is added)
                        node.querySelectorAll?.(SELECTORS.taskItem)?.forEach(enhanceTask);
                    }
                }
            });
            listObserver.observe(taskList, { childList: true, subtree: true });

            // Store observer so we can clean up on navigation
            return listObserver;
        } catch {
            // Page doesn't have task list (e.g., navigated to /settings)
            console.debug(`${SCRIPT_TAG} No task list on this page`);
        }
    }

    // --- Lifecycle ---
    let activeObserver = null;

    async function handleNavigation() {
        // Clean up previous observer
        if (activeObserver) {
            activeObserver.disconnect();
            activeObserver = null;
        }
        // Process new page
        activeObserver = await processPage();
    }

    // Initial page load
    handleNavigation();

    // SPA navigation via Tampermonkey's URL change API
    if (window.onurlchange === null) {
        window.addEventListener('urlchange', () => {
            console.debug(`${SCRIPT_TAG} URL changed to:`, location.href);
            handleNavigation();
        });
    } else {
        // Fallback: observe DOM for URL changes
        let lastURL = location.href;
        new MutationObserver(() => {
            if (location.href !== lastURL) {
                lastURL = location.href;
                console.debug(`${SCRIPT_TAG} URL changed to:`, location.href);
                handleNavigation();
            }
        }).observe(document.body, { childList: true, subtree: true });
    }
})();
