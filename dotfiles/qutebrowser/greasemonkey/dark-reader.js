// ==UserScript==
// @name          Dark Reader (Unofficial)
// @icon          https://darkreader.org/images/darkreader-icon-256x256.png
// @namespace     DarkReader
// @description	  Inverts the brightness of pages to reduce eye strain
// @version       4.7.15
// @author        https://github.com/darkreader/darkreader#contributors
// @match         *://*.giantesswaltz.org/*
// @match         *://cloud.oppo.com/*
// @homepageURL   https://darkreader.org/ | https://github.com/darkreader/darkreader
// @run-at        document-end
// @grant         none
// @include       *
// @require       https://cdn.jsdelivr.net/npm/darkreader/darkreader.min.js
// @noframes
// ==/UserScript==

DarkReader.enable({
    brightness: 100,
    contrast: 100,
    sepia: 0
});

(function() {
    const host = location.hostname;

    const style = document.createElement('style');

    /* ===============================
     * OPPO Cloud（DOM 背景）
     * =============================== */
    if (host.includes('oppo.com')) {
        style.textContent = `
      body.nobg,
      #index-app,
      .wrapper_body,
      .cloud-box {
        background-color: #282a36 !important;
      }
    `;
    }

    if (style.textContent.trim()) {
        document.documentElement.appendChild(style);
    }
})();
