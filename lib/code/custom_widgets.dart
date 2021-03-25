import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_functions.dart';
import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/screen/contact_admin.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Disposer = void Function();

Widget customLoadingModule(String text) {
  return Center(
    child: Container(
      margin: EdgeInsets.only(top: 16),
      child: Chip(
        avatar: CircularProgressIndicator(),
        label: Text(
          text,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: appWhite,
      ),
    ),
  );
}

Widget customDivider(double width) {
  return Center(
    child: Container(
      height: 5,
      width: width,
      decoration: ShapeDecoration(shape: roundShape, color: appGrey),
    ),
  );
}

Widget customLoadingScreen(String text) {
  return Container(
    color: appWhite,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SpinKitCubeGrid(
            color: appColor,
            size: 50.0,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: appColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    ),
  );
}

Widget taskItem(dynamic task, User user, {bool isAdmin = false}) {
  // print('building?');
  // isAdmin = false;
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

  Widget taskButton() => Builder(builder: (context) {
        return OutlinedButton(
            style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(
              color: appColor,
              width: 2,
            ))),
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
                            Navigator.pop(context);
                            await customFunctions.acceptTask(user, task.taskID);
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
                status == TaskStatus.available ? 'Accept Task' : 'Dispute with Admin',
                style: TextStyle(fontSize: 16),
              ),
            ));
      });

  return Container(
    padding: EdgeInsets.all(8),
    margin: EdgeInsets.all(8),
    decoration: ShapeDecoration(
        shape: taskShape,
        color: appWhite,
        shadows: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: Offset(2, 2), spreadRadius: 1, blurRadius: 4)]),
    child: Column(
      children: [
        Row(
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
        ),
        SizedBox(
          height: 4,
        ),
        journeyInfo(),
        (status == TaskStatus.mine || isAdmin) ? customerInfo() : taskButton(),
        (status != TaskStatus.available && isAdmin) ? driverInfo() : SizedBox.shrink()
      ],
    ),
  );
}

class CustomStatefulBuilder extends StatefulWidget {
  const CustomStatefulBuilder({
    Key key,
    @required this.builder,
    @required this.dispose,
  })  : assert(builder != null),
        super(key: key);

  final StatefulWidgetBuilder builder;
  final Disposer dispose;

  @override
  _CustomStatefulBuilderState createState() => _CustomStatefulBuilderState();
}

class _CustomStatefulBuilderState extends State<CustomStatefulBuilder> {
  @override
  Widget build(BuildContext context) => widget.builder(context, setState);

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
  }
}

enum TaskStatus { available, unavailable, mine }
