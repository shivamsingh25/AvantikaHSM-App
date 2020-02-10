import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:http/http.dart' as http;
import 'package:AvantikaHSM/main.dart';
import '../security.dart';
import 'package:fluttertoast/fluttertoast.dart';

var remarks;
var datetime;
var name;
var dept;
var occ;

class Occurrence extends StatefulWidget {
  @override
  _OccurrenceState createState() => _OccurrenceState();
}

class _OccurrenceState extends State<Occurrence> {
  final GlobalKey<FormState> _generalformKey = GlobalKey<FormState>();

  final _remarksController = TextEditingController();
  final _nameController = TextEditingController();
  final _deptController = TextEditingController();
  final _occController = TextEditingController();

  void getValues(){
    remarks = _remarksController.text; 
    datetime = date.toString();
    name = _nameController.text;
    dept = _deptController.text;
    occ = _occController.text;
    debugPrint(remarks+" : "+datetime+" : "+name+" : "+dept+" : "+occ);
    submitEntry();
  }

  void submitEntry() async {
    result = await http.post(
        "$SERVER/hsmoperations.php", // SERVER:   https://servers.shivamsr.com/hsm/app/account-validator.php
        body: {
          "securityoccurrenceregisterentry" : "OccRegEntry",
          "securityoccurrenceregisterentry_datetime": datetime,
          "securityoccurrenceregisterentry_id": SECuserEmail,
          "securityoccurrenceregisterentry_remarks": remarks,
          "securityoccurrenceregisterentry_dept": dept,
          "securityoccurrenceregisterentry_occ" : occ,
          "securityoccurrenceregisterentry_name" : name
        });
    //Map registerEntry = json.decode(result.body);

      Fluttertoast.showToast(
          msg: 'Occurrence Register Entry has been inserted',
          gravity: ToastGravity.BOTTOM,
          //backgroundColor: Colors.red,
          timeInSecForIos: 2);
  }

  bool _autoValidate = false;
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    //InputType.both: DateFormat("yyyy-mm-dd hh-mm-ss"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;

  void _validateInputs() {
    if (_generalformKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _generalformKey.currentState.save();
      getValues();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Form(
                  key: _generalformKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: Center(
                          child: new Text(
                            "Watchlist/ Occurance Register Entry",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: DateTimePickerFormField(
                          inputType: inputType,
                          format: formats[inputType],
                          editable: editable,
                          decoration: InputDecoration(
                              labelText: 'Date/Time IN',
                              prefixIcon: Icon(Icons.access_time)),
                          onChanged: (dt) => setState(() => date = dt),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          controller: _nameController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          validator: (String arg) {
                            if (arg.length < 3)
                              return 'Name must be more than 2 character';
                            else
                              return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Name",
                              prefixIcon: Icon(Icons.account_circle)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          controller: _deptController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          validator: (String arg) {
                            if (arg.length < 5)
                              return 'Department must be more than 2 character';
                            else
                              return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Department",
                              prefixIcon: Icon(Icons.folder_shared)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          controller: _occController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (String arg1) {
                            if (arg1.length == 0) {
                              return 'Cannot be empty.';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Occurrence",
                              prefixIcon: Icon(Icons.visibility)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          controller: _remarksController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(150),
                          ],
                          decoration: InputDecoration(
                              labelText: "Remarks (if any)",
                              prefixIcon: Icon(Icons.message)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new RaisedButton(
                          color: Colors.red,
                          onPressed: _validateInputs,
                          child: new Text(
                            "Submit Entry",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
