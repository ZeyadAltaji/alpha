import 'dart:convert';
import 'package:flutter/material.dart';
import '../../GeneralFiles/General.dart';
import 'package:http/http.dart' as http;

class MissingFingerPrints extends StatefulWidget {
  @override
  _MissingFingerPrintsState createState() => _MissingFingerPrintsState();
}

class _MissingFingerPrintsState extends State<MissingFingerPrints> {
  Future<dynamic> getData() async {
    var body = {
      "CompNo": "${me!.compNo}",
      "EmpNo": "${me!.empNum}",
      "FromDate":
          dateFormat.format(now.add(Duration(days: -180))), //DateTime FromDate
      "ToDate":
          dateFormat.format(now.add(Duration(days: 180))), //DateTime ToDate
      "lang": gLang, //short lang = 1
    };
    String _baseUrl = Uri.encodeFull('$myProtocol$serverURL/GetAttendance');
    var res =
        await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(
            title: '${arEn('تسجيل بصمة دوام', 'Time attendance registration')}',
            actions: []),
        body: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data != null) {
              List list = snapshot.data["result"];
              if (list.length == 0) return noData;
              return Container(
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(colors: [
                    primaryColor.withOpacity(0.01),
                    primaryColor.withOpacity(0.01),
                  ]),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    return MissingPrint(data: list[i]);
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: primaryColor.withOpacity(0.35),
                    );
                  },
                ),
              );
            }
            return Center(
              child: circular,
            );
          },
        ),
      ),
    );
  }
}

class MissingPrint extends StatefulWidget {
  final dynamic data;

  const MissingPrint({Key? key, this.data}) : super(key: key);
  @override
  _MissingPrintState createState() => _MissingPrintState();
}

class _MissingPrintState extends State<MissingPrint> {
  bool get it => widget.data["emp_In"] == "00:00";
  bool get ot => widget.data["emp_Out"] == "00:00";
  DateTime get day => DateTime.parse(widget.data["sDate"]);
  void _done(String msg, bool error, String k, String dayTime) async {
    if (msg == "" && error) {
      setState(() {
        // _isBusy = false;
      });
      return;
    }
    msg = translate(msg);
    Navigator.pop(context);
    new Future.delayed(new Duration(seconds: 0), () async {
      return await showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) => error
              ? errorDialog(msg.replaceAll('error - ', ''))
              : successDialog(msg)).then((value) {
        if (!error) {
          setState(() {
            setState(() {
              widget.data[k] = dayTime;
            });
          });
        }
      });
    });
  }

  void doSave(String dayTime, String note, bool isIN) async {
    await db.excute('InsertInOutPunch', {
      "CompNo": '${me!.compNo}',
      "IsIn": isIN ? "In" : "Out",
      "EmpNo": '${me!.empNum}',
      "DayDate": '${dateFormat.format(day)}',
      "DayTime": '$dayTime',
      "Note": '$note',
    }).then((dynamic value) {
      _done(value["result"].toString(), value["error"],
          isIN ? 'emp_In' : 'emp_Out', dayTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    noteDialog(String dayTime, DateTime day, bool isIN) {
      TextEditingController _c = new TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.only(top: 15, left: 10, right: 10),
              height: 150,
              child: Container(
                child: new Column(
                  children: <Widget>[
                    new TextField(
                      decoration: new InputDecoration(
                          hintText: "${arEn('ملاحظات', 'Notes')}"),
                      controller: _c,
                    ),
                    ButtonBar(
                      children: <Widget>[
                        greenOK('${arEn('حفظ', 'save')}',
                            () async => doSave(dayTime, _c.text, isIN)),
                        greenCancel('${arEn('الغاء', 'Cancel')}',
                            () => Navigator.pop(context))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.only(right: 10, top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Icon(
                Icons.access_alarms,
                size: 25,
              ),
              Text(
                '  ${dateFormat2.format(day)}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fSize(4)),
              ),
            ],
          ),
          ButtonBar(
            children: [
              it
                  ? redCancel('${arEn('تسجيل دخول', 'Login')}', () {
                      showTimePicker(
                        useRootNavigator: false,
                        context: context,
                        initialTime: TimeOfDay(hour: 8, minute: 0),
                      ).then((TimeOfDay? value) {
                        if (value != null) {
                          DateTime startTime = MyDateUtils(day)
                              .copyWith(
                                  hour: 0,
                                  minute: 0,
                                  second: 0,
                                  microsecond: 0,
                                  millisecond: 0)
                              .add(new Duration(hours: 0));
                          startTime = MyDateUtils(startTime)
                              .copyWith(hour: value.hour, minute: value.minute);

                          String dayTime = timeFormat24.format(startTime);
                          noteDialog(dayTime, startTime, true);
                        }
                      });
                    })
                  : TextButton(
                      child: Text(
                          '${arEn('دخول', 'Start')} : ${widget.data["emp_In"]}'),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(transparent),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(black),
                      ),
                      onPressed: null,
                    ),
              ot
                  ? redCancel('${arEn('تسجيل خروج', 'Leave')}', () {
                      showTimePicker(
                        useRootNavigator: false,
                        context: context,
                        initialTime: TimeOfDay(hour: 8, minute: 0),
                      ).then((TimeOfDay? value) {
                        if (value != null) {
                          DateTime startTime = MyDateUtils(day)
                              .copyWith(
                                  hour: 0,
                                  minute: 0,
                                  second: 0,
                                  microsecond: 0,
                                  millisecond: 0)
                              .add(new Duration(hours: 0));
                          startTime = MyDateUtils(startTime)
                              .copyWith(hour: value.hour, minute: value.minute);

                          String dayTime = timeFormat24.format(startTime);
                          noteDialog(dayTime, startTime, false);
                        }
                      });
                    })
                  : TextButton(
                      child: Text(
                          '${arEn('خروج', 'Exit')} : ${widget.data["emp_Out"]}'),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(transparent),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(black),
                      ),
                      onPressed: null,
                    ),
            ],
          )
        ],
      ),
    );
  }
}
