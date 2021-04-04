# Genesis Travels

App for the drivers and admins of a local travel agency to manage new tasks. This app lets the admins to post new task of clients and allows the drivers to accept them. Once accepted, only the driver who accepted can see the client's name and phone number to coordinate the task. Other drivers will see the task as **unavailable**.


The drivers are notified of new tasks via Firebase Cloud Messaging service that they can choose to opt out by unsubscribing to the topic for task notifications, if they are not available to accept tasks. A nodejs function running in Cloud Functions is triggered whenever a new task is posted and delivers the notifications to all the devices that have subscribed to the tasks topic. The drivers can also see the tasks that they have accepted in the past.
