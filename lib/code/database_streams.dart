import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genesis_travels/code/models.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;//..settings = Settings(host: '10.0.2.2:8080', sslEnabled: false);
class DatabaseService {
  final String uid;
  DatabaseService({this.uid});


  final CollectionReference usersCollection = _db.collection('users');
  final CollectionReference tasksCollection = _db.collection('tasks');

  UserModel _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
      uid: uid,
      displayName: snapshot.data()['displayName'] ?? "",
      phoneNumber: snapshot.data()['phoneNumber'] ?? "",
      lastSeen: snapshot.data()['lastSeen'].toDate() ?? DateTime.now(),
      myTasks: snapshot.data()['myTasks'] ?? [],
    );
  }

  Stream<UserModel> get userData {
    return usersCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

  List<Tasks> _activeTasksSnap(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Tasks(
        taskID: doc.data()['taskID'] ?? "",
        created: doc.data()['created'] ?? 0,
        customerName: doc.data()['customerName'] ?? "",
        customerNumber: doc.data()['customerNumber'] ?? "",
        driverName: doc.data()['driverName'] ?? "",
        driverNumber: doc.data()['driverNumber'] ?? "",
        fromDate: doc.data()['fromDate'] != null ? doc.data()['fromDate'].toDate() : DateTime.now(),
        toDate: doc.data()['toDate'] != null ? doc.data()['toDate'].toDate() : DateTime.now(),
        duration: doc.data()['duration'] ?? "",
        from: doc.data()['from']?? "",
        destination: doc.data()['destination'] ?? "",
        price: doc.data()['price'] ?? "",
        takenBy: doc.data()['takenBy'] ?? ""
      );
    }).toList();
  }

  Stream<List<Tasks>> get activeTasks {
    return tasksCollection.orderBy('created', descending: true).snapshots()
        .map(_activeTasksSnap);
  }

  List<MyTasks> _myTasksSnap(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return MyTasks(
          taskID: doc.data()['taskID'] ?? "",
          created: doc.data()['created'] ?? 0,
          customerName: doc.data()['customerName'] ?? "",
          customerNumber: doc.data()['customerNumber'] ?? "",
          fromDate: doc.data()['fromDate'] != null ? doc.data()['fromDate'].toDate() : DateTime.now(),
          toDate: doc.data()['toDate'] != null ? doc.data()['toDate'].toDate() : DateTime.now(),
          duration: doc.data()['duration'] ?? "",
          from: doc.data()['from']?? "",
          destination: doc.data()['destination'] ?? "",
          price: doc.data()['price'] ?? "",
      );
    }).toList();
  }

  Stream<List<MyTasks>> get myTasks {
    return usersCollection.doc(uid).collection('my_tasks').orderBy('created', descending: true).snapshots()
        .map(_myTasksSnap);
  }
}