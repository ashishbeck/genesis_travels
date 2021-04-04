import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genesis_travels/code/auth.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_functions.dart';
import 'package:genesis_travels/code/custom_widgets.dart';
import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/code/notification_handler.dart';
import 'package:genesis_travels/screen/contact_admin.dart';
import 'package:genesis_travels/screen/new_task.dart';
import 'package:genesis_travels/screen/task_item.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:url_launcher/url_launcher.dart';

final homeKey = new GlobalKey<_HomePageState>();

class HomePage extends StatefulWidget {
  HomePage({Key homekey}) : super(key: homeKey);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool checkingUser = false;
  bool isAdmin;
  bool isAvailable = true;
  TabController tabController;
  ScrollController scrollController = ScrollController();
  List<Widget> tabsList = [];
  List<Widget> tabViewsList = [];
  List<Tasks> allTasks = [];
  List<Tasks> activeTasks = [];
  List<Tasks> oldTasks = [];
  List<Tasks> myTasks = [];
  Timer periodicTimer;
  final _streamController = BehaviorSubject();
  String appName = "";
  String version = "";

  periodicTimerInit() => periodicTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _streamController.add(timer.tick);
        return;
      });

  Widget snackBar(String text) => SnackBar(
        content: Text(text),
      );

  Future getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    version = packageInfo.version;
  }

  Future updateCheck(BuildContext context) async {
    String url = await customFunctions.checkForUpdates();
    if (url != null) {
      Widget dialog = WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text('Update Required'),
          content: Text('Please update the app to continue using by clicking the button below'),
          // content: Text('Please update the app to continue. Ask Ajay or any other admin to get the latest version of the app'),
          actions: [
            TextButton(
                onPressed: () async {
                  // updateProgress(context, url);
                    launch(url);
                },
                child: Text('UPDATE'))
          ],
        ),
      );
      showDialog(barrierDismissible: false, context: context, builder: (context) => dialog);
    }
  }

  // Future updateProgress(BuildContext context, String url) async {
  //   if (url != null) {
  //     Widget dialog = WillPopScope(
  //       onWillPop: () async => false,
  //       child: StreamBuilder<FileResponse>(
  //         stream: DefaultCacheManager().getFileStream(url, withProgress: true),
  //         builder: (context, snapshot) {
  //           DownloadProgress progress;
  //           if (snapshot.data is DownloadProgress) {
  //             progress = snapshot.data;
  //             return AlertDialog(
  //               // title: Text('Downloading'),
  //               content: Row(
  //                 children: [
  //                   CircularProgressIndicator(value: progress.progress,),
  //                   Padding(padding: EdgeInsets.all(8)),
  //                   Text('Downloading. Please wait..'),
  //                 ],
  //               ),
  //             );
  //           } else if (snapshot.data != null) {
  //             FileInfo file = snapshot.data;
  //             return AlertDialog(
  //               title: Text('Download Completed'),
  //               content: Text('Press INSTALL and allow permission to install to continue'),
  //               actions: [
  //                 TextButton(
  //                   child: Text('INSTALL'),
  //                   onPressed: () async {
  //                     print(file.file.path);
  //                     AppInstaller.installApk('/data/user/0/com.genesis.travels/cache/libCachedImageData/d578b160-94aa-11eb-93c9-9fba9978cff5.apk');
  //                   }
  //                 )
  //               ],
  //             );
  //           }
  //           return AlertDialog(
  //             // title: Text('Downloading'),
  //             content: Row(
  //               children: [
  //                 CircularProgressIndicator(),
  //                 Padding(padding: EdgeInsets.all(8)),
  //                 Text('Downloading. Please wait..'),
  //               ],
  //             ),
  //           );
  //         }
  //       ),
  //     );
  //     showDialog(barrierDismissible: false, context: context, builder: (context) => dialog);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    periodicTimerInit();
    tabController = new TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPackageInfo();
      updateCheck(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
    _streamController.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    print('building?');
    final user = Provider.of<User>(context);
    final userModel = Provider.of<UserModel>(context);
    if (user != null && !checkingUser) {
      // print('user uid is ${user.uid} and ${user.phoneNumber} and meta data is ${user.providerData}');
      checkingUser = true;
      authService.getUserData(user).then((value) async {
        if (value == null) await customFunctions.enterDisplayName(context, user);
        isAdmin = await authService.checkIfAdmin(user.phoneNumber);
        // isAdmin = false;
        print('admin mode is $isAdmin');
        setState(() {});
      });
      NotificationHandler().checkNotificationSubscription('tasks').then((value) {
        setState(() => isAvailable = value);
      });
    }

    Widget drawerItem(IconData icon, String title, {Function onTap}) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      );
    }

    Widget drawer() {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/logo_travels.png',
                fit: BoxFit.contain,
              ),
            ),
            user != null
                ? ListTile(
                    title: Text(userModel?.displayName ?? ""),
                    subtitle: Text(userModel?.phoneNumber ?? ""),
                  )
                : SizedBox.shrink(),
            Divider(
              thickness: 2,
            ),
            drawerItem(Icons.phone, 'Contact Admin', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => ContactAdminPage(
                            isAdmin: isAdmin,
                          )));
            }),
            drawerItem(Icons.power_settings_new, 'Logout', onTap: () {
              AlertDialog dialog = new AlertDialog(
                content: new Text("Are you sure you want to log out?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        authService.signOut();
                      },
                      child: Text('Log out')),
                ],
              );
              showDialog(context: context, builder: (context) => dialog);
            }),
            Spacer(),
            AboutListTile(
              icon: Icon(Icons.info),
              applicationIcon: Image.asset(
                'assets/icon.png',
                width: 50,
                height: 50,
              ),
              applicationLegalese: 'Copyright © Genesis Travels',
              applicationName: appName,
              applicationVersion: version,
              child: Text('About'),
            )
          ],
        ),
      );
    }

    Widget tab(String title) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Text(title),
      );
    }

    Widget tabView(List tasks) {
      if (tasks.isEmpty) {
        return Center(
          child: Text(
            'No tasks found',
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 24, color: appColor),
          ),
        );
      }
      return ListView.builder(
          controller: scrollController,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItem(task, user, isAdmin: isAdmin);
            // return ListTile(
            //   title: Text('${task.from} to ${task.destination}'),
            //   subtitle: Text('${task.customerNumber} - ${task.customerName}'),
            // );
          });
    }

    Widget buildFAB() {
      return isAdmin
          ? FloatingActionButton(
              backgroundColor: appColor,
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, new MaterialPageRoute(builder: (context) => NewTask()));
              },
            )
          : FloatingActionButton.extended(
              label: Text(isAvailable ? 'Available' : 'Unavailable'),
              icon: Icon(isAvailable ? Icons.check_circle : Icons.cancel),
              backgroundColor: isAvailable ? appColor : Colors.black,
              onPressed: () async {
                if (isAvailable) {
                  setState(() => isAvailable = false);
                  NotificationHandler().unsubscribeFromTopic('tasks');
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar('DISABLED notifications for new tasks'));
                } else {
                  setState(() => isAvailable = true);
                  NotificationHandler().subscribeToTopic('tasks');
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar('ENABLED notifications for new tasks'));
                }
              },
            );
    }

    Widget buildBody() {
      if (isAdmin == null) return customLoadingScreen('Initializing..');
      DateTime now = DateTime.now();
      allTasks = Provider.of<List<Tasks>>(context) ?? [];
      if (allTasks.isNotEmpty) {
        activeTasks = allTasks.where((element) => (element.fromDate.millisecondsSinceEpoch > now.millisecondsSinceEpoch)).toList() ?? [];
      }
      if (isAdmin) {
        if (allTasks.isNotEmpty) {
          oldTasks = allTasks.where((element) => element.fromDate.millisecondsSinceEpoch < now.millisecondsSinceEpoch).toList() ?? [];
        }
        tabsList = [tab('Active Tasks'), tab('Old Tasks')];
        tabViewsList = [tabView(activeTasks), tabView(oldTasks)];
      } else {
        if (userModel != null) {
          myTasks = allTasks.where((element) => userModel.myTasks.contains(element.taskID)).toList();
        }
        tabsList = [tab('Active Tasks'), tab('My Tasks')];
        tabViewsList = [tabView(activeTasks), tabView(myTasks)];
      }
      return StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            return Column(
              children: [
                TabBar(
                    controller: tabController,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: appColor,
                    labelColor: appColor,
                    tabs: tabsList),
                Expanded(child: TabBarView(controller: tabController, children: tabViewsList))
              ],
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Genesis Travels'),
        centerTitle: true,
        // shape: appBarShape,
        actions: [
          kDebugMode
              ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Tasks newTask = Tasks(
                        created: DateTime.now().millisecondsSinceEpoch,
                        customerName: 'customerName',
                        customerNumber: 'customerNumber',
                        price: 'price',
                        from: 'from',
                        fromDate: DateTime(2022),
                        destination: 'destination',
                        toDate: DateTime(2023));
                    customFunctions.submitTask(newTask, null);
                  })
              : SizedBox.shrink()
        ],
      ),
      drawer: Drawer(
        child: drawer(),
      ),
      floatingActionButton: isAdmin != null ? buildFAB() : SizedBox.shrink(), //![null, false].contains(isAdmin)
      body: buildBody(),
      // body: SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       Text('Welcome to the app home page'),
      //       ElevatedButton(
      //           onPressed: () {
      //             authService.signOut();
      //           },
      //           child: Text('Log Out'))
      //     ],
      //   ),
      // ),
    );
  }
}
