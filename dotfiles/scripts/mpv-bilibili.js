// ==UserScript==
// @name         MPV BiliBili
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Use mpv to play bilibili's video and copy BV number
// @author       SilverOfLight
// @match        https://www.bilibili.com/video/*
// @icon         https://i0.hdslb.com/bfs/static/jinkela/long/images/favicon.ico
// @grant        GM_setClipboard
// @grant        GM_notification
// @grant        GM_xmlhttpRequest
// ==/UserScript==

(function () {
  'use strict';

  const CONTROL_ID = 'my-custom-control-123';
  const COPY_BV_ID = 'copy-bv-button-456';

  const bvid = window.location.href.match(/video\/(BV\w+)/)?.[1];
  if (!bvid) return;

  function playWithMpv() {
    const videoUrl = `http://www.bilibili.com/video/${bvid}`;

    GM_xmlhttpRequest({
      method: "GET",
      url: `http://localhost:15612/play?url=${encodeURIComponent(videoUrl)}`,
      timeout: 3000,
      onload: function (response) {
        if (response.status === 200) {
          pauseBiliVideo();
        } else {
          showNotification(`MPV 启动失败: ${response.status}`);
        }
      },
      onerror: function(err) {
        showNotification(`MPV 启动失败，服务可能未运行`)
      },
      ontimeout: function() {
        showNotification(`MPV 超时`)
      }
    })
  }

  function pauseBiliVideo() {
    let retryCount = 0;
    const tryPause = () => {
      const video = document.querySelector('video');
      if (video && !video.paused) {
        video.pause();
        const pauseBtn = document.querySelector(`.bpx-player-ctrl-play, .bilibili-player-video-btn-start`);
        if (pauseBtn) pauseBtn.click();
        return true
      }
      return retryCount++ < 20
    };
    const interval = setInterval(() => {
      if (!tryPause()) clearInterval(interval);
    }, 100);
  }

  function copyBV() {
    GM_setClipboard(bvid, 'text');
    showNotification('BV id Copyed');
  }

  function showNotification(message) {
    const notif = document.createElement('div');
    notif.textContent = message;
    notif.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #282a36;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
            z-index: 2147483647;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            animation: fadeInOut 3s forwards;
        `;

    const style = document.createElement('style');
    style.textContent = `
            @keyframes fadeInOut {
                0% { opacity: 0; top: 0; }
                10% { opacity: 1; top: 20px; }
                90% { opacity: 1; top: 20px; }
                100% { opacity: 0; top: 0; }
            }
        `;

    document.head.appendChild(style);
    document.body.appendChild(notif);

    setTimeout(() => {
      notif.remove();
      style.remove();
    }, 3000);
  }

  function createButton(id, text, bottom, clickHandler) {
    const button = document.createElement('button');
    button.id = id;
    button.textContent = text;

    button.style.cssText = `
            position: fixed !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            bottom: ${bottom}px !important;
            right: 20px !important;
            z-index: 2147483647 !important;
            padding: 10px !important;
            background: #282a36e6 !important;
            color: white !important;
            border: none !important;
            border-radius: 4px !important;
            cursor: pointer !important;
            font-size: 16px !important;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2) !important;
            line-height: 1 !important;
            transition: transform 0.1s, background 0.2s !important;
        `;

    button.addEventListener('mouseover', () => {
      button.style.background = '#383b4ae6 !important';
    });

    button.addEventListener('mouseout', () => {
      button.style.background = '#282a36e6 !important';
    });

    button.addEventListener('mousedown', () => {
      button.style.transform = 'scale(0.95) !important';
    });

    button.addEventListener('mouseup', () => {
      button.style.transform = 'scale(1) !important';
    });

    button.addEventListener('click', clickHandler);
    document.body.appendChild(button);
    return button;
  }

  function addCustomControls() {
    if (document.getElementById(CONTROL_ID) && document.getElementById(COPY_BV_ID)) return true;

    if (!document.body) return false;

    try {
      // 创建复制BV按钮（位置在上方）
      createButton(COPY_BV_ID, 'copy BV', 70, copyBV);

      // 创建MPV播放按钮（位置在下方）
      createButton(CONTROL_ID, 'Watch with mpv', 20, playWithMpv);

      return true;
    } catch (e) {
      console.error('油猴脚本错误:', e);
      return false;
    }
  }

  function init() {
    if (addCustomControls()) return;
    document.addEventListener('DOMContentLoaded', addCustomControls);
    window.addEventListener('load', addCustomControls);
    setTimeout(addCustomControls, 3000);
  }

  init();
})();
