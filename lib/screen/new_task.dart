import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_functions.dart';
import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/screen/task_item.dart';

class NewTask extends StatefulWidget {
  final Tasks oldTask;
  NewTask({this.oldTask});
  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _formKey = GlobalKey<FormState>();
  String customerName;
  String customerNumber;
  String from;
  String destination;
  DateTimeRange dateTimeRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  DateTime fromDate;
  DateTime toDate;
  // String toDate;
  String price;
  Tasks oldTask;

  @override
  void initState() {
    super.initState();
    oldTask = widget.oldTask;
    if (oldTask != null) {
      customerName = oldTask.customerName;
      customerNumber = oldTask.customerNumber;
      from = oldTask.from;
      destination = oldTask.destination;
      fromDate = oldTask.fromDate;
      toDate = oldTask.toDate;
      price = oldTask.price;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(fromDate);
    print(toDate);

    Widget dateTimePicker(DateTime dateTime, String replacement) => OutlinedButton(
        style: ButtonStyle(
            side: MaterialStateProperty.all(BorderSide(
              color: appColor,
              width: 2,
            )),
            shape: MaterialStateProperty.all(roundShape)),
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          showDatePicker(
            context: context,
            initialDate: fromDate ?? DateTime.now(),
            firstDate: fromDate ?? DateTime.now(),
            lastDate: DateTime(2100),
          ).then((dateValue) {
            if (dateValue != null)
              showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget child) {
                  final Widget mediaQueryWrapper = MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      alwaysUse24HourFormat: false,
                    ),
                    child: child,
                  );
                  return Localizations.override(
                    context: context,
                    locale: Locale('en', 'US'),
                    child: mediaQueryWrapper,
                  );
                },
              ).then((timeValue) {
                if (timeValue != null) {
                  setState(() {
                    if (replacement.contains('From')) {
                      fromDate = dateValue.add(Duration(hours: timeValue.hour, minutes: timeValue.minute));
                    } else {
                      toDate = dateValue.add(Duration(hours: timeValue.hour, minutes: timeValue.minute));
                    }
                  });
                }
              });
          });
        },
        child: AutoSizeText(
          dateTime != null ? formatDate(dateTime, [dd, '-', M, '-', yy, ' ', hh, ':', nn, ' ', am]) : replacement,
          maxLines: 1,
          minFontSize: 5,
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text(oldTask != null ? 'Edit Task' : 'New Task'),
        centerTitle: true,
        actions: oldTask != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: 'Delete Task',
                  onPressed: () async {
                    Widget dialog = AlertDialog(
                      title: Text('Delete Task'),
                      content: Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text('No')),
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await customFunctions.deleteTask(oldTask.taskID);
                              Navigator.pop(context);
                            },
                            child: Text('Yes')),
                      ],
                    );
                    showDialog(context: context, builder: (context) => dialog);
                  },
                )
              ]
            : [],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextFormField(
                  initialValue: customerName,
                  decoration: textFieldDecoration.copyWith(labelText: 'Customer Name'),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (val) => customerName = val,
                  validator: (val) => val.isEmpty ? 'Please enter the customer name' : null,
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: customerNumber?.substring(3),
                        decoration: textFieldDecoration.copyWith(labelText: 'Customer Number', prefixText: '$countryCode '),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 10,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.next,
                        onChanged: (val) => customerNumber = '$countryCode ' + val,
                        validator: (val) => val.length != 10 ? 'Customer number is incorrect' : null,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: price,
                        decoration: textFieldDecoration.copyWith(labelText: 'Price', prefixText: '??? '),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                        onChanged: (val) => price = val,
                        validator: (val) => val.isEmpty ? 'Please enter the  price' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  initialValue: from,
                  decoration: textFieldDecoration.copyWith(labelText: 'From Location'),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (val) => from = val,
                  validator: (val) => val.isEmpty ? 'Please enter the starting location' : null,
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  initialValue: destination,
                  decoration: textFieldDecoration.copyWith(labelText: 'Destination'),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onChanged: (val) => destination = val,
                  validator: (val) => val.isEmpty ? 'Please enter the destination' : null,
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(child: dateTimePicker(fromDate, 'From')),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: dateTimePicker(toDate, 'To'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  style: ButtonStyle(shape: MaterialStateProperty.all(roundShape)),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Submit'),
                  ),
                  onPressed: () {
                    AlertDialog dialog = new AlertDialog(
                      title: Text('Review Submission'),
                      content: new Text("Are you sure you want to submit this task?"),
                      shape: taskShape,
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel')),
                        TextButton(
                            onPressed: () async {
                              Tasks newTask = Tasks(
                                  created: DateTime.now().millisecondsSinceEpoch,
                                  customerName: customerName,
                                  customerNumber: customerNumber,
                                  price: price,
                                  from: from,
                                  fromDate: fromDate,
                                  destination: destination,
                                  toDate: toDate);
                              await customFunctions.submitTask(newTask, oldTask != null ? oldTask.taskID : null);
                              // print(oldTask.taskID);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Submit')),
                      ],
                    );
                    if (_formKey.currentState.validate() && fromDate != null && toDate != null) {
                      showDialog(context: context, builder: (context) => dialog);
                    } else if (fromDate == null || toDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please enter dates'),
                      ));
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
