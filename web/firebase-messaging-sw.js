/* eslint-disable no-undef */
// Firebase Messaging Service Worker for Flutter Web
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCpGHhE-ir8S-DxNPWeQc5KU_vfGIVwigQ",
  authDomain: "harvestorr.firebaseapp.com",
  databaseURL: "https://harvestorr-default-rtdb.firebaseio.com",
  projectId: "harvestorr",
  storageBucket: "harvestorr.firebasestorage.app",
  messagingSenderId: "436902316402",
  appId: "1:436902316402:web:b02d1eff201c76298475eb",
});

const messaging = firebase.messaging();

// Optional: Customize notification appearance
messaging.onBackgroundMessage(function(payload) {
  const { title, body } = payload.notification || {};
  self.registration.showNotification(title || 'Harvester Alert', {
    body: body || 'New alert',
    icon: '/icons/Icon-192.png'
  });
});
