import 'dart:convert';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/DateButton.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<_GetListState> _getListState = GlobalKey<_GetListState>();
final GlobalKey<_ComboState> _comboState = GlobalKey<_ComboState>();
final GlobalKey<_ComboState> _comboState0 = GlobalKey<_ComboState>();

class InOutLog2 extends StatefulWidget {
  @override
  _InOutLogState createState() => _InOutLogState();
}

List? data_;

class _InOutLogState extends State<InOutLog2> {
  @override
  void initState() {
    super.initState();
    data_ = [];
  }

  Future<dynamic> xx() async {
    if (me == null) return;
    if (data_!.isNotEmpty) return data_;

    var res = await http.post(
      Uri.parse('$myProtocol$serverURL/General'),
      headers: headers,
      body: {
        "CompNo": '${me?.compNo}',
        "SupervisorID": '${me?.empNum}',
        "pn": "HRP_Mobile_GetStampAllUsers"
      },
    );
    if (res.statusCode == 200) {
      dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
      List data = snapshot["result"];
      data_ = data;
      setState(() {});
      return data;
    }
    return null;
  }

  int fromEmpNum = 0;
  int toEmpNum = 0;
  DateTime fromDate = now.copyWith(day: 1);
  DateTime toDate = now;
  bool selectAll = false;
  @override
  Widget build(BuildContext context) {
    void dosearch() async {
      wait(context);
      Uri _baseUrl = Uri.parse('$myProtocol$serverURL/general');
      dynamic body = {
        "CompNo": '${me?.compNo}',
        "SupervisorID": '${me?.empNum}',
        'fromEmpNum': '$fromEmpNum',
        "toEmpNum": "$toEmpNum",
        "fromDate": "${dateFormat.format(fromDate)}",
        "toDate": "${dateFormat.format(toDate)}",
        "pn": "HRP_Mobile_FingerPrintsLog3"
      };
      final response = await http.post(
        _baseUrl,
        headers: headers,
        body: body,
      );
      done(context);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        List jsonResponse = result["result"];
        _getListState.currentState!.doSearch(jsonResponse);
      }
    }

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(
          title: '${arEn('سجل تسجيل الدوام', 'Time recording log')}',
          actions: [
            IconButton(
              icon: Icon(
                Icons.group,
                color: white,
              ),
              onPressed: () async {
                setState(() {
                  if (byDateGroup == false) {
                    byDateGroup = true;
                  } else {
                    byDateGroup = false;
                  }
                });
                var preferences = await SharedPreferences.getInstance();
                preferences.setBool('byDateGroup', byDateGroup);
                dosearch();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
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
                        Text(arEn('من موظف : ', 'From emp : ')),
                        Expanded(
                          child: Directionality(
                            textDirection: direction,
                            child: data_!.isNotEmpty
                                ? Combo(
                                    selectLast: false,
                                    key: _comboState0,
                                    data: data_!,
                                    onChange: (int x) {
                                      if (fromEmpNum != x) fromEmpNum = x;
                                    },
                                  )
                                : Center(
                                    child: SpinKitRipple(
                                      color: Colors.black,
                                      size: 30.0,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(arEn('الى موظف : ', 'To emp : ')),
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
                                      selectLast: true,
                                      key: _comboState,
                                      data: snapshot.data,
                                      onChange: (int x) {
                                        if (toEmpNum != x) toEmpNum = x;
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
                            dosearch();
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
  final bool? selectLast;
  const Combo({Key? key, this.data, this.onChange, this.selectLast})
      : super(key: key);
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
    if (selected == null)
      selected = widget.selectLast! ? widget.data!.last : widget.data!.first;
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
            child: Text(arEn("${value['empName']}", "${value['empEngName']}")),
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
  List<String> lst = [];
  List<String> lstValues = [];
  void doSearch(List d) {
    data = d;
    if (d.length > 0) {
      lst.clear();
      lstValues.clear();
      for (var dc in d) {
        if (!lst.contains("${dc['empNo']}") && !byDateGroup) {
          lst.add("${dc['empNo']}");
          lstValues.add(arEn("${dc['empName']}", "${dc['empEngName']}"));
        }
        if (!lst.contains("${dc['date']}") && byDateGroup) {
          lst.add("${dc['date']}");
          lstValues.add("${dc['date']}");
        }
      }
    }
    setState(() {});
  }

  List ?data;
  @override
  Widget build(BuildContext context) {
    if (data == null || data!.length == 0) return Container();
    return Builder(
      builder: (context) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: lst.length,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              child: Column(
                children: [
                  Container(
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    height: 25,
                    child: Center(child: Text(lstValues[i])),
                  ),
                  byDateGroup
                      ? Column(
                          children: [
                            for (var item in data!.where((e) =>
                                e['date'].toString().trim() ==
                                lst[i].toString().trim()))
                              Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(arEn(
                                        item['empName'], item['empEngName'])),
                                  )),
                                  Container(
                                      width: 50, child: Text(item['checkIn'])),
                                  Container(
                                      width: 50, child: Text(item['checkOut'])),
                                ],
                              )
                          ],
                        )
                      : Column(
                          children: [
                            for (var item in data!.where((e) =>
                                e['empNo'].toString().trim() ==
                                lst[i].toString().trim()))
                              Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(item['date']),
                                  )),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                        arEn(item['dayAr'], item['dayEn'])),
                                  )),
                                  Container(
                                      width: 50, child: Text(item['checkIn'])),
                                  Container(
                                      width: 50, child: Text(item['checkOut'])),
                                ],
                              )
                          ],
                        )
                ],
              ),
            );

            // return Container(
            //   child: Directionality(
            //     textDirection: TextDirection.ltr,
            //     child: Row(
            //       children: [
            //         Expanded(
            //           child: Directionality(
            //             textDirection: direction,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //               children: [
            //                 Text(
            //                   g['date'],
            //                   style: TextStyle(fontSize: fSize(0)),
            //                 ),
            //                 Text(
            //                   g['empName'],
            //                   style: TextStyle(fontSize: fSize(0)),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // );
          },
        );
      },
    );
  }
}
