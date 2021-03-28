import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genesis_travels/code/auth.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_widgets.dart';
import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/screen/contact_admin.dart';
import 'package:uuid/uuid.dart';

CustomFunctions customFunctions = CustomFunctions();

class CustomFunctions {

  final FirebaseFirestore _db = FirebaseFirestore.instance;//..settings = Settings(host: '10.0.2.2:8080', sslEnabled: false);

  Future enterDisplayName(BuildContext context, User user) async {
    // await Future.delayed(Duration(milliseconds: 200));
    TextEditingController controller = new TextEditingController();

    onSubmit() async {
      if (controller.text.isNotEmpty) {
        await authService.updateUserData(user, controller.text);
        Navigator.pop(context);
      }
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        enableDrag: false,
        shape: bottomSheetShape,
        builder: (context) {
          return SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(bottom: 8)),
                Text(
                  'Please enter your full name to continue',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(bottom: 8)),
                TextField(
                  controller: controller,
                  decoration: textFieldDecoration.copyWith(
                    labelText: 'Full Name',
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (value) {
                    onSubmit();
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  width: double.maxFinite,
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(appColor),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                      onPressed: onSubmit,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: appWhite, fontSize: 18),
                          ))),
                )
              ],
            ),
          ));
        });
  }

  Future<List<Person>> getAdmins() async {
    List<Person> admins = [];
    final snapshot = await _db.collection('admins').get();
    snapshot.docs.forEach((element) {
      admins.add(Person(element.data()['name'], element.data()['number']));
    });
    return admins;
  }

  Future acceptTask(User user, String taskID) async {
    DocumentReference ref = _db.doc('tasks/$taskID');
    await ref.update({
      'takenBy': user.uid,
      'driverNumber': user.phoneNumber,
      'driverName': user.displayName,
    },).then((value) {
      print('saving ot myTasks');
      _db.doc('users/${user.uid}').update({
        'myTasks': FieldValue.arrayUnion([taskID])
      });
    });
  }

  Future submitTask(Tasks newTask) async {
    var uuid = Uuid();
    String taskID = uuid.v4();
    DocumentReference ref = _db.collection('tasks').doc(taskID);
    await ref.set({
      'taskID': taskID,
      'created': newTask.created,
      'customerName': newTask.customerName,
      'customerNumber': newTask.customerNumber,
      'price': newTask.price,
      'from': newTask.from,
      'destination': newTask.destination,
      'fromDate': newTask.fromDate,
      'toDate': newTask.toDate
    },);
    return;
  }
}
