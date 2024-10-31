import 'dart:convert';

import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/DateButton.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class WorkFlowReport extends StatefulWidget {
  const WorkFlowReport({Key? key}) : super(key: key);

  @override
  State<WorkFlowReport> createState() => _WorkFlowReportState();
}

enum Action { approved, rejected }
enum RT { off, leave, adv }

class _WorkFlowReportState extends State<WorkFlowReport> {
  DateTime fromDate = now.copyWith(day: 1);
  DateTime toDate = now;

  Action _character = Action.approved;
  RT defrt = RT.off;
  void serach() {
    // if (_character == Action.approved) toast('approved');
    // if (_character == Action.rejected) toast('rejected');
    setState(() {});
  }

  Future<dynamic> xx() async {
    if (me == null) return;
    int requestType = 1;
    if (defrt == RT.leave) requestType = -1;
    if (defrt == RT.adv) requestType = 4;
    var res = await http.post(
      Uri.parse('$myProtocol$serverURL/General'),
      headers: headers,
      body: {
        "CompNo": '${me?.compNo}',
        "Lang": '${arEn('1', '2')}',
        "EmpNo": '${me?.empNum}',
        "RequestType": '$requestType',
        "UserRAction": '${_character == Action.approved ? 'c' : 'r'}',
        "fromDate": '${dateFormat.format(fromDate)}',
        "toDate": '${dateFormat.format(toDate)}}',
        "pn": "HRP_Mobile_WorkFlowHistory"
      },
    );
    if (res.statusCode == 200) {
      dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
      List data = snapshot["result"];

      return data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'سجل الموافقة والرفض'),
      body: Column(
        children: [
          Container(
            // decoration: new BoxDecoration(
            //   gradient: new LinearGradient(colors: [
            //     primaryColor,
            //     primaryColor,
            //   ]),
            // ),
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: 150,
            child: Column(
              children: [
                Expanded(
                    child: Row(
                  children: [
                    Text('${arEn('من', 'From')}'),
                    Expanded(
                      child: DateButton(
                        date: fromDate,
                        onchange: (value) {
                          fromDate = value;
                        },
                      ),
                    ),
                    Text('${arEn('الى', 'to')}'),
                    Expanded(
                      child: DateButton(
                        date: toDate,
                        onchange: (value) {
                          toDate = value;
                        },
                      ),
                    ),
                  ],
                )),
                Container(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            defrt = RT.off;
                          });
                        },
                        child: Row(
                          children: [
                            Radio<RT>(
                              value: RT.off,
                              groupValue: defrt,
                              onChanged: (RT? value) {
                                setState(() {
                                  defrt = RT.off;
                                });
                              },
                            ),
                            Text(arEn('اجازات', 'Vacations')),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            defrt = RT.leave;
                          });
                        },
                        child: Row(
                          children: [
                            Radio<RT>(
                              value: RT.leave,
                              groupValue: defrt,
                              onChanged: (RT? value) {
                                setState(() {
                                  defrt = RT.leave;
                                });
                              },
                            ),
                            Text(arEn('مغادرات', 'Leaves')),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            defrt = RT.adv;
                          });
                        },
                        child: Row(
                          children: [
                            Radio<RT>(
                              value: RT.adv,
                              groupValue: defrt,
                              onChanged: (RT? value) {
                                setState(() {
                                  defrt = RT.adv;
                                });
                              },
                            ),
                            Text(arEn('سلف', 'Advance payment')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _character = Action.approved;
                                });
                              },
                              child: Row(
                                children: [
                                  Radio<Action>(
                                    value: Action.approved,
                                    groupValue: _character,
                                    onChanged: (Action? value) {
                                      setState(() {
                                        _character = Action.approved;
                                      });
                                    },
                                  ),
                                  Text(arEn('موافقة', 'Approved')),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _character = Action.rejected;
                                });
                              },
                              child: Row(
                                children: [
                                  Radio<Action>(
                                    value: Action.rejected,
                                    groupValue: _character,
                                    onChanged: (Action? value) {
                                      setState(() {
                                        _character = value!;
                                      });
                                    },
                                  ),
                                  Text(arEn('مرفوضة', 'Rejected')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Button(
                        onPressed: () async {
                          serach();
                        },
                        text: '${arEn('بحث', 'Search')}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder(
              future: xx(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data != null) {
                  if (snapshot.data != null) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var b in snapshot.data)
                            Card(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                // height: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(arEn('الطلب : ', 'Type : ')),
                                        Text('${b['tp']}')
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(arEn('التاريخ : ', 'Date : ')),
                                        Text(dateFormat.format(
                                            DateTime.parse(b['addDate']))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(arEn('الموظف : ', 'Employee : ')),
                                        Text(arEn(
                                            b['empName'], b['empEngName'])),
                                      ],
                                    ),
                                    defrt == RT.adv
                                        ? Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(arEn('المبلغ : ',
                                                      'Amount : ')),
                                                  Text(
                                                      "${b['requiredAmount']}"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(arEn('عدد الاشهر : ',
                                                      'Months : ')),
                                                  Text("${b['monthNo']}"),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(arEn('المدة : ',
                                                      'Duration : ')),
                                                  Text("${b['duration']}"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(arEn('العنوان : ',
                                                      'Address : ')),
                                                  Text("${b['address']}"),
                                                ],
                                              ),
                                            ],
                                          ),
                                    Row(
                                      children: [
                                        Text(arEn('ملاحظات : ', 'Notes : ')),
                                        Text("${b['notes']}"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return Text('${arEn('خطأ في التحميل', 'Loading error')}');
                  }
                }
                return Center(
                  child: SpinKitRipple(
                    color: Colors.black,
                    size: 30.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
