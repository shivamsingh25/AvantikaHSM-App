import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class Generalregsiter extends StatefulWidget {
  @override
  _GeneralregsiterState createState() => _GeneralregsiterState();
}

class _GeneralregsiterState extends State<Generalregsiter> {
  final GlobalKey<FormState> _generalformKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
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
                            "General Register Entry",
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
                        child: new TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (String arg1){
                            if(arg1.length == 0){
                              return 'Cannot be empty.';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Vehicle Number",
                              prefixIcon: Icon(Icons.directions_car)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
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
                              labelText: "Visitor Name",
                              prefixIcon: Icon(Icons.account_circle)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: validateMobile,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: "Visitor Phone",
                              prefixIcon: Icon(Icons.call)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                          validator: (String arg1){
                            if(arg1.length == 0){
                              return 'Cannot be empty.';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Visitor Place",
                              prefixIcon: Icon(Icons.location_on)),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(150),
                          ],
                          validator: (String arg1){
                            if(arg1.length == 0){
                              return 'Cannot be empty.';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Purpose of visit",
                              prefixIcon: Icon(Icons.textsms)),
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
