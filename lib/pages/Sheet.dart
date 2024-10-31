import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/models/Modules.dart';

class SheetPage extends StatefulWidget {
  @override
  _SheetPageState createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  FocusNode? valueFocus;

  List<TimeAtt> records = [];
  @override
  void initState() {
    valueFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    valueFocus!.dispose();
    super.dispose();
  }

  Future<dynamic> callAsyncFetch() async {
    // if (records.length > 0) return null;
    var body = {
      "CompNo": "${me?.compNo}",
      "FromEmp": "${me?.empNum}",
      "FromDate": dateFormat.format(initialDate),
      "ToDate": dateFormat.format(initialDate2),
      "glang": gLang,
      "pn": "HRP_RptDailyAttendance",
    };
    String _baseUrl = Uri.encodeFull('$myProtocol$serverURL/general');
    var res =
        await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes));
    }

    return null;
  }

  String amPM(String a) {
    if (gLang == "2") {
      return a;
    } else {
      return a.replaceAll('AM', ' ص').replaceAll('PM', ' م');
    }
  }

  Widget get xData => doSearch();
  bool load = false;
  Color mColor(
      String totOvertTF, String empIn, String empOut, bool registered) {
    if (totOvertTF != '0:00' && !registered) {
      return Colors.blue[500]!;
    }

    if ('${empIn.replaceAll('AM', ' ص').replaceAll('PM', ' م')}' == '00:00' &&
        '${empOut.replaceAll('AM', ' ص').replaceAll('PM', ' م')}' == '00:00')
      return Colors.grey;
    return darkTheme ? white : Colors.black;
  }

  TextStyle ts(
      String totOvertTF, String empIn, String empOut, bool registered) {
    return TextStyle(color: mColor(totOvertTF, empIn, empOut, registered));
  }

  FutureBuilder doSearch() {
    if (!load) {
      return FutureBuilder(
        builder: (context, snapshot) {
          return new Text(
              '${arEn('يرجى تحديد الفترة ثم البحث', 'Please select the period and then search')}');
        }, future: null,
      );
    }
    return FutureBuilder(
      future: callAsyncFetch(),
      initialData: records,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          Iterable list = snapshot.data["result"];
          records = list.map((model) => TimeAtt.map(model)).toList();
          return InteractiveViewer(
            maxScale: 20.5,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,

                // constrained: false,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        '${arEn('التاريخ', 'Date')}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fSize(0)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '${arEn('دخول', 'Entry')}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fSize(0)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '${arEn('خروج', 'Exit')}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fSize(0)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '${arEn('المغادرات', 'Departures')}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fSize(0)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '${arEn('إضافي', 'Overtime')}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fSize(0)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fSize(0)),
                      ),
                    ),
                  ],
                  rows: records.map(
                    (ta) {
                      TextStyle t =
                          ts(ta.totOvertTF!, ta.empIn!, ta.empOut!, ta.registered!);
                      return DataRow(cells: [
                        DataCell(Text(
                          '${dateFormat.format(ta.sDate!)}',
                          style: t,
                        )),
                        DataCell(Text(
                          '${amPM(ta.empIn!)}',
                          style: t,
                        )),
                        DataCell(Text(
                          '${amPM(ta.empOut!)}',
                          style: t,
                        )),
                        DataCell(Text(
                          '${ta.totLeavesTF}',
                          style: t,
                        )),
                        DataCell(
                          ta.totOvertTF == '0:00'
                              ? Center(
                                  child: Text(
                                  '${ta.totOvertTF}',
                                  style: t,
                                ))
                              : OverTimeButton(
                                  time: ta,
                                ),
                        ),
                        DataCell(Text(
                          '${ta.gridVacDesc}',
                          style: t,
                        )),
                      ]);
                    },
                  ).toList(),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Container(),
              );
            },
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
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    String title = arguments['desc'].toString();
    String selectedDate =
        initialDate.toString().split(' ')[0].replaceAll('-', '/');
    String selectedDate2 =
        initialDate2.toString().split(' ')[0].replaceAll('-', '/');
    var requestForm = AbsorbPointer(
      absorbing: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 20),
        child: new Column(
          children: <Widget>[
            new Form(
              key: fingerKEY,
              child: Container(
                child: new Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child:
                                      Text('${arEn('من تاريخ', 'From date')}'),
                                  width:
                                      MediaQuery.of(context).size.width * .20,
                                ),
                                Button(
                                  onPressed: () {
                                    selectDate(1);
                                  },
                                  text: selectedDate,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        children: <Widget>[
                          new Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child:
                                      Text('${arEn('الى تاريخ', 'To date')}'),
                                  width: MediaQuery.of(context).size.width * .2,
                                ),
                                Button(
                                  onPressed: () {
                                    selectDate(2);
                                  },
                                  text: selectedDate2,
                                ),
                                Button(
                                  text: '${arEn('بحث', 'Search')}',
                                  onPressed: () {
                                    if (initialDate2.isBefore(initialDate)) {
                                      toast(
                                          "${arEn('تاريخ البداية اقل من تاريخ النهاية', 'The start date is lower than the end date')}");
                                      return;
                                    }
                                    setState(() {
                                      load = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Container(
                        child: xData,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(title: title),
        body: SingleChildScrollView(
          child: Container(child: requestForm),
        ),
        //bottomSheet: ad18,
      ),
    );
  }

  DateTime initialDate = DateTime(now.year, now.month, 1, 0, 0, 0);
  DateTime initialDate2 = DateTime.now();
  void selectDate(int selector) async {
    if (selector == 1) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100));
      if (picked != null && picked != initialDate)
        setState(() {
          initialDate = picked;
        });
      return;
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate2,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != initialDate2)
      setState(() {
        initialDate2 = picked;
      });
  }
}

class OverTimeButton extends StatefulWidget {
  final TimeAtt ?time;
  const OverTimeButton({Key? key, this.time}) : super(key: key);
  @override
  _OverTimeButtonState createState() => _OverTimeButtonState();
}

class _OverTimeButtonState extends State<OverTimeButton> {
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            widget.time!.registered! ? Color(0xffc8dbcf) : Color(0xff03A9F4),
          ),
          overlayColor:
              WidgetStateProperty.all<Color>(Color(0xffc8dbcf)), //splash
          foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
        ),
        child: Text('${widget.time!.totOvertTF}'),
        onPressed: () async {
          if (widget.time!.registered!) return;
          new Dialogs(context, (bool r) async {
            if (r == true) {
              wait(context,
                  '${arEn('انتظر ... يتم حفظ المعلومات', 'Wait ... the information is saving')}');
              await db.excute('General', {
                "EmpNo": '${me?.empNum}',
                "CompNo": '${me?.compNo}',
                "date": '${dateFormat.format(widget.time!.sDate!)}',
                "time": '${widget.time!.totOvert}',
                "pn": "HRP_MOBILE_OverTimeRegister"
              }).then((r3) {
                dynamic res = r3["result"][0]['result'];
                done(context);
                toast(res.toString());
                widget.time!.registered = true;
                setState(() {});
              });
            }
          },
                  '${arEn('تسجيل اضافي', 'Overtime registration')}',
                  '${arEn('هل تريد تسجيل عمل اضافي مدته', 'Do you want to record an overtime work duration ')}  ${widget.time!.totOvertTF!} ${arEn('بتاريخ', 'Dated')} ${dateFormat2.format(widget.time!.sDate!)}',
                  false)
              .yesOrNo();
        },
      ),
    );
  }
}
