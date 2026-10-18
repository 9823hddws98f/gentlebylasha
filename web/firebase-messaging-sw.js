// Shows Gentle push messages while the webapp is closed or in the background.
// The SDK version must match the Firebase JS SDK the Flutter plugins load
// (supportedFirebaseJsSdkVersion in firebase_core_web).
importScripts("https://www.gstatic.com/firebasejs/12.19.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.19.0/firebase-messaging-compat.js");

// Public web config, the same as lib/firebase_options.dart.
firebase.initializeApp({
  apiKey: "AIzaSyArdwqJWklzqJzHKNgcrIcRx9Herhs8Es8",
  appId: "1:65622286155:web:cf2c7cb81edc71f31e12ce",
  messagingSenderId: "65622286155",
  projectId: "sleeptales-4bac2",
  authDomain: "sleeptales-4bac2.firebaseapp.com",
  storageBucket: "sleeptales-4bac2.appspot.com",
});

// Messages with a notification payload are shown by the SDK itself.
firebase.messaging();
