const functions = require('firebase-functions');
// const admin = require('frebase-admin/lib/database');
const admin = require('firebase-admin');

admin.initializeApp();

exports.helloWorld = functions.https.onRequest((request, response) => {
  // functions.logger.info("Hello logs!", {structuredData: true});
  response.send({data: "Hello from Firebase!"});
});

exports.addCount = functions.https.onCall((data, context) => {
  var count = parseInt(data["count"], 10);
  return ++count;
});

exports.removeCount = functions.https.onCall((data,context) =>{
  var count = data['count'];
  return --count;
});

exports.sendFCM = functions.https.onCall((data, context) => {
  var token = data["token"];
  var title = data["title"];
  var body = data["body"];

  var payload = {
    notification: {
      title: title,
      body: body
    }
  }

  var result = admin.messaging().sendToDevice(token, payload);
  return result;
})