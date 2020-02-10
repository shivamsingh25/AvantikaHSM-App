import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'CustomShapeClipper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// -> Pages
import 'home.dart';
import 'housekeeping.dart';
import 'security.dart';

//-> Material RED: #F44336

//-> SERVER address 

String SERVER =
    "http://10.21.0.248"; //"http://192.168.1.100";   http://10.21.0.248

const oneSec = const Duration(seconds: 10);

// -> String Compare

bool strcmp(String a, String b) {
  if (a.length == b.length) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] == b[i]) {
        // Do nothing
      } else {
        return false;
      }
    }
  } else {
    return false;
  }
  return true;
}

int Intcheck = 0;

// -> Internet Connectivity
Future internetCheck(BuildContext context) async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      Intcheck = 1;
      //Navigator.pop(context);
    }
  } on SocketException catch (_) {
    print('not connected');
    Networkcheck(context);
    //   Navigator.push(
    //       context, new MaterialPageRoute(builder: (context) => new Nointernet()));
    // }
  }
}

class Nointernet extends StatefulWidget {
  @override
  _NointernetState createState() => _NointernetState();
}

class _NointernetState extends State<Nointernet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new WillPopScope(
          //Wrap out body with a `WillPopScope` widget that handles when a user is cosing current route
          onWillPop: () async {
            Future.value(
                false); //return a `Future` with false value so this route cant be popped or closed.
          },
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 250.0,
                ),
                SizedBox(
                  child: Icon(
                    Icons.signal_wifi_off,
                    size: 150.0,
                  ),
                ),
                SizedBox(
                  child: new Text(
                    "Please check the device's internet connection.",
                    style:
                        TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                    height: 50.0,
                    child: new FlatButton(
                      child: new Text("Try Again"),
                      onPressed: () {
                        internetCheck(context);
                      },
                    )),
              ],
            ),
          )),
    );
  }
}

void Networkcheck(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Network Error",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20.0),
          ),
          content: new Text(
            "There was a problem connecting to the internet. Please check your internet connection and try again.",
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

// -> No Back Press
// WillPopScope(
//       //Wrap out body with a `WillPopScope` widget that handles when a user is cosing current route
//       onWillPop: () async {
//         Future.value(
//             false); //return a `Future` with false value so this route cant be popped or closed.
//       },
//       child: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );

// -> Account Authenticator

var result;
void post(FirebaseUser user, UserDetails details, BuildContext context) async {
  result = await http.post(
      "$SERVER/extra/account-validator.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
      body: {"avantikagsigninemail": user.email});
  Map account = json.decode(result.body);
  print(account);
  //print(result);
  String type = account['type'];
  //print(type.length);
  //String test = "helloo";
  //print(strcmp(test,"helloo"));
  //print(strcmp(type,"student"));
  //print(identical(type,"student"));
  String avantikamailcheckemail = user.email;
  String avantikamail = avantikamailcheckemail.substring(
      avantikamailcheckemail.length - 16, avantikamailcheckemail.length);
  if (strcmp(avantikamail, "@avantika.edu.in") == true) {
    print("User Validated");
  } else {
    /*
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('Please use only Avantika University Email for Signin'),
          backgroundColor: Colors.red,
        ));
        */
    Fluttertoast.showToast(
        msg: 'Please use Official Avantika University Email for Signin',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        timeInSecForIos: 2);
  }

  if (strcmp(type, "student") == true) {
    Fluttertoast.showToast(
        msg: 'Sign In Success',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        timeInSecForIos: 2);
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ProfileScreen(detailsUser: details)));
    });
  }

  if (strcmp(type, "security") == true) {
    print("Security User Validated");
    Fluttertoast.showToast(
        msg: 'Sign In Success',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        timeInSecForIos: 2);
    Future.delayed(const Duration(milliseconds: 2000), () {
      SECuserEmail = details.userEmail;
      SECuserName = details.userName;
      SECuserPhoto = details.photoUrl;
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new SecurityPanel(detailsUser: details)));
    });
  }

  if (strcmp(type, "housekeeping") == true) {
    print("Housekeeping User Validated");
    Fluttertoast.showToast(
        msg: 'Sign In Success',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        timeInSecForIos: 2);
    Future.delayed(const Duration(milliseconds: 2000), () {
      HKuserEmail = details.userEmail;
      HKuserName = details.userName;
      HKuserPhoto = details.photoUrl;
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) =>
                  new HousekeepingPanel(detailsUser: details)));
    });
  }
}

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

Future clearShared() async {
  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.clear();
  var appDir = (await getTemporaryDirectory()).path;
  new Directory(appDir).delete(recursive: true);
}

// Main APP

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avantika-HSM',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Gsignin(),
    );
  }
}

class Gsignin extends StatefulWidget {
  @override
  _GsigninState createState() => _GsigninState();
}

class _GsigninState extends State<Gsignin> {
  @override
  void initState() {
    super.initState();
    internetCheck(context);
    clearShared();
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => internetCheck(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(
      children: <Widget>[
        SizedBox(child: CustomShape()),
        SizedBox(
          height: 100.0,
        ),
        SizedBox(
          child: new Text(
            "© 2019 Avantika University, Ujjain (MP)",
            style: TextStyle(color: Colors.grey),
          ),
        )
      ],
    ));
  }
}

class CustomShape extends StatefulWidget {
  @override
  _CustomShapeState createState() => _CustomShapeState();
}

class _CustomShapeState extends State<CustomShape> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> _signIn(BuildContext context) async {
    /*
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text('Sign In'),
      ));
      */

    //internetCheck(context);
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        await _firebaseAuth.signInWithCredential(credential);

    ProviderDetails providerInfo = new ProviderDetails(user.providerId);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(providerInfo);

    UserDetails details = new UserDetails(user.providerId, user.displayName,
        user.photoUrl, user.email, providerData);

    post(user, details, context);
    //print(result.body);
    //String type = JSON.jsonDecode(result.body);
    //print("skipped");
    //print(user.email);

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height:
                          MediaQuery.of(context).size.height - 156.0, //580.0,
                      color: Colors.red,
                      child: Center(
                          child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40.0,
                          ),
                          SizedBox(
                            child: Row(
                              children: <Widget>[
                                //padding: EdgeInsets.only(top: 50.0,bottom: 100.0, right: 260.0 ),
                                new IconButton(
                                    icon: new Icon(
                                      Icons.home,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _showDialog(context);
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
                          ),
                          // SizedBox(
                          //   height: 0.0,
                          // ),
                          // SizedBox(
                          //   height: 350.0,
                          //   child: new Image.network("$SERVER/images/app/main-logo.png"),
                          // ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height -
                                (MediaQuery.of(context).size.height * 0.65),
                          ),
                          SizedBox(
                              width: 250.0,
                              height: 50.0,
                              child: RaisedButton(
                                padding: const EdgeInsets.only(left: 70.0),
                                textColor: Colors.red,
                                color: Colors.white,
                                splashColor: Colors.red[100],
                                child: Row(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.google),
                                    Text("  Sign in",
                                        style: new TextStyle(fontSize: 28.0))
                                  ],
                                ),
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                onPressed: () => _signIn(context)
                                    .catchError((e) => print(e)),
                              )),
                        ],
                      ))),
                )
              ],
            ));
  }
}

class UserDetails {
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final String userEmail;
  final List<ProviderDetails> providerData;
  UserDetails(this.providerDetails, this.userName, this.photoUrl,
      this.userEmail, this.providerData);
}

class ProviderDetails {
  ProviderDetails(this.providerDetails);
  final String providerDetails;
}

// -> App Info Modal

/*


// Card Signin

Widget build(BuildContext context) {
    return Center(
        child: Card(
        margin: const EdgeInsets.only(left: 50.0, right: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/logo.png', height: 150.0, width: 150.0),
            //Text("Please Sign in with your Avantika Email ID to continue to Housekeeping and Security Management System (HSM)",style: new TextStyle(fontSize: 14.0)),
            ButtonTheme.bar(
              minWidth: 295.0,
              height: 50.0,
              // make buttons use the appropriate styles for cards
              child: ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    splashColor: Colors.blue,
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(FontAwesomeIcons.google),
                        Text("  Sign in", style: new TextStyle(fontSize: 28.0))
                      ],
                    ),
                    textColor: Colors.white,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    onPressed: () {/* ... */},
                  ),
                ],
              ),
            ),
          ],
        ),
      ), 

    );
  }
}

*/
