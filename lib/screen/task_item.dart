import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/screen/new_task.dart';
import 'package:genesis_travels/screen/root_page.dart';

import 'home.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_functions.dart';
import 'package:genesis_travels/code/custom_widgets.dart';
import 'package:date_format/date_format.dart';
import 'package:genesis_travels/main.dart';
import 'package:genesis_travels/screen/contact_admin.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskItem extends StatelessWidget {
  final Tasks task;
  final User user;
  final bool isAdmin;
  TaskItem(this.task, this.user, {this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    TaskStatus status;
    Color statusColor;
    String statusText;
    if (task.takenBy == user?.uid) {
      status = TaskStatus.mine;
      statusText = 'Accepted';
      statusColor = Colors.blue;
    } else if (task.takenBy == '') {
      status = TaskStatus.available;
      statusText = 'Available';
      statusColor = Colors.green;
    } else {
      status = TaskStatus.unavailable;
      statusText = isAdmin ? 'Reserved' : 'Unavailable';
      statusColor = Colors.red;
    }

    Widget statusInfo() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(TextSpan(text: '', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16, color: Colors.black), children: [
          WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: CircleAvatar(
                backgroundColor: statusColor,
                radius: 10,
              )),
          TextSpan(text: ' Status: '),
          TextSpan(text: statusText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: statusColor))
        ])),
        Text.rich(TextSpan(
            text: 'Price: ',
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16, color: Colors.black),
            children: [TextSpan(text: '₹${task.price}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))]))
      ],
    );

    Widget journeyText(String text, DateTime time) => Column(
          children: [
            AutoSizeText(
              text, // + 'asd ads asd as da das as aa'
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
              minFontSize: 16,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              formatDate(time, [dd, '-', M, '-', yy]) + ' (${formatDate(time, [DD])})' + '\n' + formatDate(time, [hh, ':', nn, ' ', am]),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            )
          ],
        );

    Widget journeyInfo() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 3, child: journeyText(task.from, task.fromDate)),
            Expanded(
                flex: 1,
                child: Icon(
                  Icons.east,
                  size: 24,
                )),
            Expanded(flex: 3, child: journeyText(task.destination, task.toDate))
          ],
        );

    Widget customerInfo() => ListTile(
          title: Text(task.customerName),
          // trailing: Text(task.customerNumber),
          leading: Icon(
            Icons.phone,
            color: appColor,
          ),
          onTap: () async {
            String url = 'tel:${task.customerNumber}';
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
        );

    Widget driverInfo() => Container(
          padding: EdgeInsets.all(2),
          margin: EdgeInsets.all(2),
          decoration: ShapeDecoration(shape: taskShape, color: appColor.withOpacity(0.6)),
          child: Column(
            children: [
              Text(
                'DRIVER',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.underline,
                ),
              ),
              // Divider(
              //   color: appWhite,
              //   thickness: 2,
              //   indent: 60,
              //   endIndent: 60,
              // ),
              ListTile(
                title: Text(
                  task.driverName,
                  style: TextStyle(color: appWhite),
                ),
                // trailing: Text('Driver number', style: TextStyle(color: appWhite)),
                leading: Icon(
                  Icons.phone,
                  color: appWhite,
                ),
                onTap: () async {
                  String url = 'tel:${task.driverNumber}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
              )
            ],
          ),
        );

    Widget taskButton() => ElevatedButton(
              style: ButtonStyle(
                  // side: MaterialStateProperty.all(BorderSide(
                  //   color: status == TaskStatus.available ? Colors.green : appColor,
                  //   width: 2,
                  // )),
                  backgroundColor: MaterialStateProperty.all(
                    status == TaskStatus.available ? Colors.green : appColor,
                  ),
                  shape: MaterialStateProperty.all(roundShape)),
              onPressed: () {
                if (status == TaskStatus.available) {
                  AlertDialog dialog = new AlertDialog(
                    title: Text('Confirm Task'),
                    content: new Text("Are you sure you want to accept this task?"),
                    shape: taskShape,
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            if (user != null) {
                              try {
                                Navigator.pop(context);
                                await customFunctions.acceptTask(user, task.taskID);
                              } catch(e) {
                                print('e string is ${e.toString()}');
                                if(e.toString().contains('/permission-denied')) print('no perm');
                                // Navigator.pop(context);
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    title: Text('Some Error Occurred'),
                                    content: Text('Looks like someone has already taken this task'),
                                    shape: taskShape,
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text('Okay'))
                                    ],
                                  );
                                });
                              }
                            }
                          },
                          child: Text('Accept')),
                    ],
                  );
                  showDialog(context: context, builder: (context) => dialog);
                } else {
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => ContactAdminPage()));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  status == TaskStatus.available ? 'Accept' : 'Dispute with Admin',
                  style: TextStyle(fontSize: 16),
                ),
              ));

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      decoration: ShapeDecoration(
          shape: taskShape,
          color: appWhite,
          shadows: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: Offset(2, 2), spreadRadius: 1, blurRadius: 4)]),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            if (isAdmin) {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => NewTask(oldTask: task,)));
            }
          },
          child: Column(
            children: [
              statusInfo(),
              SizedBox(
                height: 4,
              ),
              journeyInfo(),
              (status == TaskStatus.mine || isAdmin) ? customerInfo() : status != TaskStatus.unavailable ? taskButton() : SizedBox.shrink(),
              (status != TaskStatus.available && isAdmin) ? driverInfo() : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
