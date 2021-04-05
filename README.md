# Genesis Travels

Flutter app for the drivers and admins of a local travel agency to manage new tasks. This app lets the admins to post new task of clients and allows the drivers to accept them. Once accepted, only the driver who accepted can see the client's name and phone number to coordinate the task. Other drivers will see the task as **unavailable**.


The drivers are notified of new tasks via Firebase Cloud Messaging service that they can choose to opt out by unsubscribing to the topic for task notifications, if they are not available to accept tasks. A nodejs function running in Cloud Functions is triggered whenever a new task is posted and delivers the notifications to all the devices that have subscribed to the tasks topic. The drivers can also see the tasks that they have accepted in the past.

## Configuration
If you wish to use this app for your own personal project then integrate Firebase to your project first using the [official guide](https://firebase.google.com/docs/flutter/setup?platform=android).


This app is intended for Android users only but you can implement support for iOS users as well.
Don't forget to import the `google-services.json` file into your project according to the guide. Create a new file called `keys.dart` in the `lib/code` directory and add this line into it
```
String fcmApiKey = "your_api_key";
```
Go to your firebase project console and enter project settings. Select the `Cloud Messaging` tab and copy the server key and replace `your_api_key` with it. This is needed to check if the driver has subscribed to the task topic to receive notifications and update the UI accordingly.

Implement Cloud Functions in your project by following the guide [here](https://firebase.google.com/docs/functions/get-started). The necessary function is included in the repo so you should simply deploy it to get it up and running.

You should then set the following security rule for your Firestore to allow admin roles implementation-
<details>
  <summary>Firestore Rules Configuration</summary>
  
  ```rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      function isAdmin() {
        return exists(path("/databases/" + database + "/documents/admins/" + request.auth.token.phone_number.replace('\\+', '')));
      }
      match /admins/{admin} {
        allow read: if request.auth.uid != null;
        allow write: if isAdmin();
      }
      match /updates/{u} {
        allow read: if request.auth.uid != null;
        allow write: if isAdmin();
      }
      match /users/{user} {
        allow read: if request.auth.uid == user || isAdmin();
        allow write: if request.auth.uid == user;
      }
      match /tasks/{task=**} {
        allow read: if request.auth.uid != null;
        allow create: if isAdmin();
        allow delete: if isAdmin();
        allow update: if (request.auth.uid != null && !('takenBy' in resource.data)) || isAdmin();
      }
    }
  }
  ```
</details>

And then create a new collection in Firestore named `admins` and add documents for each admin that have a document ID of their phone number without '+' but with country code and add fields: `name` and `number` with full phone numbers including '+'. It should then look like this-
![firestore](https://firebasestorage.googleapis.com/v0/b/genesis-travels.appspot.com/o/firestore.jpg?alt=media&token=f3f9979c-35c6-46cd-8bc1-a3b0c604c1a0)
Then open the `constants.dart` file in `lib/code` and edit the value of `countryCode` with the country code of your choice.


While it is not necessary but you can force the users to update the app incase you find a security flaw in the current version by including the following document in your `updates` collection-
![updates](https://firebasestorage.googleapis.com/v0/b/genesis-travels.appspot.com/o/updates.jpg?alt=media&token=3c538a79-1f44-4658-9b02-a2e16f9bc784)
