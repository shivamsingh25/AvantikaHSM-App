import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'CustomShapeClipper.dart';
import 'circular_image.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:swipedetector/swipedetector.dart';
import 'package:share/share.dart';

//-> Global Variables

String signinUsername;
String signinUseremail;
String signinUserimage;
String servicetype;
String remarks;
String requestresponse;
String requeststatus;

//-> HSM Cloud-Firestore data

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

class ProfileScreen extends StatelessWidget {
  final UserDetails detailsUser;
  ProfileScreen({Key key, @required this.detailsUser}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //final GoogleSignIn _gSignIn = GoogleSignIn();
    signinUsername = detailsUser.userName;
    signinUseremail = detailsUser.userEmail;
    signinUserimage = detailsUser.photoUrl;
    return new ZoomScaffold(
      menuScreen: MenuScreen(),
      contentScreen: Layout(
          contentBuilder: (cc) => Container(
                color: Colors.grey[200],
                child: Container(
                  color: Colors.grey[200],
                ),
              )),
    );
  }
}

class HSMhome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    getLatestOTP();
    return Column(
      children: <Widget>[
        SizedBox(
          height: 500.0,
          //child:  Image.asset('images/home.png', scale: 1.0,),
          child: Image.network("$SERVER/images/app/home.png"),
        )
      ],
    );
  }
}

// alignment: Alignment.center,
// height: 100.0,
// width: 100.0,
// child: CircleAvatar(
//   backgroundColor: Colors.transparent,
//   radius: 80.0,
//   child: Image(image: AssetImage('assets/home.png'),)
// ),

String otp_url;
String otp;
String inst;

   void getLatestOTP() async {
    result = await http.post(
        "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/
        body: {"showlatestrequestotp": signinUseremail});
    Map pendingotp = json.decode(result.body);
    print(pendingotp);
    otp = pendingotp['otp'];
    if (strcmp(otp, "null") == true) {
      otp_url = "$SERVER/images/app/none.png";
      inst =
          "No pending requests. Go to the home section and follow the instructions to get your housekeeping needs done.";
      otp = "";
      Fluttertoast.showToast(
          msg: 'No Pending Request',
          gravity: ToastGravity.BOTTOM,
          //backgroundColor: Colors.red,
          timeInSecForIos: 2);
    } else {
      otp_url = "$SERVER/otp.php?otp=" + otp;
      inst =
          "Please share this OTP with the assigned staff at the time of satisfactory request service completion.";
    }
    debugPrint(otp_url);
  }


class PendingRequest extends StatefulWidget {
  @override
  _PendingRequestState createState() => _PendingRequestState();
}

class _PendingRequestState extends State<PendingRequest> {
  @override
  Widget build(BuildContext context) {
    getLatestOTP();
    return Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[
            SizedBox(
                child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Text(inst, style: TextStyle(color: Colors.grey)),
            )),
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height * 0.6, //350.0,
              child: Image.network(otp_url),
            ),
            SizedBox(
              child: new Text(
                otp,
                style: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 15.0,
                ),
              ),
            ),
          ],
        ));
  }
}

// -> Zoom Scaffold

class ZoomScaffold extends StatefulWidget {
  final Widget menuScreen;
  final Layout contentScreen;
  final Function detailsUser;
  //ZoomScaffold(this.menuScreen, this.contentScreen, this.detailsUser);

  ZoomScaffold({this.menuScreen, this.contentScreen, this.detailsUser});

  @override
  _ZoomScaffoldState createState() => new _ZoomScaffoldState();
}

class _ZoomScaffoldState extends State<ZoomScaffold>
    with TickerProviderStateMixin {
  MenuController menuController;
  Curve scaleDownCurve = new Interval(0.0, 0.3, curve: Curves.easeOut);
  Curve scaleUpCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideOutCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideInCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);

  int _currentIndex = 0;
  final List<Widget> _children = [
    HSMhome(),
    SettingsWidget(),
    PendingRequest()
  ];

  Future<bool> _onWillPop() {
    return menuController.toggle();
  }

  @override
  void initState() {
    super.initState();

    menuController = new MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  createContentDisplay() {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: zoomAndSlideContent(
            // Call MenuToggle on Back Press
            new Container(
                child: SwipeDetector(
          onSwipeRight: () {
            menuController.toggle();
          },
          onSwipeLeft: () {
            menuController.toggle();
          },
          child: new Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomPadding: false,
              body: Column(children: <Widget>[
                SizedBox(
                    child: ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                      height: 130.0,
                      color: Colors.red,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new IconButton(
                                icon: new Icon(
                                  Icons.sort,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  menuController.toggle();
                                }),
                            new InkResponse(
                              //onTap: menuController.toggle(),
                              child: new Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: new Center(
                                  child: new Text("Avantika HSM",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                )),
                SizedBox(
                  child: _children.elementAt(
                      _currentIndex), //new SettingsWidget(), //CheckHSM(),
                )
              ]),
              bottomNavigationBar: new Theme(
                data: Theme.of(context).copyWith(
                    // sets the background color of the `BottomNavigationBar`
                    canvasColor: Colors.white,
                    // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                    primaryColor: Colors.red,
                    textTheme: Theme.of(context)
                        .textTheme
                        .copyWith(caption: new TextStyle(color: Colors.grey))),
                child: BottomNavigationBar(
                  onTap: onTabTapped, // new
                  currentIndex: _currentIndex,
                  //currentIndex: 1, // this will be set when a new tab is tapped
                  items: [
                    BottomNavigationBarItem(
                      icon: new Icon(Icons.home),
                      title: new Text('Home'),
                    ),
                    BottomNavigationBarItem(
                      icon: new Icon(Icons.add_box),
                      title: new Text('Request'),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.assignment_turned_in),
                        title: Text('Pending request'))
                  ],
                ),
              )),
        ))));
  }

  zoomAndSlideContent(Widget content) {
    var slidePercent, scalePercent;
    switch (menuController.state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(menuController.percentOpen);
        scalePercent = scaleDownCurve.transform(menuController.percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(menuController.percentOpen);
        scalePercent = scaleUpCurve.transform(menuController.percentOpen);
        break;
    }

    final slideAmount = 275.0 * slidePercent;
    final contentScale = 1.0 - (0.2 * scalePercent);
    final cornerRadius = 16.0 * menuController.percentOpen;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0.0, 0.0)
        ..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: new Container(
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              offset: const Offset(0.0, 5.0),
              blurRadius: 15.0,
              spreadRadius: 10.0,
            ),
          ],
        ),
        child: new ClipRRect(
            borderRadius: new BorderRadius.circular(cornerRadius),
            child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Scaffold(
            body: widget.menuScreen,
          ),
        ),
        createContentDisplay()
      ],
    );
  }
}

class ZoomScaffoldMenuController extends StatefulWidget {
  final ZoomScaffoldBuilder builder;

  ZoomScaffoldMenuController({
    this.builder,
  });

  @override
  ZoomScaffoldMenuControllerState createState() {
    return new ZoomScaffoldMenuControllerState();
  }
}

class ZoomScaffoldMenuControllerState
    extends State<ZoomScaffoldMenuController> {
  MenuController menuController;

  @override
  void initState() {
    super.initState();

    menuController = getMenuController(context);
    menuController.addListener(_onMenuControllerChange);
  }

  @override
  void dispose() {
    menuController.removeListener(_onMenuControllerChange);
    super.dispose();
  }

  getMenuController(BuildContext context) {
    final scaffoldState =
        context.ancestorStateOfType(new TypeMatcher<_ZoomScaffoldState>())
            as _ZoomScaffoldState;
    return scaffoldState.menuController;
  }

  _onMenuControllerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, getMenuController(context));
  }
}

typedef Widget ZoomScaffoldBuilder(
    BuildContext context, MenuController menuController);

class Layout {
  final WidgetBuilder contentBuilder;

  Layout({
    this.contentBuilder,
  });
}

class MenuController extends ChangeNotifier {
  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;

  MenuController({
    this.vsync,
  }) : _animationController = new AnimationController(vsync: vsync) {
    _animationController
      ..duration = const Duration(milliseconds: 250)
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            state = MenuState.opening;
            break;
          case AnimationStatus.reverse:
            state = MenuState.closing;
            break;
          case AnimationStatus.completed:
            state = MenuState.open;
            break;
          case AnimationStatus.dismissed:
            state = MenuState.closed;
            break;
        }
        notifyListeners();
      });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  get percentOpen {
    return _animationController.value;
  }

  open() {
    _animationController.forward();
  }

  close() {
    _animationController.reverse();
  }

  toggle() {
    if (state == MenuState.open) {
      close();
    } else if (state == MenuState.closed) {
      open();
    }
  }
}

enum MenuState {
  closed,
  opening,
  open,
  closing,
}

//-> Menu-Page

class MenuScreen extends StatelessWidget {
  //final UserDetails detailsUser;
  //MenuScreen({Key key, @required this.detailsUser}) : super(key: key);

  final String imageUrl =
      signinUserimage; //"http://i.pravatar.cc/300";//detailsUser.photoUrl;

  final List<MenuItem> options = [
    MenuItem(Icons.dashboard, 'Avantika HSM'),
    MenuItem(Icons.directions_bus, 'Travel'),
  ];

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    return Container(
      padding: EdgeInsets.only(
          top: 62,
          left: 32,
          bottom: 8,
          right: MediaQuery.of(context).size.width / 2.9),
      color: Colors.white, //color: Color(0xff454dff),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircularImage(
                  NetworkImage(imageUrl),
                ),
              ),
              Text(
                signinUsername,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              )
            ],
          ),
          Spacer(),
          Column(
            children: options.map((item) {
              return ListTile(
                onTap: () {},
                leading: Icon(
                  item.icon,
                  color: Colors.black,
                  size: 20,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              );
            }).toList(),
          ),
          Spacer(),
          ListTile(
            onTap: () {
              Share.share("Download Avantika HSM here: \n Https://servers.shivamsr.com/hsm/app/hsm.apk");
            },
            leading: Icon(
              Icons.share,
              color: Colors.black,
              size: 20,
            ),
            title: Text('Share the app',
                style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
          ListTile(
            onTap: () {
              _showDialog(context);
            },
            leading: Icon(
              Icons.info,
              color: Colors.black,
              size: 20,
            ),
            title: Text('App Info',
                style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
          ListTile(
            onTap: () {
              _gSignIn.signOut();
              //_gSignIn.revokeAccess();
              print('SignedOut');
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.power_settings_new,
              color: Colors.black,
              size: 20,
            ),
            title: Text('Logout',
                style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  String title;
  IconData icon;

  MenuItem(this.icon, this.title);
}

// -> HSM request form

class SettingsWidget extends StatefulWidget {
  SettingsWidget({Key key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => new _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  List service = ['Housekeeping', 'Carpenter', 'Plumber', 'Electrician'];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentservice;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentservice = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String service in service) {
      items.add(new DropdownMenuItem(value: service, child: new Text(service)));
    }
    return items;
  }

  final _remarksController = TextEditingController();

  void getRemarks() {
    remarks = _remarksController.text;
  }

  sendRequest() async {
    getRemarks();

    print("$signinUseremail  +  $remarks  +  $servicetype");

    result = await http.post(
        "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
        body: {
          "hsmuserrequestemail": signinUseremail,
          "hsmrequestremarks": remarks,
          "hsmservicecategory": servicetype
        });

    debugPrint(result.body);
    Map hsmrequest = json.decode(result.body);
    //print(hsmrequest);
    requestresponse = hsmrequest['requestresponse'];
    if (strcmp(requestresponse, "nostaff") == true) {
      Fluttertoast.showToast(
          msg: 'No Staff available. Please try again later',
          gravity: ToastGravity.BOTTOM,
          //backgroundColor: Colors.red,
          timeInSecForIos: 2);
    } else if (strcmp(requestresponse, "limitreached") == true) {
      Fluttertoast.showToast(
          msg: 'HSM service request limit has been reached for the day',
          gravity: ToastGravity.BOTTOM,
          //backgroundColor: Colors.red,
          timeInSecForIos: 2);
    } else {
      Fluttertoast.showToast(
          msg: 'Your Request Has been Submitted and is in Queue',
          gravity: ToastGravity.BOTTOM,
          //backgroundColor: Colors.red,
          timeInSecForIos: 2);
    }
    debugPrint(requestresponse);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      //color: Colors.white,
      child: new Center(
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 45.0),
          SizedBox(
              child: new Text(
            "Request for an HSM service",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          )),
          SizedBox(height: 60.0),
          SizedBox(
              child: Padding(
            padding: EdgeInsets.only(right: 160.0),
            child: new Text(
              "Select HSM Service category: ",
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
          )),
          SizedBox(height: 0.0),
          SizedBox(
            width: 350.0,
            child: new DropdownButton(
              value: _currentservice,
              items: _dropDownMenuItems,
              style: TextStyle(fontSize: 20.0, color: Colors.black),
              onChanged: changedDropDownItem,
            ),
          ),
          SizedBox(height: 30.0),
          SizedBox(
            child: Padding(
              padding: EdgeInsets.only(right: 220.0),
              child: new Text(
                "Remarks (optional):",
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 0.0),
          SizedBox(
            width: 350.0,
            child: TextFormField(
              controller: _remarksController,
              //decoration: InputDecoration(labelText: "Remarks:"),
            ),
          ),
          SizedBox(height: 30.0),
          SizedBox(
            height: 40.0,
            child: new Text(
              "*By requesting service you accept usage \n policy of this app for a reasonable cause.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 10.0),
          SizedBox(
            height: 40.0,
            width: 230.0,
            child: RaisedButton(
                padding: const EdgeInsets.only(left: 25.0),
                textColor: Colors.white,
                color: Colors.red,
                splashColor: Colors.red[300],
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Icon(Icons.send),
                    Text("   Request Service",
                        style: new TextStyle(fontSize: 24.0))
                  ],
                ),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  //internetCheck(context);
                  //print("working");
                  sendRequest();
                }),
          ),
        ],
      )),
    );
  }

  void changedDropDownItem(String selectedservice) {
    setState(() {
      _currentservice = selectedservice;
      servicetype = _currentservice;
    });
  }
}

/*

class Hsmform extends StatefulWidget {
  @override
  HsmformState createState() {
    return HsmformState();
  }
}

class HsmformState extends State<Hsmform> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  // If the form is valid, we want to show a Snackbar
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

*/

/* 

// Melt app bar

class ProfileScreen extends StatelessWidget {
  final UserDetails detailsUser;
  ProfileScreen({Key key, @required this.detailsUser}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    return new Scaffold(
        body: Column(children: <Widget>[
          ClipPath(
              clipper: CustomShapeClipper(),
              child: Container(
                  height: 160.0,
                  color: Colors.red,
                  child: Center(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.bars, color: Colors.white),
                      Text(
                        "   Avantika HSM",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 28.0),
                      ),
                    ],
                  ))))
        ]));
  }
}


*/

/*

class ProfileScreen extends StatelessWidget {
  final UserDetails detailsUser;
  ProfileScreen({Key key, @required this.detailsUser}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    return Scaffold(
      appBar: AppBar(
        title: Text(detailsUser.userName),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(icon: Icon(FontAwesomeIcons.signOutAlt,
          size: 20.0,
          color: Colors.white),
          onPressed: (){
            _gSignIn.signOut();
            print('SignedOut');
            Navigator.pop(context);
          },)
        ],
      ),
    );
  }
}

*/

// Zoom - Scaffold

/*



  createContentDisplay() {
    return zoomAndSlideContent(
        new Container(
          child: new Scaffold(
            backgroundColor: Colors.transparent,
            appBar: new AppBar(
              backgroundColor: Colors.grey[200],
              elevation: 0.0,
              leading: new IconButton(
                  icon: new Icon(Icons.sort, color: Colors.black,),
                  onPressed: () {
                    menuController.toggle();
                  }
              ),
            ),
            body: widget.contentScreen.contentBuilder(context),
            body: Column(children: <Widget>[
            ClipPath(
              clipper: CustomShapeClipper(),
              child: Container(
                  height: 50.0,
                  color: Colors.red,
                  child: Center(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                  ))))
        ]))
          ),
    );
  }

*/
