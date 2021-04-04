const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
process.env.TZ = "Asia/Kolkata";

exports.newTaskNotification = functions.firestore.document('tasks/{task}').onCreate((snapshot, context) => {
    const data = snapshot.data();
    let title = "New Task";
    let topic = "tasks";
	var registrationToken = 'dRcG8ASBSmaUP3Cx0cvCk2:APA91bHfJUuo5EcerHeN5QcJt4MKmolLGprmO5NckPtEbOFPJVgMc-G7f5TWR3Fui-rL-71D8bWpKqKeRqAcF7jl-OC-nkretzM5LOcqQ3vwh4BuO_vzmzCakvUYYffjQIaMgtlnZUQa';
    let from = data.from;
    let destination = data.destination;
	let fromDate = data.fromDate.toDate();
	let fromTZDate =  new Date(fromDate.getTime() + 330*60000);
    let fromDateString = fromTZDate.toDateString();
	let toDate = data.toDate.toDate();
	let toTZDate = new Date(toDate.getTime() + 330*60000);
    let toDateString = toTZDate.toDateString();
    let body = from + " (" + fromDateString + ") to " + destination + " (" + toDateString + ")";
    // let created = data.created.toString();
    let id = data.taskID;
    var message = {
        data: {
          title: title,
          body: body,
        //   created: created,
          id: id
        },
		// token: registrationToken
        topic: topic
    };
    admin.messaging().send(message)
        .then((response) => {
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
        })
        .catch((error) => {
            console.log('Error sending message:', error);
        });
    console.log(body);
})