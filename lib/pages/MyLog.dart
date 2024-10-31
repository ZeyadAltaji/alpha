import 'dart:convert';
import 'package:badges/badges.dart' as badges ;
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class MyLogPage extends StatefulWidget {
  @override
  _MyLogPageState createState() => _MyLogPageState();
}

List<KeyListValue> detailsList = [];

class _MyLogPageState extends State<MyLogPage> {
  @override
  void initState() {
    super.initState();
    detailsList = [];
  }

  @override
  void dispose() {
    detailsList = [];
    super.dispose();
  }

  Color getColor(int requestType, int stat) {
    if (requestType == 123 && stat == 3) {
      stat = -1;
    }
    if (stat < 0) {
      return Colors.red;
    }
    if (stat == 1 || stat == 0) {
      return Colors.grey;
    }
    if (stat > 1) {
      return Colors.green;
    }
    return Colors.transparent;
  }

  Widget statuso(int requestType, int stat) {
    if (requestType == 123 && stat == 3) {
      stat = -1;
    }
    if (stat < 0) {
      return Text(
        trans.rejected.toUpperCase(),
        style: TextStyle(fontSize: fSize(0)),
      );
    }
    if (stat == 1 || stat == 0) {
      return Text(
        trans.pending.toUpperCase(),
        style: TextStyle(fontSize: fSize(0)),
      );
    }
    if (stat > 1) {
      return Text(
        trans.approved.toUpperCase(),
        style: TextStyle(fontSize: fSize(0)),
      );
    }
    return Text(
      '',
      style: TextStyle(fontSize: fSize(0)),
    );
  }

  Future<List?> getDetails(LogRecord log) async {
    int? requestType = log.requestType == 123 ? 1 : log.requestType;
    if (detailsList
            .where((x) =>
                x.compNo == me?.compNo &&
                x.requestType == requestType &&
                x.vRSerial == log.vRSerial)
            .length >
        0) {
      return detailsList
          .where((x) =>
              x.compNo == me?.compNo &&
              x.requestType == requestType &&
              x.vRSerial == log.vRSerial)
          .first
          .data;
    }

    var body = {
      "CompNo": "${me?.compNo}",
      "VR_Serial": "${log.vRSerial}",
      "RequestType": "$requestType",
      "pn": "HRP_Mobile_GetWorkFlowDetail",
    };

    var _baseUrl = Uri.parse('$myProtocol$serverURL/General');
    var res = await http.post(_baseUrl, headers: headers, body: body);
    if (res.statusCode == 200) {
      var d = json.decode(res.body);
      List sdM = d["result"];
      detailsList.add(new KeyListValue(
        compNo: me?.compNo,
        requestType: requestType,
        vRSerial: log.vRSerial,
        data: sdM,
      ));
      return sdM;
    }
    return [];
  }

  IconData icon(List<dynamic> data, int i) {
    int c = data
        .where((x) =>
            x['levelNumber'] == i &&
            x['action'].toString().toLowerCase().trim() == 'c')
        .length;
    if (c > 0) return Icons.check;
    return Icons.access_time;
  }

  Color getCardColor(List<dynamic> data, int i) {
    int c = data
        .where((x) =>
            x['levelNumber'] == i &&
            x['action'].toString().toLowerCase().trim() == 'c')
        .length;
    if (c > 0) return Colors.green[700]!;
    return Colors.grey;
  }

  double getHeight(List<dynamic> l) {
    int a = 1;
    for (int i = 0; i < 1500; i++) {
      if (l.where((x) => x['levelNumber'] == i).length > a)
        a = l.where((x) => x['levelNumber'] == i).length;
    }
    if (a == 1)
      a = a * 60;
    else
      a = a * 35;
    return double.parse('$a');
  }

  Widget myDetail(LogRecord log) {
    if (log.statusWF == 1 || log.statusWF == 0) {
      return FutureBuilder(
          future: getDetails(log),
          builder: (context, s) {
            if (s.hasData) {
              List? data = s.data as List?;
              data!.sort((a, b) => a['levelNumber'].compareTo(b['levelNumber']));
              if (data.length == 0) return SizedBox();
              int maxLevel = data.last['levelNumber'];
              if (data.length == 0) {
                return Container();
              }
              return Directionality(
                textDirection: direction,
                child: Container(
                  width: width,
                  height: getHeight(data),
                  child: ListView.builder(
                    shrinkWrap: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: maxLevel,
                    controller:
                        PageController(viewportFraction: 0.5, keepPage: true),
                    itemBuilder: (_, i) {
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: getCardColor(data, i + 1),
                                ),
                              ),
                              child: badges.Badge(
                                position: badges.BadgePosition.topStart( top: -5,start: -5),
                                badgeStyle: badges.BadgeStyle(
                                badgeColor: getCardColor(data, i + 1),
                                padding: EdgeInsets.all(2),
                                
                                ),
                                badgeContent: Icon(
                                  icon(data, i + 1),
                                  size: 15,
                                  color: white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var item in data
                                          .where(
                                              (x) => x['levelNumber'] == i + 1)
                                          .toList())
                                        Text(
                                            '${arEn(item['arabic'], item['english'])}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          i < maxLevel - 1
                              ? Container(
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey,
                                  ),
                                )
                              : Container(
                                  child: Icon(
                                    Icons.thumb_up,
                                    color: Colors.grey,
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                ),
              );
            } else if (s.hasError) {
              return Center(child: Text("${s.error}"));
            }
            return SpinKitThreeBounce(
              color: primaryColor,
              size: 30,
            );
          });
    }
    return SizedBox();
  }

  List<LogRecord> records = [];
  int vRSerial = 0;
  int index2 = 0;
  Future<void> cancelRequest() async {
    new Dialogs(
      context,
      _doCancel,
      trans.arEn('الغاء الطلب', 'Cancel request'),
      trans.arEn(
          'هل تريد الغاء هذا الطلب ؟', 'Do you want to cancel this request?'),
      true,
    ).yesOrNo();
  }

  Future<void> _doCancel(bool ok) async {
    if (!ok) return;
    wait(context);

    await db.excute('DeleteLeave', {
      "CompNo": me?.compNo.toString(),
      "EmpNo": me?.empNum.toString(),
      "VR_Serial": '$vRSerial',
    }).then((dynamic value) {
      _done(
        translate('${value["result"]}'),
        value["error"],
      );
    });
  }

  void _done(String msg, bool error) async {
    done(context);
    new Future.delayed(new Duration(seconds: 0), () async {
      return await showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) => error
            ? errorDialog(msg)
            : successDialog(
                msg,
              ),
      ).then((
        value,
      ) {
        if (!error) {
          setState(() {
            records.removeAt(index2);
          });
        }
      });
    });
  }

  Container babyCard(LogRecord log, int index) {
    return Container(
      child: Card(
        elevation: 4,
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.rotate(
                        angle: 18 * (22 / 7) / 90,
                        child: Icon(
                          Icons.star_border,
                          size: 15,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        arEn(log.descAr!, log.descEn!.toUpperCase()),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  badges.Badge(
                    position: badges.BadgePosition.topEnd(top: 5, end: 0),

                    badgeStyle: badges.BadgeStyle(
                    badgeColor: getColor(log.requestType!, log.statusWF!),
                    ),
                     badgeAnimation: badges.BadgeAnimation.rotation(
                      animationDuration: Duration(seconds: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: gLang == "1"
                          ? statuso(log.requestType!, log.statusWF!)
                          : statuso(log.requestType!, log.statusWF!),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          trans.arEn('تاريخ التقديم', 'Submission date') +
                              ' : ${dateFormat2.format(log.transDate!)}',
                          style: TextStyle(fontSize: fSize(2)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: width * 0.85,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${log.notes}',
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontSize: fSize(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          trans.arEn('ملاحظات', 'Notes') +
                              ' : ${truncate(log.requeridNote!, 40)}',
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: fSize(2)),
                        ),
                      ],
                    ),
                    (log.requestType == 123 && log.statusWF == 3 ||
                            log.statusWF == -1)
                        ? Row(
                            children: [
                              Text(
                                trans.arEn('سبب الرفض', 'Refuse reason ') +
                                    ' : ${log.rejected}',
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: fSize(2)),
                              ),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              myDetail(log),
              // ButtonBar(
              //   children: [
              //     (log.requestType! == 123 && log.statusWF! == 1 ||
              //             log.requestType == 123 && log.statusWF == 2)
              //         ? new TextButton(
              //             style: ButtonStyle(
              //               backgroundColor: WidgetStateProperty.all<Color>(
              //                   Colors.transparent),
              //               overlayColor: WidgetStateProperty.all<Color>(
              //                   Color(0xffecb1c5)), //splash
              //               foregroundColor: WidgetStateProperty.all<Color>(
              //                   Color(0xffbf2056)),
              //             ),
              //             child: Text(
              //               trans.arEn('الغاء الطلب', 'Cancel request'),
              //               style: TextStyle(fontSize: fSize(2)),
              //             ),
              //             onPressed: () {
              //               vRSerial = log.vRSerial!;
              //               index2 = index;
              //               cancelRequest();
              //             })
              //         : getColor(log.requestType, log.statusWF) == Colors.grey
              //             ? new TextButton(
              //                 style: ButtonStyle(
              //                   backgroundColor:
              //                       WidgetStateProperty.all<Color>(
              //                           Colors.transparent),
              //                   overlayColor: WidgetStateProperty.all<Color>(
              //                       Color(0xffecb1c5)), //splash
              //                   foregroundColor:
              //                       WidgetStateProperty.all<Color>(
              //                           Color(0xffbf2056)),
              //                 ),
              //                 child: Text(
              //                   trans.arEn('الغاء الطلب', 'Cancel request'),
              //                   style: TextStyle(fontSize: fSize(2)),
              //                 ),
              //                 onPressed: () async {
              //                   new Dialogs(context, (bool r) async {
              //                     if (r == true) {
              //                       await http.post(
              //                         Uri.parse(
              //                             '$myProtocol$serverURL/General'),
              //                         headers: headers,
              //                         body: {
              //                           "CompNo": '${me?.compNo}',
              //                           "VR_Serial": '${log.vRSerial}',
              //                           "RequestType":
              //                               "${log.requestType == 123 ? 1 : log.requestType}",
              //                           "pn": "HRP_Web_DelRequestId"
              //                         },
              //                       ).then(
              //                         (value) {
              //                           setState(() {});
              //                         },
              //                       );
              //                     }
              //                   },
              //                           arEn('الغاء الطلب', 'Cancel request'),
              //                           arEn('هل تريد حقاً الغاء هذا الطلب ؟',
              //                               'Do you really want to cancel this request?'),
              //                           true)
              //                       .yesOrNo();
              //                 })
              //             : null,
              //   ],
              OverflowBar(
                children: [
                  (log.requestType! == 123 && log.statusWF! == 1 ||
                          log.requestType == 123 && log.statusWF == 2)
                      ? TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            overlayColor: MaterialStateProperty.all<Color>(
                                Color(0xffecb1c5)), // splash
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffbf2056)),
                          ),
                          child: Text(
                            trans.arEn('الغاء الطلب', 'Cancel request'),
                            style: TextStyle(fontSize: fSize(2)),
                          ),
                          onPressed: () {
                            vRSerial = log.vRSerial!;
                            index2 = index;
                            cancelRequest();
                          },
                        )
                      : getColor(log.requestType!, log.statusWF!) == Colors.grey
                          ? TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                                overlayColor: MaterialStateProperty.all<Color>(
                                    Color(0xffecb1c5)), // splash
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xffbf2056)),
                              ),
                              child: Text(
                                trans.arEn('الغاء الطلب', 'Cancel request'),
                                style: TextStyle(fontSize: fSize(2)),
                              ),
                              onPressed: () async {
                                new Dialogs(context, (bool r) async {
                                  if (r == true) {
                                    await http.post(
                                      Uri.parse(
                                          '$myProtocol$serverURL/General'),
                                      headers: headers,
                                      body: {
                                        "CompNo": '${me?.compNo}',
                                        "VR_Serial": '${log.vRSerial}',
                                        "RequestType":
                                            "${log.requestType == 123 ? 1 : log.requestType}",
                                        "pn": "HRP_Web_DelRequestId"
                                      },
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  }
                                },
                                        arEn('الغاء الطلب', 'Cancel request'),
                                        arEn('هل تريد حقاً الغاء هذا الطلب ؟',
                                            'Do you really want to cancel this request?'),
                                        true)
                                    .yesOrNo();
                              },
                            )
                          : Container(),
                ],

              )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> callAsyncFetch() async {
    var body = {
      "CompNo": me?.compNo.toString(),
      "empNo": me?.empNum.toString(),
      "Lang": gLang,
    };
    String _baseUrl = Uri.encodeFull('$myProtocol$serverURL/MyLog');
    var res =
        await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes));
    }
    return null;
  }

  FutureBuilder loadData() {
    return FutureBuilder(
      future: callAsyncFetch(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          Iterable list = snapshot.data["result"];
          if (list.length == 0) return noData;
          records = list.map((model) => LogRecord.map(model)).toList();
          return Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(colors: [
                primaryColor.withOpacity(0.01),
                primaryColor.withOpacity(0.01),
              ]),
            ),
            //padding: EdgeInsets.only(bottom: 50),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              itemCount: records.length,
              itemBuilder: (context, index) {
                return babyCard(records[index], index);
              },
              // separatorBuilder: (context, index) {
              //   return Divider(
              //     color: Colors.transparent,
              //   );
              // },
            ),
          );
        }
        return Center(
          child: circular,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: trans.direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(title: trans.drawer4),
        body: loadData(),
        //bottomSheet: ad16,
      ),
    );
  }
}
