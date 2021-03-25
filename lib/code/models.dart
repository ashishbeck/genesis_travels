class UserModel {
  final String uid;
  final String displayName;
  final String phoneNumber;
  final DateTime lastSeen;

  UserModel({this.uid, this.displayName, this.phoneNumber, this.lastSeen});
}

class Tasks {
  final String taskID;
  final int created;
  final String customerName;
  final String customerNumber;
  final String driverName;
  final String driverNumber;
  final DateTime fromDate;
  final DateTime toDate;
  final String duration;
  final String from;
  final String destination;
  final String price;
  final String takenBy;

  Tasks(
      {this.taskID,
        this.created,
        this.customerName,
        this.customerNumber,
        this.driverName,
        this.driverNumber,
        this.fromDate,
        this.toDate,
        this.duration,
        this.from,
        this.destination,
        this.price,
        this.takenBy
      });
}

class MyTasks {
  final String taskID;
  final int created;
  final String customerName;
  final String customerNumber;
  final DateTime fromDate;
  final DateTime toDate;
  final String duration;
  final String from;
  final String destination;
  final String price;

  MyTasks(
      {this.taskID,
        this.created,
        this.customerName,
        this.customerNumber,
        this.fromDate,
        this.toDate,
        this.duration,
        this.from,
        this.destination,
        this.price
      });
}
