import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
// import 'security/generalregister.dart';
// import 'security/keyregister.dart';
// import 'security/materiallocal.dart';
// import 'security/materialregister.dart';
// import 'security/vehicleinout.dart';
// import 'security/visitorentry.dart';
import 'security/occurence.dart';

import 'staffs.dart';

String SECuserEmail;
String SECuserPhoto;
String SECuserName;
String place = "-----";
String start_datetime = "-----";
String end_datetime = "-----";

void _showDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "About Avantika HSM - v1.0",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20.0),
          ),
          content: new Text(
            "Avantika HSM is Housekeeping and Security Management System of Avantika University, Ujjain.\n\nDesigned & Developed by: Shivam Singh\n\n© 2019 Avantika University, Ujjain (MP) ",
            textAlign: TextAlign.left,
            style: TextStyle(
                //fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14.0),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

class SecurityPanel extends StatefulWidget {
  final UserDetails detailsUser;
  SecurityPanel({Key key, @required this.detailsUser}) : super(key: key);
  @override
  _SecurityPanelState createState() => _SecurityPanelState();
}

class _SecurityPanelState extends State<SecurityPanel> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification
    );
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
            title: new Text('HSM Notification'),
            content: new Text('$payload'),
          ),
    );
  }

  showShiftNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, 'New Duty/ Shift Assigned',
        '$place - From: $start_datetime, To: $end_datetime', platform,
        payload: 'New Shift Assigned: $place - From: $start_datetime, To: $end_datetime');
  }

  @override
  void getShifthistory() async {
    result = await http.post(
        "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
        body: {
          "showshiftdutyhistoryemail": SECuserEmail,
        });
    debugPrint(result.body);
    //new Timer.periodic(oneSec, (Timer t) => getShifthistory());

    Map checkshift = json.decode(result.body);
    // place = checkshift['place'];
    // start_datetime = checkshift['start_datetime'];
    // end_datetime = checkshift['end_datetime'];

    new Timer.periodic(
        oneSec,
        (Timer t) => setState(() {
              if(strcmp(place, checkshift['place']) == false || strcmp(start_datetime, checkshift['start_datetime']) == false || strcmp(end_datetime, checkshift['end_datetime']) == false){
                place = checkshift['place'];
                start_datetime = checkshift['start_datetime'];
                end_datetime = checkshift['end_datetime'];
                debugPrint(place + start_datetime + end_datetime);
                showShiftNotification();
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    getShifthistory();
    return new WillPopScope(
        onWillPop: () => null,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Avantika HSM"),
            leading: Builder(
              builder: (context) => IconButton(
                    icon: new Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
              // automaticallyImplyLeading: false,
              // actions: <Widget>[
              //   IconButton(
              //     icon: Icon(FontAwesomeIcons.signOutAlt,
              //         size: 20.0, color: Colors.white),
              //     onPressed: () {
              //       _gSignIn.signOut();
              //       print('SignedOut');
              //       Navigator.pop(context);
              //     },
              //   )
              // ],
            ),
          ),
          // body: new Card(
          //     margin: EdgeInsets.only(
          //         top: 80.0, bottom: 80.0, left: 20.0, right: 20.0),
          //     elevation: 2.0,
          //     child:InkWell(
          //       splashColor: Color(0XFF3d4449),
          //       onTap: (){},
          //     child:
          body: Padding(
              padding: EdgeInsets.only(left: 25.0, right: 20.0),
              child: new Center(
                  child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 70.0,
                  ),
                  SizedBox(
                    height: 250.0,
                    child: Image.network("$SERVER/images/app/shift_duty.png"),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 60.0,
                    child: new Text(
                      place,
                      style: TextStyle(
                          fontSize: 36.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                    child: new Text(
                      "From:  " + start_datetime,
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 10.0,
                    child: new Text(
                      "     To:  " + end_datetime,
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ],
              ))),
          drawer: Drawer(
            child: new ListView(
              children: <Widget>[
                new UserAccountsDrawerHeader(
                  accountName: new Text(SECuserName),
                  accountEmail: new Text(SECuserEmail),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new NetworkImage(
                          'https://backgrounddownload.com/wp-content/uploads/2018/09/background-android-lollipop-1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  currentAccountPicture:
                      CircleAvatar(backgroundImage: NetworkImage(SECuserPhoto)),
                ),
                new ListTile(
                    leading: Icon(Icons.person_pin),
                    title: new Text("Duty"),
                    onTap: () {
                      Navigator.pop(context);
                    }),
                new ListTile(
                    leading: Icon(Icons.assignment),
                    title: new Text("Register Entry"),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => MyTabs()));
                    }),
                // new ListTile(
                //     leading: Icon(Icons.search),
                //     title: new Text("Search Registers"),
                //     onTap: () {
                //       Navigator.pop(context);
                //     }),
                new ListTile(
                    leading: Icon(Icons.directions_bus),
                    title: new Text("Outing List"),
                    onTap: () {
                      Navigator.pop(context);
                    }),
                new ListTile(
                    leading: Icon(Icons.account_circle),
                    title: new Text("Staff Profiles"),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => Staffslist()));
                    }),
                // new ListTile(
                //     leading: Icon(Icons.chat),
                //     title: new Text("Messages"),
                //     onTap: () {}),
                new Divider(),
                new ListTile(
                    leading: Icon(Icons.share),
                    title: new Text("Share the app"),
                    onTap: () {
                      Share.share(
                          "Download Avantika HSM here: \n Https://servers.shivamsr.com/hsm/app/hsm.apk");
                      //Navigator.pop(context);
                    }),
                new ListTile(
                    leading: Icon(Icons.info),
                    title: new Text("App Info"),
                    onTap: () {
                      _showDialog(context);
                      //Navigator.pop(context);
                    }),
                new ListTile(
                    leading: Icon(Icons.power_settings_new),
                    title: new Text("Logout"),
                    onTap: () {
                      //_gSignIn.signOut();
                      debugPrint('SignedOut');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ));
  }
}

// class SecurityScreen extends StatelessWidget {
//   final UserDetails detailsUser;
//   SecurityScreen({Key key, @required this.detailsUser}) : super(key: key);

//   void refreshdata() {
//     const oneSec = const Duration(seconds: 1);
//     new Timer.periodic(oneSec, (Timer t) => print('hi!'));
//   }

//   @override
//   void getShifthistory() async {
//     result = await http.post(
//         "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
//         body: {
//           "showshiftdutyhistoryemail": SECuserEmail,
//         });
//     debugPrint(result.body);
//     //new Timer.periodic(oneSec, (Timer t) => getShifthistory());

//     Map checkshift = json.decode(result.body);
//     place = checkshift['place'];
//     start_datetime = checkshift['start_datetime'];
//     end_datetime = checkshift['end_datetime'];
//     debugPrint(place + start_datetime + end_datetime);

//     // new Timer.periodic(
//     //     oneSec,
//     //     (Timer t) => setState(() {
//     //           place = checkshift['place'];
//     //           start_datetime = checkshift['start_datetime'];
//     //           end_datetime = checkshift['end_datetime'];
//     //         }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final GoogleSignIn _gSignIn = GoogleSignIn();
//     SECuserEmail = detailsUser.userEmail;
//     SECuserName = detailsUser.userName;
//     SECuserPhoto = detailsUser.photoUrl;
//     getShifthistory();
//     return new WillPopScope(
//         onWillPop: () => null,
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text("Avantika HSM"),
//             leading: Builder(
//               builder: (context) => IconButton(
//                     icon: new Icon(Icons.menu),
//                     onPressed: () => Scaffold.of(context).openDrawer(),
//                   ),
//               // automaticallyImplyLeading: false,
//               // actions: <Widget>[
//               //   IconButton(
//               //     icon: Icon(FontAwesomeIcons.signOutAlt,
//               //         size: 20.0, color: Colors.white),
//               //     onPressed: () {
//               //       _gSignIn.signOut();
//               //       print('SignedOut');
//               //       Navigator.pop(context);
//               //     },
//               //   )
//               // ],
//             ),
//           ),
//           // body: new Card(
//           //     margin: EdgeInsets.only(
//           //         top: 80.0, bottom: 80.0, left: 20.0, right: 20.0),
//           //     elevation: 2.0,
//           //     child:InkWell(
//           //       splashColor: Color(0XFF3d4449),
//           //       onTap: (){},
//           //     child:
//           body: Padding(
//               padding: EdgeInsets.only(left: 25.0, right: 20.0),
//               child: new Center(
//                   child: Column(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 70.0,
//                   ),
//                   SizedBox(
//                     height: 250.0,
//                     child: Image.network("$SERVER/images/app/shift_duty.png"),
//                   ),
//                   SizedBox(
//                     height: 40.0,
//                   ),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   SizedBox(
//                     height: 60.0,
//                     child: new Text(
//                       place,
//                       style: TextStyle(
//                           fontSize: 36.0,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10.0,
//                     child: new Text(
//                       "From:  " + start_datetime,
//                       style: TextStyle(
//                           fontSize: 24.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   SizedBox(
//                     height: 10.0,
//                     child: new Text(
//                       "     To:  " + end_datetime,
//                       style: TextStyle(
//                           fontSize: 24.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey),
//                     ),
//                   ),
//                 ],
//               ))),
//           drawer: Drawer(
//             child: new ListView(
//               children: <Widget>[
//                 new UserAccountsDrawerHeader(
//                   accountName: new Text(SECuserName),
//                   accountEmail: new Text(SECuserEmail),
//                   decoration: new BoxDecoration(
//                     image: new DecorationImage(
//                       image: new NetworkImage(
//                           'https://backgrounddownload.com/wp-content/uploads/2018/09/background-android-lollipop-1.jpg'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   currentAccountPicture:
//                       CircleAvatar(backgroundImage: NetworkImage(SECuserPhoto)),
//                 ),
//                 new ListTile(
//                     leading: Icon(Icons.person_pin),
//                     title: new Text("Duty"),
//                     onTap: () {
//                       Navigator.pop(context);
//                     }),
//                 new ListTile(
//                     leading: Icon(Icons.assignment),
//                     title: new Text("Register Entry"),
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           new MaterialPageRoute(
//                               builder: (context) => MyTabs()));
//                     }),
//                 // new ListTile(
//                 //     leading: Icon(Icons.search),
//                 //     title: new Text("Search Registers"),
//                 //     onTap: () {
//                 //       Navigator.pop(context);
//                 //     }),
//                 new ListTile(
//                     leading: Icon(Icons.directions_bus),
//                     title: new Text("Outing List"),
//                     onTap: () {
//                       Navigator.pop(context);
//                     }),
//                 new ListTile(
//                     leading: Icon(Icons.account_circle),
//                     title: new Text("Staff Profiles"),
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           new MaterialPageRoute(
//                               builder: (context) => Staffslist()));
//                     }),
//                 new ListTile(
//                     leading: Icon(Icons.chat),
//                     title: new Text("Messages"),
//                     onTap: () {}),
//                 new Divider(),
//                 new ListTile(
//                     leading: Icon(Icons.share),
//                     title: new Text("Share the app"),
//                     onTap: () {
//                       Share.share(
//                           "Download Avantika HSM here: \n Https://servers.shivamsr.com/hsm/app/hsm.apk");
//                       //Navigator.pop(context);
//                     }),
//                 new ListTile(
//                     leading: Icon(Icons.info),
//                     title: new Text("App Info"),
//                     onTap: () {
//                       _showDialog(context);
//                       //Navigator.pop(context);
//                     }),
//                 new ListTile(
//                     leading: Icon(Icons.power_settings_new),
//                     title: new Text("Logout"),
//                     onTap: () {
//                       //_gSignIn.signOut();
//                       debugPrint('SignedOut');
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     }),
//               ],
//             ),
//           ),
//         ));
//   }
// }

class MyTabs extends StatefulWidget {
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 1);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Security Department Registers"),
            backgroundColor: Colors.red,
            bottom: new TabBar(
                isScrollable: true,
                controller: controller,
                tabs: <Tab>[
                  // new Tab(child: Text("General Entry")),
                  // new Tab(child: Text("Key Register")),
                  // new Tab(child: Text("Material - Local")),
                  // new Tab(child: Text("Material Register")),
                  new Tab(child: Text("Occurence/ Watchlist")),
                  // new Tab(child: Text("Vehicle In/Out")),
                  // new Tab(child: Text("Visitor Entry")),
                ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          // Generalregsiter(),
          // Keyregister(),
          // Materiallocal(),
          // Materialregister(),
          Occurrence(),
          // Vehicleinout(),
          // Visitorentry()
        ]));
  }
}
