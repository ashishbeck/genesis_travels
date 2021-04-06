import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_travels/code/auth.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/database_streams.dart';
import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/code/notification_handler.dart';
import 'package:genesis_travels/screen/root_page.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/transformers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  GestureBinding.instance.resamplingEnabled = true;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  notificationHandler.initNotifications();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  runApp(MyApp());
}

Future backgroundHandler (RemoteMessage message) async {
  print('message while on background\n$message');
  NotificationHandler().showNotification(message);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          initialData: null,
          value: authService.user,
          catchError: (ctx, e) {
            print('error from user provider');
            throw(e);
          },
        ),
        StreamProvider<UserModel>.value(
          initialData: null,
          value: AuthService().user.transform(FlatMapStreamTransformer<User, UserModel>(
            (user) => DatabaseService(uid: user.uid).userData,
          )),
          catchError: (ctx, e) {
            print('error from userModel provider');
            throw(e);
          },
        ),
        StreamProvider<List<Tasks>>.value(
          initialData: null,
          value: DatabaseService().activeTasks,
          catchError: (e,a){
            print('error from tasks provider');
            throw(a);
          },
        ),
        // StreamProvider<List<MyTasks>>.value(
        //     initialData: null,
        //     value: authService.user.transform(FlatMapStreamTransformer<User, List<MyTasks>>(
        //       (user) => DatabaseService(uid: user.uid).myTasks,
        //     )),
        //   catchError: (ctx, e) {
        //     print('error from myTasks provider');
        //     throw(e);
        //   },),
      ],
      child: MaterialApp(
        title: 'Genesis Travels',
        theme: ThemeData(primaryColor: appColor, primarySwatch: Colors.red
            // appBarTheme: AppBarTheme(color: Colors.transparent, elevation: 0)
            // primaryColorBrightness: Brightness.light,
            // scaffoldBackgroundColor: appWhite
            ),
        home: RootPage(),
      ),
    );
  }
}
