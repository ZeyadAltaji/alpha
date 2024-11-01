//import 'package:alpha/pages/ADS.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';

class LeaveRequest extends StatefulWidget {
  @override
  _LeaveRequestState createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  bool _isBusy = false;
  String _notes = "";
  String _address = "";
  FocusNode? addressFocus;
  FocusNode? notesFocus;

  @override
  void initState() {
    addressFocus = FocusNode();
    notesFocus = FocusNode();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (link != "http://212.118.30.35:7472/apicore") {
      //   if (defValues
      //           .where((x) => x.parID == 99998 && x.parNameAr.contains('عمل'))
      //           .length !=
      //       0) {
      //     setState(() {
      //       dropdownValue = defValues
      //           .where((x) => x.parID == 99998 && x.parNameAr.contains('عمل'))
      //           .first;
      //     });
      //   }
      // }
    });
  }

  @override
  void dispose() {
    addressFocus!.dispose();
    notesFocus!.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (dropdownValue.parValue == 0) {
      toast(
          '${arEn('لا يمكن ارسال الطلب بدون نوع محدد', 'The request cannot be sent without a specific type')}');
      return;
    }
    final form = leaveKEY.currentState;
    if (endTime.isBefore(startTime)) {
      toast(
          "${arEn('وقت المغادرة قبل وقت العودة', 'Departure time is before return time')}");
      return;
    }
    //  if (dateDef.inHours > maxPeriod.parValue) {
    //    toast(maxPeriod.parNameAr +
    //        "  ${maxPeriod.parValue.toString().padLeft(2, '0')}:00  ساعة");
    //    return;
    //  }

    if (req == true) {
      if (_notes == "") {
        setState(() {
          notesFocus!.requestFocus();
          return;
        });
      }
    }

    if (_address.length < 3) {
      setState(() {
        addressFocus!.requestFocus();
        return;
      });
    }

    if (form!.validate()) {
      form.save();
      setState(() {
        FocusScope.of(context).unfocus();
        _isBusy = true;
      });
      new Dialogs(
              context,
              _doSave,
              '${arEn('ارسال', 'submit')}',
              '${arEn('هل تريد ارسال الطلب ؟', 'Do you want to send the request?')}',
              false)
          .yesOrNo();
    }
  }

  Future<void> _doSave(bool ok) async {
    if (!ok) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    await db.excute('SaveNewLeaveVac', {
      "CompNo": me!.compNo.toString(),
      "EmpNo": me!.empNum.toString(),
      "Type": "1",
      "StartDate": selectedDate.toString(),
      "EndDate": selectedDate.toString(),
      "StartTime": startTime.toString(),
      "EndTime": endTime.toString(),
      "LeaveType": dropdownValue.parValue.toString(),
      "VacationType": "0",
      "Address": _address,
      "Substitute": me!.empNum.toString(),
      "Notes": _notes,
      "SendEmail": "false",
      "LevType": dropdownValue.parNameAr.toString(),
      "Lang": gLang,
    }).then((dynamic value) {
      _done(value["result"].toString(), value["error"]);
    }).whenComplete(() {});
  }

  void _done(String msg, bool error) async {
    if (msg == "" && error) {
      setState(() {
        _isBusy = false;
      });
      return;
    }
    msg = translate(msg);
    FocusScope.of(context).unfocus();
    new Future.delayed(new Duration(seconds: 0), () async {
      return await showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) => error
              ? errorDialog(msg.replaceAll('error - ', ''))
              : successDialog(msg)).then((value) {
        setState(() {
          _isBusy = false;
        });
        if (!error) Navigator.pop(context);
      });
    });
  }

  DefValue maxPeriod = defValues.where((x) => x.parID == 1).first;
  bool req =
      boolParse(defValues.where((x) => x.parID == 7).first.parValue.toString());

  List<DefValue> vationTypes =
      defValues.where((x) => x.parID == 99998).toList();

  DefValue dropdownValue = defValues.where((x) => x.parID == 99998).first;
  Duration get dateDef {
    startTime = new DateTime(now.year, now.month, now.day, startTime.hour,
        startTime.minute, 0, 0, 0);
    endTime = new DateTime(
        now.year, now.month, now.day, endTime.hour, endTime.minute, 0, 0, 0);
    return endTime.difference(startTime);
  }

  String get timeDef => !dateDef.isNegative
      ? "${dateDef.inHours.toString().padLeft(2, '0')}:${dateDef.inMinutes.remainder(60).toString().padLeft(2, '0')}"
      : "${arEn('اوقات غير صحيحة', 'The times are not correct')}";

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String title = arguments['desc'].toString();
    String selectedTime = timeFormat.format(startTime);
    if (gLang == "1") {
      selectedTime = selectedTime.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    }

    String selectedTime2 = timeFormat.format(endTime);
    if (gLang == "1") {
      selectedTime2 = selectedTime2.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    }
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(title: title, actions: [
          !_isBusy
              ? TextButton(
                  child: Text(arEn('ارسال', 'Send')),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.transparent),
                    overlayColor: WidgetStateProperty.all<Color>(
                        Colors.transparent), //splash
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: _submit,
                )
              : Center(
                  child: circular,
                ),
        ]),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(5),
          child: Container(
            child: ListView(
              padding: EdgeInsets.only(left: 10.0, right: 10),
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: new Column(
                    children: <Widget>[
                      new Form(
                        key: leaveKEY,
                        child: Container(
                          child: new Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  new Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                              '${arEn('وقت المغادرة', 'Departure time')}'),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                        ),
                                        Button(
                                          onPressed: () {
                                            selectTime(1);
                                          },
                                          text: selectedTime,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                              '${arEn('وقت العودة', 'Return time')}'),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                        ),
                                        Button(
                                          onPressed: () {
                                            selectTime(2);
                                          },
                                          text: selectedTime2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                              '${arEn('التاريخ', 'Date')}'),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                        ),
                                        Button(
                                          onPressed: () {
                                            selectDate();
                                          },
                                          text: selectedDate
                                              .toString()
                                              .split(' ')[0]
                                              .replaceAll('-', '/'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${arEn('مدة المغادرة ', 'Departure Duration')} :  $timeDef',
                                    style: dateDef.isNegative
                                        ? TextStyle(
                                            color: Colors.red,
                                          )
                                        : TextStyle(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${arEn(': نوع المغادرة', 'Type of departure :')}',
                                      textDirection: TextDirection.ltr,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    new Container(
                                      child: DropdownButton<DefValue>(
                                        value: dropdownValue,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        underline: Container(
                                          height: 0,
                                        ),
                                        onChanged: (DefValue? newValue) {
                                          setState(() {
                                            dropdownValue = newValue!;
                                          });
                                        },
                                        items: vationTypes.map(
                                          (DefValue value) {
                                            return DropdownMenuItem<DefValue>(
                                              value: value,
                                              child: Container(
                                                width: 200,
                                                child: Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(0),
                                                    child: Text(
                                                      arEn(value.parNameAr!,
                                                          value.parNameEn!),
                                                      textDirection: direction,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              new Container(
                                child: TextFormField(
                                  controller:
                                      TextEditingController(text: '$_address'),
                                  keyboardType: TextInputType.text,
                                  onSaved: (val) => _address = val!,
                                  onChanged: (val) => _address = val,
                                  validator: (val) {
                                    if (val!.length < 3) {
                                      return "${arEn('الرجاء ادخال عنوان صحيح', 'Please enter a valid address')}";
                                    }
                                    return null;
                                  },
                                  focusNode: addressFocus,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      border: OutlineInputBorder(),
                                      counterText: "",
                                      labelText:
                                          '${arEn('العنوان خلال المغادرة', 'Address during leave')}'),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              new Container(
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  onSaved: (val) => _notes = val!.trim(),
                                  onChanged: (val) => _notes = val.trim(),
                                  validator: (val) {
                                    if (req) {
                                      if (val == "") {
                                        return "${arEn('يجب ادخال سبب المغادرة', 'The reason for leaving must be entered')}";
                                      }
                                    }
                                    return null;
                                  },
                                  maxLines: 4,
                                  focusNode: notesFocus,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      counterText: "",
                                      labelText:
                                          '${arEn('سبب المغادرة', 'Leaving reason')}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        //bottomSheet: ad7,
      ),
    );
  }

  DateTime startTime = MyDateUtils(now)
      .copyWith(
          hour: now.hour, minute: 0, second: 0, microsecond: 0, millisecond: 0)
      .add(new Duration(hours: 0));
  DateTime endTime = MyDateUtils(now)
      .copyWith(
          hour: now.hour, minute: 0, second: 0, microsecond: 0, millisecond: 0)
      .add(new Duration(hours: 0));
  DateTime selectedDate = MyDateUtils(now).copyWith(
      year: now.year,
      month: now.month,
      day: now.day,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: 0,
      millisecond: 0);

  void selectTime(int selector) async {
    if (selector == 1) {
      showTimePicker(
        useRootNavigator: true,
        context: context,
        initialTime: TimeOfDay(hour: startTime.hour, minute: startTime.minute),
      ).then((TimeOfDay ?value) {
        if (value != null) {
          setState(() {
            startTime = MyDateUtils(startTime)
                .copyWith(hour: value.hour, minute: value.minute);
          });
        }
      });
    } else {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: endTime.hour, minute: endTime.minute),
      ).then((TimeOfDay? value) {
        if (value != null) {
          setState(() {
            endTime = MyDateUtils(endTime)
                .copyWith(hour: value.hour, minute: value.minute);
          });
        }
      });
    }
  }

  void selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}
