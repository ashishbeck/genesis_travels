import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genesis_travels/code/auth.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_functions.dart';
import 'package:genesis_travels/code/custom_widgets.dart';
import 'package:genesis_travels/code/models.dart';
import 'package:genesis_travels/screen/contact_admin.dart';
import 'package:genesis_travels/screen/new_task.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool checkingUser = false;
  bool isAdmin;
  TabController tabController;
  List<Widget> tabsList = [];
  List<Widget> tabViewsList = [];
  List<Tasks> allTasks = [];
  List<Tasks> activeTasks = [];
  List<Tasks> oldTasks = [];
  List<MyTasks> myTasks = [];
  Timer periodicTimer;
  final _streamController = BehaviorSubject();

  periodicTimerInit() => periodicTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _streamController.add(timer.tick);
        return;
      });

  // Future checkUser(User user) async {
  //
  // }

  @override
  void initState() {
    super.initState();
    periodicTimerInit();
    tabController = new TabController(length: 2, vsync: this);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // });
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
    // final userModel = Provider.of<UserModel>(context);
    print('building user ${user.phoneNumber}');
    if (user != null && !checkingUser) {
      // print('user uid is ${user.uid} and ${user.phoneNumber} and meta data is ${user.providerData}');
      checkingUser = true;
      authService.getUserData(user).then((value) async {
        if (value == null) await customFunctions.enterDisplayName(context, user);
        isAdmin = await authService.checkIfAdmin(user.phoneNumber);
        print('admin mode is $isAdmin');
        setState(() {

        });
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
                fit: BoxFit.contain,),
            ),
            user != null ? ListTile(
              title: Text(user.displayName ?? ""),
              subtitle: Text(user.phoneNumber),
            ) : SizedBox.shrink(),
            Divider(
              thickness: 2,
            ),
            drawerItem(Icons.phone, 'Contact Admin', onTap: () =>
                Navigator.push(context, new MaterialPageRoute(builder: (context) => ContactAdminPage(isAdmin: isAdmin,)))),
            drawerItem(Icons.power_settings_new, 'Logout', onTap: (){
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
              applicationIcon: Image.asset('assets/icon.png', width: 50, height: 50,),
              applicationLegalese: 'Copyright Genesis Travels',
              applicationName: 'Genesis Travels',
              applicationVersion: '1.0.0',
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
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return taskItem(task, user, isAdmin: isAdmin);
            // return ListTile(
            //   title: Text('${task.from} to ${task.destination}'),
            //   subtitle: Text('${task.customerNumber} - ${task.customerName}'),
            // );
          });
    }

    Widget buildBody() {
      if (isAdmin == null) return customLoadingScreen('Initializing..');
      allTasks = Provider.of<List<Tasks>>(context) ?? [];
      return StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (isAdmin) {
              DateTime now = DateTime.now();
              if (allTasks.isNotEmpty) {
                activeTasks = allTasks.where((element) => element.fromDate.millisecondsSinceEpoch > now.millisecondsSinceEpoch).toList() ?? [];
                oldTasks = allTasks.where((element) => element.fromDate.millisecondsSinceEpoch < now.millisecondsSinceEpoch).toList() ?? [];
              }
              tabsList = [tab('Active Tasks'), tab('Old Tasks')];
              tabViewsList = [tabView(activeTasks), tabView(oldTasks)];
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
            } else if (!isAdmin) {
              DateTime now = DateTime.now();
              if (allTasks.isNotEmpty) {
                activeTasks = allTasks.where((element) => (element.fromDate.millisecondsSinceEpoch > now.millisecondsSinceEpoch)).toList() ??
                    [];
              }
              myTasks = Provider.of<List<MyTasks>>(context) ?? [];
              tabsList = [tab('Active Tasks'), tab('My Tasks')];
              tabViewsList = [tabView(activeTasks), tabView(myTasks)];
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
            }
            return customLoadingScreen('Initializing..');
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Genesis Travels'),
        centerTitle: true,
        // shape: appBarShape,
      ),
      drawer: Drawer(
        child: drawer(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, new MaterialPageRoute(builder: (context) => NewTask()));
        },
      ),
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
