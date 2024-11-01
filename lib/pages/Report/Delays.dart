import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/DateButton.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class Delays extends StatefulWidget {
  const Delays({Key? key}) : super(key: key);

  @override
  State<Delays> createState() => _DelaysState();
}

DateTime fDate = now;
DateTime tDate = now;
bool fire = false;

class _DelaysState extends State<Delays> {
  @override
  void initState() {
    super.initState();
    fDate = now;
    tDate = now;
    if (delaysData == null)
      fire = false;
    else
      fire = true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: gLang != "1" ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: appBar(
            title: '',
            actions: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            delaysData = null;
                            fire = true;
                            setState(() {});
                          },
                          icon: Icon(Icons.search)),
                      DateButton(
                        date: tDate,
                        onchange: (d) {
                          tDate = d;
                        },
                      ),
                      Text(arEn('الى', 'To')),
                      DateButton(
                        date: fDate,
                        onchange: (d) {
                          fDate = d;
                        },
                      ),
                      Text(arEn('من', 'From')),
                    ],
                  ),
                ),
              ),
            ],
            back: false),
        body: fire
            ? FutureBuilder(
                future: getAbsences(fDate, tDate),
                builder: (context, s) {
                  if (s.connectionState == ConnectionState.done && s.hasData) {
                    Iterable list = s.data as Iterable;
                    return AbsenceCore(
                      list: list,
                      onRefresh: (b) {
                        fire = true;
                        delaysData = null;
                        setState(() {});
                      },
                    );
                  }
                  return Center(
                    child: circular,
                  );
                })
            : Container(),
      ),
    );
  }
}

class AbsenceCore extends StatefulWidget {
  final Iterable<dynamic>? list;
  final Function(bool)? onRefresh;
  const AbsenceCore({Key? key, this.list, this.onRefresh}) : super(key: key);

  @override
  State<AbsenceCore> createState() => _AbsenceCoreState();
}

class _AbsenceCoreState extends State<AbsenceCore> {
  @override
  Widget build(BuildContext context) {
    List<String> bus = [];
    for (var item in widget.list!) {
      bus.add(arEn(item['wplace'], item['wplaceEng']));
    }
    bus = bus.toSet().toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var bu in bus)
            Column(
              children: [
                Directionality(
                  textDirection:
                      gLang == "1" ? TextDirection.rtl : TextDirection.ltr,
                      child: ExpansionTileCard(
                    baseColor:
                        darkTheme ? Colors.white : Colors.grey,
                    expandedColor:  darkTheme ? Color(0xffdb5a5a) : Color(0xffEBEDEF),
                    leading: CircleAvatar(
                      foregroundColor: darkTheme ? Colors.white : Colors.grey,
                      backgroundColor:
                          darkTheme ? Color(0xffdb5a5a) : Color(0xffEBEDEF),
                      child: Text(
                        '${widget.list!.where((x) => arEn(x['wplace'], x['wplaceEng']) == bu).length}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: darkTheme ? Colors.grey : Colors.black),
                      child: Container(
                        width: width,
                        child: Text(
                          bu,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  // child: ExpansionCard(
                  //   margin: EdgeInsets.zero,
                  //   leading: CircleAvatar(
                  //     foregroundColor: darkTheme ? Colors.white : Colors.grey,
                  //     backgroundColor:
                  //         darkTheme ? Color(0xffdb5a5a) : Color(0xffEBEDEF),
                  //     child: Text(
                  //       '${widget.list!.where((x) => arEn(x['wplace'], x['wplaceEng']) == bu).length}',
                  //       style: TextStyle(fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  //   title: DefaultTextStyle(
                  //     style: Theme.of(context).textTheme.caption.copyWith(
                  //         color: darkTheme ? Colors.grey : Colors.black),
                  //     child: Container(
                  //       width: width,
                  //       child: Text(
                  //         bu,
                  //         style: TextStyle(fontSize: 12),
                  //       ),
                  //     ),
                  //   ),
                    children: [
                      for (var item in widget.list!.where(
                          (x) => arEn(x['wplace'], x['wplaceEng']) == bu))
                        absBlock(
                          context: context,
                          data: item,
                          onDone: (t) {
                            widget.onRefresh!(t);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

Widget absBlock({BuildContext? context, dynamic data, Function(bool)? onDone}) {
  return Card(
    child: Container(
      // width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                  '  ${data['empNo']}    :   ${arEn(data['empName'], data['empEngName'])}'),
            ],
          ),
          Row(
            children: [
              Text(dayName(DateTime.parse(data['dateT_OUT']))),
              SizedBox(
                width: 15,
              ),
              Text(dateFormat.format(DateTime.parse(data['dateT_OUT']))),
            ],
          ),
          Row(
            children: [
              Text('${arEn('من', 'From')}'),
              Text(' :  '),
              Text(timeFormat.format(DateTime.parse(data['dateT_OUT']))),
              SizedBox(
                width: 15,
              ),
              Text('${arEn('الى', 'To')}'),
              Text(' :  '),
              Text(timeFormat.format(DateTime.parse(data['dateT_IN']))),
            ],
          ),
          Row(
            children: [
              Text(arEn(data['lve_Desc'], data['lve_EngDesc'])),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: data['canRequest'] != 0
                    ? null
                    : () {
                        manage(context!, data['dateT_OUT'], data['empNo'],
                            (bool t) {
                          onDone!(t);
                        });
                      },
                icon: Icon(
                  LineIcons.paperHand,
                ),
              ),
              IconButton(
                onPressed: data['canRequest'] == 0
                    ? null
                    : () {
                        manageDelete(context!, data['fid'], data['empNo'],
                            (bool t) {
                          onDone!(t);
                        });
                      },
                icon: Icon(
                  LineIcons.trash,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () {
                  showCupertinoModalBottomSheet(
                    bounce: false,
                    duration: Duration(milliseconds: 250),
                    context: context!,
                    builder: (BuildContext context) {
                      return AbsenceRequestDetails(
                        empNo: data['empNo'],
                        empName: arEn(data['empName'], data['empEngName']),
                        compNo: data['compNo'],
                        sDate: DateTime.parse(data['dateT_OUT']),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.history,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<List?> getAbsences(DateTime fDate, DateTime tDate) async {
  if (delaysData != null) return delaysData;
  Uri _baseUrl = Uri.parse('$link/General');
  var res = await http.post(
    _baseUrl,
    headers: headers,
    body: {
      "CompNo": "${me!.compNo}",
      "FromDate": "${dateFormat.format(fDate)}",
      "ToDate": "${dateFormat.format(tDate)}",
      "FromShift": "1",
      "ToShift": "99999",
      "Level": "1",
      "FromEmp": "1",
      "ToEmp": "99999",
      "FromLeave": "1",
      "ToLeave": "99999",
      "FromId": "1",
      "ToId": "99999",
      "OrdByEmp": "0",
      "UserID": "${me!.empNum}",
      "pn": "HRP_Mobile_Delays",
    },
  );
  if (res.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
    List data = snapshot["result"];
    delaysData = data;
    return data;
  }
  return null;
}

Future<List?> getAbsencesHistory(DateTime sDate, int empNo) async {
  Uri _baseUrl = Uri.parse('$link/General');
  var res = await http.post(
    _baseUrl,
    headers: headers,
    body: {
      "CompNo": "${me!.compNo}",
      "sDate": "$sDate",
      "EmpNo": "$empNo",
      "Type": "2",
      "pn": "HRP_Mobile_GetAdminRequest",
    },
  );
  if (res.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
    List data = snapshot["result"];

    return data;
  }
  return null;
}

void manage(
    BuildContext context, String sDate, int empNo, Function(bool) onDone) {
  TextEditingController _c = new TextEditingController();
  Future<void> sendPunsh(String sDate, int empNo) async {
    Uri _baseUrl = Uri.parse('$link/General');
    await http.post(
      _baseUrl,
      headers: headers,
      body: {
        "CompNo": "${me!.compNo}",
        "SDate": "$sDate",
        "EmpNo": "$empNo",
        "Comment": _c.text,
        "Admin": "${me!.empNum}",
        "Type": "2",
        "pn": "HRP_Mobile_Punishment",
      },
    );
  }

  showDialog(
    barrierColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Directionality(
          textDirection: direction,
          child: AlertDialog(
            elevation: 10,
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Container(
              padding: EdgeInsets.only(right: 30, top: 10, left: 30),
              child: Text(
                'ملاحظة',
                style: TextStyle(fontSize: fSize(7)),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            content: Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: width,
                        child: Text('يرجى كتابة التعليمات'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        textDirection: direction,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            border: new OutlineInputBorder(),
                            hintText: 'اكتب هنا'),
                        controller: _c,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Directionality(
                textDirection:
                    gLang == "1" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      redOK('${arEn('ارسال', 'Send')}', () {
                        sendPunsh(sDate, empNo).then((value) {
                          onDone(true);
                        });
                        Navigator.pop(context);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                      redCancel('${arEn('الغاء', 'Cancel')}', () {
                        Navigator.pop(context);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void manageDelete(
    BuildContext context, int fid, int empNo, Function(bool) onDone) {
  TextEditingController _c = new TextEditingController();
  Future<void> DeletePunsh(int fid, int empNo) async {
    Uri _baseUrl = Uri.parse('$link/General');
    await http.post(
      _baseUrl,
      headers: headers,
      body: {
        "CompNo": "${me!.compNo}",
        "FId": "$fid",
        "EmpNo": "$empNo",
        "pn": "HRP_Mobile_DeletePunishment",
      },
    );
  }

  showDialog(
    barrierColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Directionality(
          textDirection: direction,
          child: AlertDialog(
            elevation: 10,
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Container(
              padding: EdgeInsets.only(right: 30, top: 10, left: 30),
              child: Text(
                trans.arEn('الغاء الطلب', 'Cancel request'),
                style: TextStyle(fontSize: fSize(7)),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            content: Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: width,
                        child: Text(trans.arEn('هل تريد الغاء هذا الطلب ؟',
                            'Do you want to cancel this request?')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Directionality(
                textDirection:
                    gLang == "1" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      redOK('${arEn('الغاء', 'Cancel')}', () {
                        DeletePunsh(fid, empNo).then((value) {
                          onDone(true);
                        });
                        Navigator.pop(context);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class AbsenceRequestDetails extends StatefulWidget {
  final int ?compNo;
  final DateTime ?sDate;
  final int ?empNo;
  final String? empName;
  const AbsenceRequestDetails(
      {Key? key, this.compNo, this.empNo, this.sDate, this.empName})
      : super(key: key);

  @override
  State<AbsenceRequestDetails> createState() => _AbsenceRequestDetailsState();
}

class _AbsenceRequestDetailsState extends State<AbsenceRequestDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      child: Scaffold(
        body: FutureBuilder(
            future: getAbsencesHistory(widget.sDate!, widget.empNo!),
            builder: (context, s) {
              if (s.connectionState == ConnectionState.done && s.hasData) {
                Iterable list = s.data as Iterable;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.empName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: darkTheme ? Colors.white : Colors.black,
                            fontFamily: 'TheSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    for (var d in list)
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      d['userName'],
                                    ),
                                    Text(
                                      dtFormat.format(
                                          DateTime.parse(d['createdOn'])),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                      child: Text(
                                    d['comment'],
                                    style: TextStyle(color: Colors.red),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                );
              }
              return Center(
                child: circular,
              );
            }),
      ),
    );
  }
}
// 
// 
// 
// 
// 
// 
// 
// 
// 