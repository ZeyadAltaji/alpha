// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:alpha/data/localdb.dart';
import 'package:alpha/pages/TransPort/TransDetails.dart';
import 'package:alpha/pages/WorkFlow/Generaldetails.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkFlowPage extends StatefulWidget {
  @override
  _WorkFlowPageState createState() => _WorkFlowPageState();
}

class _WorkFlowPageState extends State<WorkFlowPage> {
  Widget recordIcon(int stat) {
    if (stat == -1) {
      return const Icon(Icons.thumb_down);
    }
    if (stat == 1) {
      return const Icon(Icons.timer);
    }
    if (stat == 2) {
      return const Icon(Icons.thumb_up);
    }
    return Text(
      '',
      style: TextStyle(color: Colors.red),
    );
  }

  Widget statuso(int stat) {
    if (stat == -1) {
      return Text(
        '${arEn('مرفوض', 'REJECTED')}',
        style: TextStyle(color: Colors.red),
      );
    }
    if (stat == 1) {
      return Text(
        '${arEn('في الانتظار', 'PENDING')}',
        style: TextStyle(color: Colors.black),
      );
    }
    if (stat == 2) {
      return Text(
        '${arEn('موافق', 'APPROVED')}',
        style: TextStyle(color: Colors.green),
      );
    }
    return Text(
      '',
      style: TextStyle(color: Colors.red),
    );
  }

  final formKey = new GlobalKey<FormState>();
  final GlobalKey expansionTileKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  double? previousOffset;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => loadLog());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadLog() async {
    var body = {
      "CompNo": me?.compNo.toString(),
      "EmpNo": me?.empNum.toString(),
      "Lang": gLang
    };
    String _baseUrl = Uri.encodeFull('$myProtocol$serverURL/notifications');
    var res =
        await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

    if (res.statusCode == 200) {
      dynamic value = json.decode(res.body);
      Iterable d = value["news"];
      news = d.map((m) => new News.map(m)).toList();
      Iterable list = value["result"];
      wFrecords = list.map((model) => WorkFlowRecord.map(model)).toList();
      wFTypes.clear();
      for (var record in wFrecords) {
        wFTypes.add(record.fDescAr!);
      }
      wFTypes = wFTypes.toSet().toList();
      try {
        setState(() {});
      } catch (e) {}
    }
  }

  int iD = 0;
  int requestType = 0;
  Future<void> _dataAction(int approveOrReject, String reject) async {
    //if (approveOrReject == 0) {
    //  if (reject == '') {
    //    toast(
    //        '${arEn('يجب ادخال سبب الرفض', 'The Reject for the vacation must be entered')}');
    //    return;
    //  }
    //}

    wait(context);

    Uri _baseUrl = Uri.parse('$link/General');
    var res = await http.post(
      _baseUrl,
      headers: headers,
      body: {
        "CompNo": '${me?.compNo}',
        "EmpNo": '${me?.empNum}',
        "ID": '$iD',
        "RequestType": '$requestType',
        "ApproveOrReject": '$approveOrReject',
        "Note": '$reject',
        "Substitute": '$substituteId',
        "pn": "HRP_Mobile_WorkFlowAction",
      },
    );
    if (res.statusCode == 200) {
      done(context);
      showSnackBar(context,
          '${arEn('تم تنفيذ الطلب', 'The request has been fulfilled')}');
      setState(() {
        wFrecords.remove(tmp);
        wFTypes.clear();
        for (var record in wFrecords) {
          wFTypes.add(record.fDescAr!);
        }
        setState(() {
          wFTypes = wFTypes.toSet().toList();
          provider.newWF();
        });
      });
    }
  }

  WorkFlowRecord? tmp;

  Future<dynamic> callAsyncFetch(WorkFlowRecord log) async {
    if (log.cache != null) return log.cache;
    var body = {
      "form": log.form,
      "CompNo": "${me?.compNo}", //short CompNo
      "id": "${log.fID}",
      "RequestType": '${log.requestType}',
      "Lang": gLang,
    };
    String _baseUrl =
        Uri.encodeFull('$myProtocol$serverURL/GetRequestHealthServicesBy_Id');
    var res =
        await http.post(Uri.parse(_baseUrl), headers: headers, body: body);
    if (res.statusCode == 200) {
      log.cache = json.decode(utf8.decode(res.bodyBytes));
      return log.cache;
    }
    if (res.statusCode == 500) {
      //
    }
    return null;
  }

  Future<void> prepareFile(Uint8List list, String filen) async {
    wait(context);
    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/' + filen;
    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    OpenFile.open(tempDocumentPath);
    done(context);
  }

  TextEditingController _c = new TextEditingController();
  noteDialog(bool isApproved, int _iD, int _requestType, WorkFlowRecord log) {
    _c.text = tmp!.note!;
    String t = '${arEn('موافقة الطلب', 'Application approval')}';
    String h = '${arEn('ملاحظة', 'Notice')}';
    String m =
        '${arEn('هل تريد حقاً موافقة الطلب ؟', 'Do you really want to approve the request?')}';
    if (!isApproved) {
      t = '${arEn('رفض الطلب', 'Request rejection')}';
      h = '${arEn('سبب الرفض', 'Rejection reason')}';
      m = '${arEn('هل تريد حقاً رفض الطلب ؟', 'Do you really want to reject the request?')}';
    }
    iD = _iD;
    requestType = _requestType;

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
                  t,
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
                          child: Text(m),
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
                              hintText: h),
                          controller: _c,
                        ),
                        if (requestType == 1 &&
                            isApproved &&
                            log.cache["result"]["actionStat"] == 1)
                          rowBlock(
                            label: arEn('البديل : ', 'Substitute : '),
                            child: selectsub,
                          ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: darkTheme ? Colors.black12 : const Color(0xfff3f3f3),
                  ),
                  child: Container(
                    child: Directionality(
                      textDirection:
                          gLang == "1" ? TextDirection.ltr : TextDirection.rtl,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            !isApproved
                                ? redOK('${arEn('رفض', 'Reject')}', () {
                                    Navigator.pop(context);
                                    _dataAction(0, _c.text);
                                  })
                                : greenOK('${arEn('موافقة', 'Approve')}', () {
                                    Navigator.pop(context);
                                    _dataAction(1, _c.text);
                                  }),
                            SizedBox(
                              width: 5,
                            ),
                            !isApproved
                                ? redCancel('${arEn('الغاء', 'Cancel')}', () {
                                    Navigator.pop(context);
                                  })
                                : greenCancel('${arEn('الغاء', 'Cancel')}', () {
                                    Navigator.pop(context);
                                  }),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
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

  FutureBuilder builder(WorkFlowRecord log) {
    return FutureBuilder(
      future: callAsyncFetch(log),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          if (snapshot.data["result"] != null) {
            if ([70, 71].contains(log.requestType))
              return GeneralDetails(data: snapshot.data["result"], log: log);
            if ([80, 81, 16].contains(log.requestType))
              return GeneralDetails(data: snapshot.data["result"], log: log);

            if (log.requestType == 13) {
              List data = snapshot.data["result"];
              if (data.isEmpty)
                return Text(arEn(
                    'خطأ أثناء تحميل التفاصيل', 'error while loading details'));
              var t = data[0];
              double amount = data.fold(0, (sum, item) => sum + item['amount']);
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        '${arEn('نوع الطلب : بدل مواصلات', 'Request type : Transportation allowance')}'),
                    Text(
                      '${arEn('تاريخ الطلب', 'Request date')} :  ${dateFormat2.format(DateTime.parse(t['date']))}',
                      textDirection: TextDirection.ltr,
                    ),
                    Text(
                        '${arEn('قيمة الطلب : ', 'Request amount : ')} ${amount.toStringAsFixed(2)}'),
                    TextButton(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.open_in_new,
                          ),
                          Text('${arEn(' التفاصيل ', ' Details ')}')
                        ],
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.transparent),
                        overlayColor: WidgetStateProperty.all<Color>(
                            Colors.grey.withOpacity(0.2)), //splash
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.grey),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransDetails(
                              details: log.cache,
                              total: amount,
                            ),
                          ),
                        );
                      },
                    )
                  ]);
            }
            Notifications req = Notifications.map(snapshot.data["result"]);
            req.serviceTypeDesc = translate(req.serviceTypeDesc!);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${arEn('تاريخ الطلب', 'Request date')} :  ${req.departureDate}',
                  textDirection: TextDirection.ltr,
                ),
                (log.requestType == 10)
                    ? Text(
                        '${arEn('نوع الطلب', 'Request type')} : ${req.serviceTypeDesc}   >>   ${req.fileName}')
                    : (log.requestType == 1)
                        ? Text(
                            '${arEn('نوع الطلب', 'Request type')} : ${req.vacTypeDesc}')
                        : (log.requestType == 12)
                            ? SizedBox()
                            : Text(
                                '${arEn('نوع الطلب', 'Request type')} : ${req.serviceTypeDesc}'),
                (log.requestType == 1 && log.vacationOrLeave == 1)
                    ? Text(
                        '${arEn('من', 'From')} : ${req.startTime} ${arEn('الى', 'to')} : ${req.endTime}')
                    : SizedBox(),
                (log.requestType == 12)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${arEn('الموظف', 'Employee')} : ${arEn(req.remarksJustification!, req.payEmpDesc!)} '),
                          Text(
                              '${arEn('التاريخ', 'Date')} : ${req.transDate} '),
                          Text(
                              '${arEn('نوع الطلب', 'Request type')} : ${req.serviceTypeDesc}'),
                        ],
                      )
                    : SizedBox(),
                (log.requestType == 1 && log.vacationOrLeave == 0)
                    ? Text(
                        '${arEn('من', 'From')} : ${req.startDate} ${arEn('الى', 'to')} : ${req.endDate}')
                    : SizedBox(),
                (log.requestType == 1)
                    ? Text('${arEn('المدة', 'Duration')} : ${req.routeTo} ')
                    : SizedBox(),
                (log.requestType == 10)
                    ? Text('${arEn('الوقت', 'Time')} : ${req.transTime}')
                    : Text(''),
                (log.form == "finance" && log.requestType != 6)
                    ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                '${arEn('تاريخ التعيين', 'Date of hiring')} : ${req.transDate!.replaceAll('-', '/')}'),
                            Text(
                                '${arEn('الراتب الاساسي', 'basic salary')} : ${req.basic_Salary}'),
                            (log.requestType == 4)
                                ? Text(
                                    '${arEn('عدد الاشهر', 'Number of months')} : ${req.monthNo}',
                                    style: TextStyle(color: Colors.red),
                                  )
                                : SizedBox(),
                            Text(
                              '${arEn('المبلغ المطلوب', 'Required amount')} : ${req.requiredAmount}',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      )
                    : (log.form == "finance" && log.requestType == 6)
                        ? Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        '${arEn('من تاريخ', 'From date')} : ${req.departureDate}'),
                                    Text(
                                        '${arEn('الى تاريخ', 'To date')} : ${req.dateExpiry}'),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    '${arEn('الوقت المطلوب', 'required time')} : ${req.requeridHours}:${req.requeridMinut}'),
                              ],
                            ),
                          )
                        : Container(),
                (log.requestType == 1)
                    ? Text('${arEn('السبب', 'Reason')} : ${req.remarks}')
                    : (log.requestType == 12)
                        ? Text(
                            '${arEn('توصية', 'Recommendation')} : ${req.remarks}')
                        : Text('${arEn('ملاحظات', 'Notes')} : ${req.remarks}'),
                (req.dateUploded != 'null')
                    ? TextButton(
                        child: Row(
                          children: <Widget>[
                            Icon(LineIcons.paperclip),
                            Text('${arEn('مرفق', 'Attachment')}')
                          ],
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.transparent),
                          overlayColor: WidgetStateProperty.all<Color>(
                              Colors.grey.withOpacity(0.2)), //splash
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: () async {
                          Uint8List list = base64Decode(req.dateUploded!);
                          prepareFile(
                              list,
                              req.serviceTypeDesc! +
                                  '.' +
                                  req.contentType!.split("/")[1]);
                          return;
                        },
                      )
                    : SizedBox(),
              ],
            );
          } else {
            return Text(
                '${arEn('خطأ في تحميل التفاصيل , ربما تم حذف السجل', 'Error loading details, record may have been deleted')}');
          }
        }
        return Center(
          child: circular,
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  Widget sbabyCard(WorkFlowRecord log, int index) {
    String t = '';
    
    switch (log.vacationOrLeave) {
      case 1:
        t = '${arEn('مغادرة', 'Departure')} :  ${log.empName}';
        break;
      case 0:
        t = '${arEn('اجازة', 'Vacation')} :  ${log.empName}';
        break;
      case 99:
        t = '${log.fID} - ${log.empName}';
        break;
      default:
        t = log.empName ?? 'Unknown Employee'; // Fallback in case of null
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: ExpansionTileCard(
        animateTrailing: true,
        expandedColor: darkTheme ? Colors.grey.withAlpha(150) : Color(0xffffffff),
        baseColor: darkTheme ? Colors.grey.withAlpha(100) : Color(0xffe7e7e8),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        title: Text(
          byNameGroup ? (log.fDescAr ?? 'Unknown') : t,
          style: TextStyle(fontSize: fSize(2)),
        ),
        children: <Widget>[
          Container(
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: builder(log),
          ),
          OverflowBar(
            children: <Widget>[
              TextButton(
                child: Text('${arEn('موافقة', 'APPROVE')}'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                  overlayColor: WidgetStateProperty.all<Color>(olightGren),
                  foregroundColor: WidgetStateProperty.all<Color>(ogrentext),
                ),
                onPressed: () {
                  tmp = log;
                  noteDialog(true, log.fID!, log.requestType!, log);
                },
              ),
              if (!(log.actionStat == "1" && myCompanyNumber == "10020")) 
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                    overlayColor: WidgetStateProperty.all<Color>(Color(0xffecb1c5)),
                    foregroundColor: WidgetStateProperty.all<Color>(Color(0xffbf2056)),
                  ),
                  child: Text('${arEn('رفض', 'REJECT')}'),
                  onPressed: () {
                    tmp = log;
                    noteDialog(false, log.fID!, log.requestType!, log);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }


    Widget babyCard(String log, List<WorkFlowRecord> su, int index) {
      return new ExpansionTileCard(
        animateTrailing: true,
        baseColor: darkTheme ? Colors.grey.withAlpha(50) : Color(0xffffffff),
        expandedColor:
            darkTheme ? Colors.grey.withAlpha(100) : Color(0xffe7e7e8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
        ),
        leading: CircleAvatar(
            backgroundColor: Color(0xffff5151),
            child: Text(
              '${su.length}',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
        title: new Text(
          log,
          style: new TextStyle(
            // color: Colors.black,
            fontSize: fSize(2),
            fontWeight: FontWeight.bold,
          ),
        ),
        children: <Widget>[
          Container(
            child: Container(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: su.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return sbabyCard(su[index], index);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 2,
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    List<String> workers = [];
    for (var record in wFrecords) {
      workers.add(record.empName!);
    }
    workers = workers.toSet().toList();
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(
          // backgroundColor: Colors.transparent,
          // shadowColor: Colors.transparent,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                LineIcons.history,
                color: white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/WorkFlowReport');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.group,
                color: white,
              ),
              onPressed: () async {
                setState(() {
                  if (byNameGroup == false) {
                    byNameGroup = true;
                  } else {
                    byNameGroup = false;
                  }
                });
                var preferences = await SharedPreferences.getInstance();
                preferences.setBool('byNameGroup', byNameGroup);
              },
            ),
            IconButton(
              icon: Icon(LineIcons.syncIcon, color: white),
              onPressed: () {
                setState(() {
                  loadLog();
                });
              },
            ),
          ],
          title: '${arEn('الموافقات', 'Approvals')}',
          // style: TextStyle(fontSize: fSize(4), color: white),
          // ),
        ),

        body: byNameGroup
            ? Container(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    return babyCard(
                        workers[index],
                        wFrecords
                            .where((x) => x.empName == workers[index])
                            .toList(),
                        index);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 2,
                    );
                  },
                ),
              )
            : Container(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: wFTypes.length,
                  itemBuilder: (context, index) {
                    return babyCard(
                        wFTypes[index],
                        wFrecords
                            .where((x) => x.fDescAr == wFTypes[index])
                            .toList(),
                        index);
                  },
                ),
              ),
        //bottomSheet: ad20,
      ),
    );
  }
}

class MainWorkFlow extends StatefulWidget {
  const MainWorkFlow({Key ?key}) : super(key: key);

  @override
  State<MainWorkFlow> createState() => _MainWorkFlowState();
}

class _MainWorkFlowState extends State<MainWorkFlow> {
  Widget offsetPopup(Function(bool) onChanged) => PopupMenuButton<int>(
        itemBuilder: (context) => [
          for (var usr in otherUsers!)
            PopupMenuItem(
              value: 1,
              child: Text(
                arEn(usr['descr'], usr['descrEn']),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                me?.empNum = int.parse("${usr['empNo2']}");
                me?.compNo = int.parse("${usr['compNo2']}");
                onChanged(true);
              },
            ),
          PopupMenuItem(
            onTap: () async {
              await new DatabaseHelper2().getMe();
              onChanged(true);
            },
            value: 2,
            child: Text(
              arEn(me!.empName!, me!.empEngName!),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
        ],
        iconSize: 50,
        icon: Container(
          decoration: ShapeDecoration(
              color: primaryColor,
              shape: StadiumBorder(
                side: BorderSide(color: Colors.white, width: 0),
              )),
          child: Icon(Icons.people_alt, color: Colors.white),
        ),
      );

  @override
  void initState() {
    super.initState();
    otherUsers = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorkFlowPage(),
      floatingActionButton: FutureBuilder(
          future: getOtherUsers(),
          builder: (context, s) {
            if (s.connectionState == ConnectionState.done && s.hasData) {
              if (otherUsers == null || otherUsers!.isEmpty) return SizedBox();
              return offsetPopup((b) async {
                var body = {
                  "CompNo": me?.compNo.toString(),
                  "EmpNo": me?.empNum.toString(),
                  "Lang": gLang
                };
                String _baseUrl =
                    Uri.encodeFull('$myProtocol$serverURL/notifications');
                var res = await http.post(Uri.parse(_baseUrl),
                    headers: headers, body: body);

                if (res.statusCode == 200) {
                  dynamic value = json.decode(res.body);
                  Iterable d = value["news"];
                  news = d.map((m) => new News.map(m)).toList();
                  Iterable list = value["result"];
                  setState(() {
                    wFrecords =
                        list.map((model) => WorkFlowRecord.map(model)).toList();
                  });
                  wFTypes.clear();
                  for (var record in wFrecords) {
                    wFTypes.add(record.fDescAr!);
                  }
                  setState(() {
                    wFTypes = wFTypes.toSet().toList();
                  });
                }
              });
            }
            return SizedBox();
          }),
    );
  }
}

Future<List?> getOtherUsers() async {
  if (otherUsers != null) return otherUsers!;
  Uri _baseUrl = Uri.parse('$link/General');
  var res = await http.post(
    _baseUrl,
    headers: headers,
    body: {
      "CompNo": "${me?.compNo}",
      "Lang": "1",
      "empNo": "${me?.empNum}",
      "pn": "HRP_Mobile_GetWorkFlowUsers",
    },
  );
  if (res.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
    List data = snapshot["result"];
    otherUsers = data;
    return data;
  }
  return null;
}

class Substitute extends StatefulWidget {
  final Function(int)? onChange;
  final int? empNo;
  final int? compNo;
  int? selected = 0;
  Iterable? list;
  Substitute({
    Key? key,
    this.compNo,
    this.empNo,
    this.onChange,
    this.list,
    this.selected,
  }) : super(key: key);

  @override
  State<Substitute> createState() => _SubstituteState();
}

class _SubstituteState extends State<Substitute> {
  Future getData() async {
    if (widget.list == null) widget.list = [];
    if (widget.list!.isNotEmpty) return widget.list;
    var yy = await db.excute('General', {
      "CompNo": '${widget.compNo}',
      "Emp_num": '${widget.empNo}',
      "pn": "HRP_Mobile_EmpSubstitute"
    });

    return yy['result'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          widget.list = snapshot.data;
          if (widget.list!.isEmpty) return noData;
          return DropdownButton<dynamic>(
            value:
                widget.list!.where((x) => x["emp_num"] == widget.selected).first,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            underline: Container(
              height: 0,
            ),
            onChanged: (dynamic newValue) {
              widget.onChange!(newValue["emp_num"]);
              widget.selected = newValue["emp_num"];
              setState(() {});
            },
            items: widget.list!.map(
              (dynamic value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(arEn(value['empName'], value['empEngName'])),
                );
              },
            ).toList(),
          );
        }
        return Center(
          child: Text('يرجى الانتظار'),
        );
      },
    );
  }
}

int substituteId = 0;
Widget selectsub = Substitute(
  compNo: 1,
  empNo: 29,
  selected: 0,
  list: [],
  onChange: (int id) {
    substituteId = id;
  },
);
