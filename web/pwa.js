'use strict';

const status = document.getElementById('boot-status');
addEventListener('error', (event) => {
  if (event.target?.tagName === 'SCRIPT') {
    status.textContent = 'Аппыг ачаалж чадсангүй. Интернэтэд холбогдоод дахин оролдоно уу.';
  }
}, true);

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js').catch(() => {
    status.textContent = 'Офлайн хувилбарыг бэлтгэж чадсангүй. Сайтын зөвшөөрлийг шалгана уу.';
  });
}
