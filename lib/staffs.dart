import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'security.dart';
import 'housekeeping.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

void _launchcaller(var phone) async {
  if (await canLaunch(phone)) {
    await launch(phone);
  } else {
    throw 'Could not launch $phone';
  }
}

class Staffslist extends StatefulWidget {
  @override
  _State createState() => new _State();
}

//State is information of the application that can change over time or when some actions are taken.
class _State extends State<Staffslist> {
  //Map is basically a type of key/value pair in dart
  Map _staffs = new Map();
  Map _searchstaffs = new Map();

  void _getData() async {
    var url = '$SERVER/hsmoperations.php';
    var response = await http.post(url, body: {
      "showhsmstaffprofiles": "showStaffs",
    });

    if (response.statusCode == 200) {
      setState(() => _staffs = json.decode(response.body));
      debugPrint('Loaded ${_staffs.length} staff profiles from server.');
    }
  }

  void filterSearchResults(String query) {
    //List<String> dummySearchList = List<String>();
    Map _searchedstaffs = new Map();
    _searchedstaffs.addAll(_searchstaffs);
    if (query.isNotEmpty) {
      //List<String> dummyListData = List<String>();
      Map _searchedstaffslist = new Map();
      _searchedstaffs.forEach((k, v) {
        if (v.contains(query)) {
          _searchedstaffslist.putIfAbsent(
              k, () => v); //_searchedstaffslist.add(k,v);
        }
      });
      setState(() {
        _staffs.clear();
        _staffs.addAll(_searchedstaffslist);
      });
      return;
    } else {
      setState(() {
        _staffs.clear();
        _staffs.addAll(_searchstaffs);
      });
    }
  }

  @override
  TextEditingController editingController = TextEditingController();
  Widget build(BuildContext context) {
    //_getData();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('HSM Staff Profiles'),
      ),
      body: new Container(
          //padding: new EdgeInsets.all(32.0),
          child: new Center(
        child: new Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            new Expanded(
                child: new ListView.builder(
              itemCount: _staffs.length,
              itemBuilder: (BuildContext context, int index) {
                String key = _staffs.keys.elementAt(index);
                return Card(
                    elevation: 03.0,
                    child: new InkWell(
                        onTap: () {
                          //_launchcaller("tel:" + _staffs[key]["contact"]);
                          print("tapped");
                        },
                        child: new Row(
                          children: <Widget>[
                            SizedBox(
                                width: 150.0,
                                height: 150.0,
                                child:
                                    new Image.network(_staffs[key]["picture"])),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 30.0,
                                    child: new Text('${key}',
                                        style: TextStyle(
                                            fontSize: 26.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                    child: new Text(
                                      _staffs[key]["first_name"] +
                                          " " +
                                          _staffs[key]["last_name"],
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.0,
                                    child: new Text(
                                      _staffs[key]["designation"] +
                                          ", " +
                                          _staffs[key]["department"],
                                      style: TextStyle(
                                          fontSize: 18.0, color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(
                                      child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 40.0,
                                      ),
                                      SizedBox(
                                        child: IconButton(
                                            tooltip: "Call",
                                            icon: new Icon(
                                              Icons.phone,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              _launchcaller("tel: +91" +
                                                  _staffs[key]["contact"]);
                                            }),
                                      ),
                                      SizedBox(
                                        child: new Text(_staffs[key]["contact"],
                                            style: TextStyle(fontSize: 20.0)),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ],
                        )));
              },
            ))
          ],
        ),
      )),
    );
  }

  @override
  void initState() {
    _getData();
  }
}
