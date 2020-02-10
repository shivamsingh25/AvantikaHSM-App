import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:convert';
import '../main.dart';
import '../housekeeping.dart';

var start_time;
var end_time;
String room;
String s_time, e_time;
String remarks = null;
String Serversignid;
String sort = "ASC";

// -> Webview Signature Pane
class ServerSign extends StatefulWidget {
  @override
  _ServerSignState createState() => _ServerSignState();
}

class _ServerSignState extends State<ServerSign> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Verification Signature : $room - $place'),
      ),
      body: new WebView(
        initialUrl:
            '$SERVER/signature.php?housekeepingregisterid=$Serversignid',
        javascriptMode: JavascriptMode.unrestricted,
      ),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(builder:
        (BuildContext context, AsyncSnapshot<WebViewController> controller) {
      return FloatingActionButton(
        onPressed: () async {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => HousekeepingRegister()));
        },
        child: const Icon(Icons.check),
      );
    });
  }
}

//HousekeepingRegister

class HousekeepingRegister extends StatefulWidget {
  @override
  _HousekeepingRegisterState createState() => _HousekeepingRegisterState();
}

class _HousekeepingRegisterState extends State<HousekeepingRegister> {
  Map housekeepingregisterlist = new Map();

  void sortState() {
    if (strcmp(sort, "ASC")) {
      sort = "DESC";
    } else {
      sort = "ASC";
    }
  }

  void gethousekeepingregisterlist() async {
    var url = '$SERVER/hsmoperations.php';
    var response = await http.post(url, body: {
      "housekeepingregisterplace": place,
      "sortstate": sort,
    });

    if (response.statusCode == 200) {
      setState(() => housekeepingregisterlist = json.decode(response.body));
      debugPrint(
          'Loaded ${housekeepingregisterlist.length} rooms from server for $place.');
    }
  }

  @override
  void initState() {
    super.initState();
    gethousekeepingregisterlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Row(
          children: <Widget>[
            SizedBox(
              child: IconButton(
                  tooltip: "Back",
                  icon: new Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            SizedBox(
              child: new Text('Housekeeping Register - $place'),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            tooltip: "Sort",
            icon: Icon(Icons.swap_vert, color: Colors.white),
            onPressed: () {
              sortState();
              Navigator.pop(context);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => HousekeepingRegister()));
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: housekeepingregisterlist.length,
        itemBuilder: (context, int index) {
          String key = housekeepingregisterlist.keys.elementAt(index);
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
                title: new Text('Room : ' + housekeepingregisterlist[key]),
                subtitle: new Text(place),
              ),
            ),
            actions: <Widget>[
              // new IconSlideAction(
              //   caption: 'Room Locked',
              //   color: Colors.red,
              //   icon: Icons.lock,
              //   //onTap: () => _showSnackBar('More'),
              // ),
              new IconSlideAction(
                  caption: 'Entry',
                  color: Colors.green,
                  icon: Icons.enhanced_encryption,
                  onTap: () {
                    room = housekeepingregisterlist[key];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Housekeepingregisterform(),
                        ));
                  }),
            ],
            secondaryActions: <Widget>[
              new IconSlideAction(
                  caption: 'Entry',
                  color: Colors.green,
                  icon: Icons.enhanced_encryption,
                  onTap: () {
                    room = housekeepingregisterlist[key];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Housekeepingregisterform(),
                        ));
                  }),
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

class Housekeepingregisterform extends StatefulWidget {
  @override
  _HousekeepingregisterformState createState() =>
      _HousekeepingregisterformState();
}

class _HousekeepingregisterformState extends State<Housekeepingregisterform> {
  final remarksControl = TextEditingController();

  void submithousekeepingregisterentry() async {
    remarks = remarksControl.text;
    s_time = start_time.toString();
    e_time = end_time.toString();
    print(place + room + HKuserEmail + s_time + e_time + remarks);
    result = await http.post(
        "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/
        body: {
          "housekeepingregisterentry": "AppEntry",
          "housekeepingregisterentryplace": place,
          "housekeepingregisterentryroom": room,
          "housekeepingregisterentrystaff": HKuserEmail,
          "housekeepingregisterentrystart": s_time,
          "housekeepingregisterentryend": e_time,
          "housekeepingregisterentryremarks": remarks
        });

    Map id = json.decode(result.body);
    Serversignid = id['record_id']['id'];
    print("$SERVER/signature.php?housekeepingregisterid=$Serversignid");

    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => ServerSign(),
        ));
    //print(place + room + HKuserEmail + start_time + end_time + remarks);

    //print("HK register form submission response: " + result.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: new Text("Room : $room - $place"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              SizedBox(
                  child: Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0),
                child: Image.network('$SERVER/images/app/hkregister.png'),
              )),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                child: new TextField(
                    controller: remarksControl,
                    decoration: InputDecoration(
                      labelText: "Remarks (if any)",
                      hintText: "Service type (deep clean etc.)",
                    )),
              ),
              SizedBox(
                height: 30.0,
              ),
              SizedBox(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width * 0.85,
                    ),
                    SizedBox(
                      width: 100.0,
                      height: 50.0,
                      child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.red,
                          splashColor: Colors.red[300],
                          onPressed: () {
                            DatePicker.showTimePicker(context,
                                showTitleActions: true, onChanged: (date) {
                              //print('change $date');
                            }, onConfirm: (date) {
                              //print('confirm $date');
                              start_time = date;
                              print(start_time);
                            });
                          },
                          child: Text('Start Time')),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width * 0.8,
                    ),
                    SizedBox(
                      width: 100.0,
                      height: 50.0,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.red,
                        splashColor: Colors.red[300],
                        onPressed: () {
                          DatePicker.showTimePicker(context,
                              showTitleActions: true, onChanged: (date) {
                            //print('change $date');
                          }, onConfirm: (date) {
                            //print('confirm $date');
                            end_time = date;
                            print(end_time);
                          });
                        },
                        child: Text('End Time'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              SizedBox(
                width: 200.0,
                height: 50.0,
                child: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.red,
                  splashColor: Colors.red[300],
                  child: new Text("Submit & Student Signature"),
                  onPressed: () {
                    submithousekeepingregisterentry();
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

// --->> Flutter Canvas - problem: cannot save or import sign

// class SignaturePanel extends StatefulWidget {
//   @override
//   _SignaturePanelState createState() => new _SignaturePanelState();
// }

// class _SignaturePanelState extends State<SignaturePanel> {
//   List<Offset> _points = <Offset>[];

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       body: new Container(
//         child: new GestureDetector(
//           onPanUpdate: (DragUpdateDetails details) {
//             setState(() {
//               RenderBox object = context.findRenderObject();
//               Offset _localPosition =
//                   object.globalToLocal(details.globalPosition);
//               _points = new List.from(_points)..add(_localPosition);
//             });
//           },
//           onPanEnd: (DragEndDetails details) => _points.add(null),
//           child: new CustomPaint(
//             painter: new Signature(points: _points),
//             size: Size.infinite,
//           ),
//         ),
//       ),
//       floatingActionButton: new FloatingActionButton(
//           child: new Icon(Icons.clear),
//           onPressed: () => _points.clear(),
//           ),
//     );
//   }
// }

// class Signature extends CustomPainter {
//   List<Offset> points;

//   Signature({this.points});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = new Paint()
//       ..color = Colors.red
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 10.0;

//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i] != null && points[i + 1] != null) {
//         canvas.drawLine(points[i], points[i + 1], paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
// }
