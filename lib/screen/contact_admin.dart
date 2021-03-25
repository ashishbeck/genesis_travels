import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactAdminPage extends StatefulWidget {
  final bool isAdmin;

  ContactAdminPage({this.isAdmin = false});

  @override
  _ContactAdminPageState createState() => _ContactAdminPageState();
}

class _ContactAdminPageState extends State<ContactAdminPage> {
  List<Person> admins = [];

  @override
  void initState() {
    super.initState();
    admins.add(Person('Ajay Ekka', '+919178413337'));
    customFunctions.getAdmins().then((value) => setState(() => admins = value));
  }

  @override
  Widget build(BuildContext context) {
    print( admins.length);
    return Scaffold(
      appBar: AppBar(
        title: Text('Admins'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
            itemCount: admins.length,
            itemBuilder: (context, index){
              return ListTile(
                leading: Icon(Icons.contact_phone, color: appColor,),
                title: Text(admins[index].name ?? ""),
                trailing: Text(admins[index].number ?? ""),
                onTap: () async {
                  String url = 'tel:${admins[index].number}';
                  print(url);
                  if (await canLaunch(url)) {
                    launch(url);
                  }
                },
              );
        }),
      ),
    );
  }
}

class Person {
  final String name;
  final String number;

  Person(this.name, this.number);

}