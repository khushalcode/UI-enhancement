importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDWsvYgd6hSfmOzMCqX--Tqu_8dvV7YcX4",
  authDomain: "deokart-da98d.firebaseapp.com",
  databaseURL: "https://deokart-da98d-default-rtdb.firebaseio.com",
  projectId: "deokart-da98d",
  storageBucket: "deokart-da98d.firebasestorage.app",
  messagingSenderId: "796750725283",
  appId: "1:796750725283:web:b4efcdfd12fb10d6917f16",
  measurementId: "G-NF37EMQVL2"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});