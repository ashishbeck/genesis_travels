import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genesis_travels/code/auth.dart';
import 'package:genesis_travels/screen/home.dart';
import 'package:genesis_travels/screen/login.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder(
        stream: null, //authService.user
        builder: (context, snapshot) {
          print('root page');
          print(user.uid);
          // if (user == null) {
          //   return LoginPage();
          // }
          return HomePage();
          if (snapshot != null) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return HomePage();
            } else {
              return LoginPage();
            }
          }
          return Container();
        });
  }
}
