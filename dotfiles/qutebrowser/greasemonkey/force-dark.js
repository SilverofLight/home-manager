// ==UserScript==
// @name         example dark background
// @namespace    https://example.com
// @match        *://cloud.oppo.com/*
// @run-at       document-end
// @grant        none
// ==/UserScript==

(function() {
    const style = document.createElement('style');
    style.textContent = `
    html, body {
      background-color: #282a36 !important;
    }
  `;
    document.documentElement.appendChild(style);
})();
