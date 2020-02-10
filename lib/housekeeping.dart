import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:share/share.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
import 'staffs.dart';
import 'housekeeping/housekeepingregister.dart';

String HKuserEmail;
String HKuserPhoto;
String HKuserName;
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

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(HKuserName),
            accountEmail: new Text(HKuserEmail),
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new NetworkImage(
                    'https://backgrounddownload.com/wp-content/uploads/2018/09/background-android-lollipop-1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            currentAccountPicture:
                CircleAvatar(backgroundImage: NetworkImage(HKuserPhoto)),
          ),
          new ListTile(
              leading: Icon(Icons.person_pin),
              title: new Text("Duty"),
              onTap: () {
                Navigator.pop(context);
              }),
          new ListTile(
              leading: Icon(Icons.add_circle),
              title: new Text("Housekeeping Register"),
              onTap: () {
                if (strcmp(place, "Aavaas 01") == true ||
                    strcmp(place, "Aavaas 02") == true) {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                              HousekeepingRegister())); //ServerSign()));
                } else {
                  Fluttertoast.showToast(
                      msg:
                          'No Housekeeping Register available for $place, Try again later',
                      gravity: ToastGravity.BOTTOM,
                      //backgroundColor: Colors.red,
                      timeInSecForIos: 2);
                }
              }),
          new ListTile(
              leading: Icon(Icons.add_to_home_screen),
              title: new Text("HSM requests"),
              onTap: () {
                hsmPendingStatus(context);
              }),
          new ListTile(
              leading: Icon(Icons.account_circle),
              title: new Text("Staff Profiles"),
              onTap: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => Staffslist()));
              }),
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
                Navigator.pop(context);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}

class HousekeepingPanel extends StatefulWidget {
  final UserDetails detailsUser;
  HousekeepingPanel({Key key, @required this.detailsUser}) : super(key: key);
  @override
  _HousekeepingPanelState createState() => _HousekeepingPanelState();
}

class _HousekeepingPanelState extends State<HousekeepingPanel> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
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
        payload:
            'New Shift Assigned: $place - From: $start_datetime, To: $end_datetime');
  }

  @override
  void getShifthistory() async {
    result = await http.post(
        "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
        body: {
          "showshiftdutyhistoryemail": HKuserEmail,
        });
    //debugPrint(result.body);
    //new Timer.periodic(oneSec, (Timer t) => getShifthistory());

    Map checkshift = json.decode(result.body);
    // place = checkshift['place'];
    // start_datetime = checkshift['start_datetime'];
    // end_datetime = checkshift['end_datetime'];

    new Timer.periodic(
        oneSec,
        (Timer t) => setState(() {
              if (strcmp(place, checkshift['place']) == false ||
                  strcmp(start_datetime, checkshift['start_datetime']) ==
                      false ||
                  strcmp(end_datetime, checkshift['end_datetime']) == false) {
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
          drawer: NavDrawer(),
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
        ));
  }
}

// class HousekeepingScreen extends StatelessWidget {
//   final UserDetails detailsUser;
//   HousekeepingScreen({Key key, @required this.detailsUser}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     void getShifthistory() async {
//       result = await http.post(
//           "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
//           body: {
//             "showshiftdutyhistoryemail": HKuserEmail,
//           });
//       debugPrint(result.body);

//       Map checkshift = json.decode(result.body);
//       place = checkshift['place'];
//       start_datetime = checkshift['start_datetime'];
//       end_datetime = checkshift['end_datetime'];
//       debugPrint(place + start_datetime + end_datetime);
//     }

//     final GoogleSignIn _gSignIn = GoogleSignIn();
//     HKuserEmail = detailsUser.userEmail;
//     HKuserName = detailsUser.userName;
//     HKuserPhoto = detailsUser.photoUrl;
//     getShifthistory();
//     return new WillPopScope(
//         onWillPop: () => null,
//         child: Scaffold(
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
//           drawer: NavDrawer(),
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
//         ));
//   }
// }

void noPending(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "No Pending Request",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20.0),
          ),
          content: new Text(
            "HSM pending list for ($place) is empty.",
            textAlign: TextAlign.left,
            style: TextStyle(
                //fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14.0),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

void hsmPendingStatus(BuildContext context) async {
  Map status = new Map();
  var url = '$SERVER/hsmoperations.php';
  var response = await http.post(url, body: {
    "hsmrequestplacestatus": place,
  });

  status = json.decode(response.body);

  if (strcmp(status['status'], "NotAvailable") == true) {
    noPending(context);
  } else {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => HSMrequestList()));
  }
}

class HSMrequestList extends StatefulWidget {
  @override
  _HSMrequestListState createState() => _HSMrequestListState();
}

class _HSMrequestListState extends State<HSMrequestList> {
  //final items = List<String>.generate(7, (i) => "Item ${i + 1}");
  Map hsmpendingservicelist = new Map();

  void gethsmpendingservicelist() async {
    var url = '$SERVER/hsmoperations.php';
    var response = await http.post(url, body: {
      "hsmrequestplace": place,
    });

    if (response.statusCode == 200) {
      setState(() => hsmpendingservicelist = json.decode(response.body));
      debugPrint(
          'Loaded ${hsmpendingservicelist.length} HSM requests from server.');
    }
  }

  @override
  void initState() {
    super.initState();
    gethsmpendingservicelist();
  }

  //-> OTP Scan

  String otpscan = "Avantika HSM";
  Future _scanQR(String request_id) async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        otpscan = qrResult;
        debugPrint(otpscan);
        verifyOTPserver(otpscan, request_id, context);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          otpscan = "Camera permission was denied";
          debugPrint(otpscan);
        });
      } else {
        setState(() {
          otpscan = "Unknown Error $ex";
          debugPrint(otpscan);
        });
      }
    } on FormatException {
      setState(() {
        otpscan = "Try Again";
        debugPrint(otpscan);
      });
    } catch (ex) {
      setState(() {
        otpscan = "Unknown Error $ex";
        debugPrint(otpscan);
      });
    }
  }

  void _otpModal(context, String request_id) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(FontAwesomeIcons.qrcode),
                    title: new Text('Scan QR code'),
                    onTap: () => {
                          _scanQR(request_id),
                          // Navigator.push(
                          //     context,
                          //     new MaterialPageRoute(
                          //         builder: (context) => new QRscan())),
                          //debugPrint(request_id),
                        }),
                new ListTile(
                  leading: new Icon(FontAwesomeIcons.key),
                  title: new Text('Enter OTP'),
                  onTap: () => {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new OTPinput())),
                        debugPrint(request_id),
                      },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //gethsmpendingservicelist();
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Pending HSM service requests'),
      ),
      body: ListView.builder(
        itemCount: hsmpendingservicelist.length,
        itemBuilder: (context, int index) {
          String key = hsmpendingservicelist.keys.elementAt(index);
          //final item = hsmpendingservicelist[index];
          return new Slidable(
            delegate: new SlidableDrawerDelegate(),
            actionExtentRatio: 0.25,
            child: new Container(
              color: Colors.white,
              child: new ListTile(
                leading: new CircleAvatar(
                  backgroundColor: Colors.red,
                  child: new Icon(Icons.history),
                  foregroundColor: Colors.white,
                ),
                title: new Text(hsmpendingservicelist[key]["place"] +
                    ' : Room no. ' +
                    hsmpendingservicelist[key]["room"] +
                    ' ( by ' +
                    hsmpendingservicelist[key]["user_mail"] +
                    ' )'),
                subtitle: new Text(hsmpendingservicelist[key]["category"] +
                    ' : ' +
                    hsmpendingservicelist[key]["remarks"]),
              ),
            ),
            actions: <Widget>[
              //   new IconSlideAction(
              //     caption: 'Room Locked',
              //     color: Colors.red,
              //     icon: Icons.lock,
              //     //onTap: () => _showSnackBar('More'),
              //   ),
              //   new IconSlideAction(
              //     caption: 'OTP',
              //     color: Colors.blue,
              //     icon: Icons.offline_pin,
              //     //onTap: () => _showSnackBar('Delete'),
              //   ),
              new IconSlideAction(
                caption: 'OTP',
                color: Colors.blue,
                icon: Icons.offline_pin,
                onTap: () => _otpModal(
                    context, hsmpendingservicelist[key]["request_id"]),
              ),
            ],
            secondaryActions: <Widget>[
              // new IconSlideAction(
              //   caption: 'Room Locked',
              //   color: Colors.red,
              //   icon: Icons.lock,
              //   //onTap: () => _showSnackBar('More'),
              // ),
              new IconSlideAction(
                caption: 'OTP',
                color: Colors.blue,
                icon: Icons.offline_pin,
                onTap: () => _otpModal(
                    context, hsmpendingservicelist[key]["request_id"]),
              ),
            ],
          );
          // Dismissible(
          //   key: Key(item),
          //   onDismissed: (direction) {
          //     setState(() {
          //       items.removeAt(index);
          //     });
          //     Scaffold.of(context)
          //         .showSnackBar(SnackBar(content: Text("$item dismissed")));
          //   },
          //   background: Container(color: Colors.red),
          //   child: ListTile(title: Text('$item')),
          // );
        },
      ),
    );
  }
}

class OTPinput extends StatefulWidget {
  @override
  _OTPinputState createState() => _OTPinputState();
}

class _OTPinputState extends State<OTPinput> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Enter OTP"),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height * 0.7,
            ),
            new Text("Enter 4 digit OTP"),
            PinEntryTextField(
              onSubmit: (String pin) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Pin"),
                        content: Text('Pin entered is $pin'),
                      );
                    }); //end showDialog()
              }, // end onSubmit
            ),
          ],
        )));
  }
}

void verifyOTPserver(
    String otp, String request_id, BuildContext context) async {
  result = await http.post(
      "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/
      body: {
        "qrotpscan": otp,
        "hsmrequestid": request_id,
        "verifiedbystaff": HKuserEmail
      });
  Map pendingotp = json.decode(result.body);
  debugPrint(result.body);
  if (strcmp(pendingotp["status"], "verified") == true) {
    Fluttertoast.showToast(
        msg: 'OTP verified',
        gravity: ToastGravity.BOTTOM,
        //backgroundColor: Colors.red,
        timeInSecForIos: 2);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    hsmPendingStatus(context);
  } else {
    Fluttertoast.showToast(
        msg: 'Invalid OTP',
        gravity: ToastGravity.BOTTOM,
        //backgroundColor: Colors.red,
        timeInSecForIos: 2);
  }
}

// -----------------------------------------------------------------------------------------------
//-> QR scanner

// class QRscan extends StatefulWidget {
//   @override
//   QRscanState createState() {
//     return new QRscanState();
//   }
// }

// class QRscanState extends State<QRscan> {
//   String result = "Avantika HSM";

//   Future _scanQR() async {
//     try {
//       String qrResult = await BarcodeScanner.scan();
//       setState(() {
//         result = qrResult;
//       });
//     } on PlatformException catch (ex) {
//       if (ex.code == BarcodeScanner.CameraAccessDenied) {
//         setState(() {
//           result = "Camera permission was denied";
//         });
//       } else {
//         setState(() {
//           result = "Unknown Error $ex";
//         });
//       }
//     } on FormatException {
//       setState(() {
//         result = "Try Again";
//       });
//     } catch (ex) {
//       setState(() {
//         result = "Unknown Error $ex";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Avantika HSM - OTP Scanner"),
//       ),
//       body: Center(
//         child: Text(
//           result,
//           style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: Icon(Icons.camera_alt),
//         label: Text("Scan OTP"),
//         onPressed: _scanQR,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
