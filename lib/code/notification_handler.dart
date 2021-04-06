import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genesis_travels/code/keys.dart';
import 'package:genesis_travels/screen/home.dart';
import 'package:http/http.dart' as http;
NotificationHandler notificationHandler = NotificationHandler();
class NotificationHandler {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  initNotifications() async {
    await performHandshake();
    initFlutterLocalNotifications();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('message while on foreground\n$message');
      showNotification(message);
    });
  }

  performHandshake() async {
    await messaging.getToken();
  }

  checkNotificationSubscription(String topic) async {
    String token = await messaging.getToken();
    print('token is $token');
    String key = fcmApiKey;
    String url = 'https://iid.googleapis.com/iid/info/$token?details=true';
    Map<String, String> headers = {'Authorization': 'key=$key'};
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    print('response from subscription check is ${response.body}');
    try {
      Map topics = jsonDecode(response.body)['rel']['topics'];
      if (topics.containsKey(topic)) {
        return true;
      }
      return false;
    } catch(e) {
      return false;
    }
  }

  subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
  }

  initFlutterLocalNotifications() async {
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onSelectNotification: (String payload) async {
        if (homeKey != null) {
          BuildContext context = homeKey.currentContext;
          Navigator.of(context).popUntil((route) => route.isFirst);
          // ignore: invalid_use_of_protected_member
          homeKey.currentState.setState(() {
            homeKey.currentState.tabController.index = 0;
            homeKey.currentState.scrollController.jumpTo(0);
          });
        }
        await flutterLocalNotificationsPlugin.cancelAll();
      }
    );
  }

  showNotification(RemoteMessage message) async {
    if (message.data != null) {
      Map data = message.data;
      ReceivedNotification notification = ReceivedNotification(data['id'], data['title'], data['body']);
      var activeNotifications = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          .getActiveNotifications() ?? [];
      String body = notification.body;
      String title = notification.title;
      try {
        if (activeNotifications.isNotEmpty) {
          String oldBody = activeNotifications.first.body;
          int length = oldBody
              .split("\n")
              .length;
          body += "\n" + oldBody;
          title += "s (${length + 1})";
        } else {
          body = notification.body;
        }
      } catch (e) {}
      print('body is $body');
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Task Channel ID', 'Task Channel', 'Individual Task Information',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        styleInformation: BigTextStyleInformation(body),);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(1, title, body, platformChannelSpecifics, payload: notification.id);
    }
  }
}

class ReceivedNotification {
  // final int created;
  final String id;
  final String title;
  final String body;

  ReceivedNotification(this.id, this.title, this.body);
}
