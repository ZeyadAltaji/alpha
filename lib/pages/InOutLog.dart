import 'dart:convert';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Check.dart';
import 'package:alpha/GeneralFiles/DateButton.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class InOutLog extends StatefulWidget {
  @override
  _InOutLogState createState() => _InOutLogState();
}

class _InOutLogState extends State<InOutLog> {
final GlobalKey<_ComboState> _comboState = GlobalKey<_ComboState>();
final GlobalKey<_GetListState> _getListState = GlobalKey<_GetListState>();

  Future<dynamic> xx() async {
  try{
      if (me == null) return;
    var res = await http.post(
      Uri.parse('$myProtocol$serverURL/General'),
      headers: headers,
      body: {
        "CompNo": '${me?.compNo}',
        "empNum": '${me?.empNum}',
        "pn": "HRP_Mobile_GetStampUsers"
      },
    );
    if (res.statusCode == 200) {
      dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
      List data = snapshot["result"] ?? [];
      print (data);

      return data;
    }
    return null;
  }catch(ex){
    throw ex;
  }
  }

  int empNum = 0;
  DateTime fromDate = now.copyWith(day: 1);
  DateTime toDate = now;
  
  bool selectAll = false;
  @override
  Widget build(BuildContext context) {
    print(context);
                            print(fromDate);
                            print(toDate);

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        // bottomNavigationBar: AdPage(),
        appBar: appBar(
            title: '${arEn('اعتماد الدخول والخروج', 'Confirm log in and out')}',
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                  overlayColor: WidgetStateProperty.all<Color>(
                      Colors.transparent), //splash
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                child: Text('${arEn('اعتماد', 'Approve')}'),
                onPressed: () {
                  _getListState.currentState?.doRegister();
                },
              )
            ]),
        body: Column(
          children: [
            Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(colors: [
                  primaryColor,
                  primaryColor,
                ]),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 130,
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
                  Expanded(
                    child: Row(
                      children: [
                        Check(
                          value: false,
                          onChanged: (value) {
                            if (selectAll) {
                              selectAll = false;
                            } else {
                              selectAll = true;
                            }
                            _getListState.currentState?.selectAll(selectAll);
                          },
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: direction,
                            child: FutureBuilder(
                              future: xx(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData &&
                                    snapshot.data != null) {
                                  if (snapshot.data != null) {
                                    return Combo(
                                      key: _comboState,
                                      data: snapshot.data,
                                      onChange: (int x) {
                                        if (empNum != x) empNum = x;
                                      },
                                    );
                                  } else {
                                    return Text(
                                        '${arEn('خطأ في التحميل', 'Loading error')}');
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
                        ),
                        Button(
                          onPressed: () async {
                           try{
                             Uri _baseUrl =
                                Uri.parse('$myProtocol$serverURL/general');
                            dynamic body = {
                              "CompNo": '${me?.compNo}',
                              'empNum': '$empNum',
                              "adminNum": "${me?.empNum}",
                              "fromDate": "${dateFormat.format(fromDate)}",
                              "toDate": "${dateFormat.format(toDate)}",
                              "pn": "HRP_Mobile_FingerPrintsLog2"
                            };
                            final response = await http.post(
                              _baseUrl,
                              headers: headers,
                              body: body,
                            );

                            if (response.statusCode == 200) {
                              var result = json.decode(response.body);
                              List jsonResponse = result["result"];
                              print(jsonResponse);
                              _getListState.currentState!
                                  .doSearch(jsonResponse, empNum);
                            }
                           }catch(ex){
                            throw ex;
                           }
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
              child: GetList(
                key: _getListState,
              ),
            ),
          ],
        ),
        //bottomSheet: ad12,
      ),
    );
  }
}

 

class Combo extends StatefulWidget {
  final List? data;
  final ValueChanged<int>? onChange;
  const Combo({Key? key, this.data, this.onChange}) : super(key: key);
  @override
  _ComboState createState() => _ComboState();
}

class _ComboState extends State<Combo> {
  dynamic selected;
  @override
  Widget build(BuildContext context) {
    if (widget.data!.length == 0) {
      return Text('${arEn('لا يوجد موظفين', 'There are no employees')}');
    }
    if (selected == null) selected = widget.data!.first;
    widget.onChange!(selected["empNum"]);
    return DropdownButton<dynamic>(
      value: selected,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      underline: Container(
        height: 0,
      ),
      onChanged: (dynamic newValue) {
        setState(() {
          selected = newValue;
          widget.onChange!(selected["empNum"]);
        });
      },
      items: widget.data!.map(
        (dynamic value) {
          return DropdownMenuItem<dynamic>(
            value: value,
            child: Text("${value['empName']}"),
          );
        },
      ).toList(),
    );
  }
}

class GetList extends StatefulWidget {
  const GetList({Key? key}) : super(key: key);
  @override
  _GetListState createState() => _GetListState();
}

class _GetListState extends State<GetList> {
  int empNum = 0;

  void doSearch(List d, int cc) {
    empNum = cc;
    data = d;
    setState(() {});
  }

  void selectAll(bool m) {
    if (data == null) return;
    for (var s in data!) {
      s['checked'] = m;
    }
    setState(() {});
  }

  Future<void> doRegister() async {
    if (data!.length == 0) return;
    if (data!.where((x) => x['checked']).length == 0) {
      toast(
          '${arEn('يجب تحديد حقل واحد على الاقل', 'At least one field must be selected')}');
      return;
    }

    new Dialogs(
            context,
            saveDone,
            '${arEn('اعتماد', 'Approve')}',
            '${arEn('هل تريد اعتماد هذه الادخالات ؟', 'Do you want to approve these entries?')}',
            false)
        .yesOrNo();
  }

  Future<void> saveDone(bool done) async {
    if (done) {
      var t = [];
      for (var s in data!) {
        if (s["checked"]) {
          t.add(s['id']);
        }
      }
     try{
       Uri _baseUrl = Uri.parse('$myProtocol$serverURL/general');
      dynamic body = {
        "CompNo": '${me?.compNo}',
        "empNum": "$empNum",
        "stamps": "${t.toString().replaceAll('[', '').replaceAll(']', '')}",
        "pn": "HRP_Mobile_ApproveStamp"
      };
      final response = await http.post(
        _baseUrl,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        toast(result["result"][0]['r']);
        doSearch(data!.where((c) => !c['checked']).toList(), empNum);
      }
     } catch(ex){
        throw ex;
     }
    }
  }

  List? data;
  @override
  Widget build(BuildContext context) {
    if (data == null || data!.length == 0) return Container();
    return Builder(
      builder: (context) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: data!.length,
          itemBuilder: (BuildContext context, int i) {
            var g = data![i];
            return Container(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: CheckboxListTile(
                  selected: (g["checked"]),
                  title: Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: direction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                g['date'],
                                style: TextStyle(fontSize: fSize(0)),
                              ),
                              Text(
                                g['time'],
                                style: TextStyle(fontSize: fSize(0)),
                              ),
                              TextButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          primaryColor.withOpacity(0.2)),
                                ),
                                icon: (g['checkIn'] == 1)
                                    ? Icon(Icons.arrow_downward,
                                        color: g['checked']
                                            ? Colors.green
                                            : Colors.black)
                                    : Icon(Icons.arrow_upward,
                                        color: g['checked']
                                            ? Colors.green
                                            : Colors.black),
                                label: Text(
                                  g['checkIn'] == 1
                                      ? '${arEn('دخول', 'Entry')}'
                                      : '${arEn('خروج', 'Exit')}',
                                  style: TextStyle(
                                    color: g['checked']
                                        ? Colors.green
                                        : Colors.black,
                                    fontSize: fSize(0),
                                  ),
                                ),
                                onPressed: () async {
                                  await launchUrl(Uri.parse(
                                      'https://maps.google.com/maps?q=${g['latitude']}%2C${g['longitude']}&z=17&hl=ar'));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  value: (g['checked'] ??
                      false), // Default to false if g['checked'] is null
                  onChanged: (val) {
                    setState(() {
                      g['checked'] =
                          val ?? false; // Set to false if val is null
                    });
                  },

                  activeColor: Colors.green,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
