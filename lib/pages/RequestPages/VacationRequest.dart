import 'dart:convert';
import 'package:alpha/pages/Upload.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';

int dateDef = 0;
bool doRefresh = true;
dynamic bdy;

class VacationRequest extends StatefulWidget {
  @override
  _VacationRequestState createState() => _VacationRequestState();
}

class _VacationRequestState extends State<VacationRequest> {
  bool _isBusy = false;
  String _notes = "";
  String _address = "";
  FocusNode? addressFocus;
  FocusNode? notesFocus;

  @override
  void initState() {
    doRefresh = true;
    addressFocus = FocusNode();
    notesFocus = FocusNode();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    addressFocus!.dispose();
    notesFocus!.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (dropdownValue == null || dropdownValue.parValue == 0) {
      toast(
          '${arEn('لا يمكن ارسال الطلب بدون نوع محدد', 'The request cannot be sent without a specific type')}');
      return;
    }

    final form = dayOffKEY.currentState;
    if (initialDate2.isBefore(initialDate)) {
      toast(
          "${arEn('تاريخ البداية اقل من تاريخ النهاية', 'The start date is lower than the end date')}");
      return;
    }

    if (dateDef <= 0 || dateDef == null) {
      toast(maxValue.parNameAr! +
          '  ' +
          maxValue.parValue.toString() +
          ' ${arEn('يوم', 'day')}');
      return;
    }

    // if (req == true) {
    //   if (_notes == "") {
    //     setState(() {
    //       notesFocus.requestFocus();
    //       return;
    //     });
    //   }
    // }

    // if (_address.length < 3) {
    //   setState(() {
    //     addressFocus.requestFocus();
    //     return;
    //   });
    // }

    form!.save();
    setState(() {
      FocusScope.of(context).unfocus();
      _isBusy = true;
    });
    new Dialogs(context, (bool ok) {
      if (ok == true)
        _doSave(ok);
      else
        setState(() {
          _isBusy = false;
        });
    },
            '${arEn('ارسال', 'submit')}',
            '${arEn('هل تريد ارسال الطلب ؟', 'Do you want to send the request?')}',
            false)
        .yesOrNo();
  }

  Future<void> _doSave(bool ok) async {
    if (!ok) {
      setState(() {
        _isBusy = false;
      });
      return;
    }
    initialDate = new DateTime(
        initialDate.year, initialDate.month, initialDate.day, 0, 0, 0, 0, 0);
    initialDate2 = new DateTime(
        initialDate2.year, initialDate2.month, initialDate2.day, 0, 0, 0, 0, 0);

    await db.excute('SaveNewLeaveVac', {
      "CompNo": '${me!.compNo}',
      "EmpNo": '${me!.empNum}',
      "Type": "0",
      "StartDate": dateFormat.format(initialDate),
      "EndDate": dateFormat.format(initialDate2),
      "StartTime": '$now',
      "EndTime": '$now',
      "LeaveType": "0",
      "VacationType": dropdownValue.parValue.toString(),
      "Address": _address,
      "Substitute": me!.empNum.toString(),
      "Notes": _notes,
      "SendEmail": "false",
      "LevType": "",
      "Lang": gLang,
      "base64": base64Image,
      "path": 'http:/' + path
    }).then((dynamic value) {
      _done(value["result"].toString().replaceAll('\\n', '\n'), value["error"]);
    });
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

  DefValue maxValue = defValues.where((x) => x.parID == 2).first;
  bool req =
      boolParse(defValues.where((x) => x.parID == 7).first.parValue.toString());

  List<DefValue> vationTypes =
      defValues.where((x) => x.parID == 99999).toList();

  DefValue dropdownValue = defValues.where((x) => x.parID == 99999).first;

  String base64Image = '';
  String path = '';

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
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
              key: dayOffKEY,
              child: Container(
                child: new Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        new Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text('${arEn('من تاريخ', 'From date')}'),
                                width: MediaQuery.of(context).size.width * .2,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text('${arEn('الى تاريخ', 'To date')}'),
                                width: MediaQuery.of(context).size.width * .2,
                              ),
                              Button(
                                onPressed: () {
                                  selectDate(2);
                                },
                                text: selectedDate2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: CalcDuration(
                            fromDate: initialDate,
                            toDate: initialDate2,
                            vacType: dropdownValue.parValue!,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child:
                                Text('${arEn('نوع الاجازة', 'Vacation type')}'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: new Container(
                              child: DropdownButton<DefValue>(
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                underline: Container(
                                  height: 0,
                                ),
                                onChanged: (DefValue? newValue) {
                                  setState(() {
                                    doRefresh = true;
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: vationTypes.map(
                                  (DefValue value) {
                                    return DropdownMenuItem<DefValue>(
                                      value: value,
                                      child: Container(
                                        width: 200,
                                        child: Text(
                                          arEn(
                                              value.parNameAr!, value.parNameEn!),
                                          textDirection: direction,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: new Container(
                        child: TextFormField(
                          controller: TextEditingController(text: '$_address'),
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
                                  '${arEn('العنوان خلال الإجازة', 'Address during vacation')}'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: new Container(
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          onSaved: (val) => _notes = val!.trim(),
                          onChanged: (val) => _notes = val.trim(),
                          validator: (val) {
                            if (req) {
                              if (val == "") {
                                return "${arEn('يجب ادخال سبب الاجازة', 'The reason for the vacation must be entered')}";
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
                                  '${arEn('سبب الإجازة', 'vacation reason')}'),
                        ),
                      ),
                    ),
                    new Upload(
                      initialpath: path,
                      onSelectFile: (String ?base64Image_, String? path_) {
                        base64Image = base64Image_!;
                        path = path_!;
                      },
                      onRemoveFile: () {
                        base64Image = '';
                        path = '';
                      },
                    ),
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
        body: SingleChildScrollView(
          child: Container(child: requestForm),
        ),
        //bottomSheet: ad8,
      ),
    );
  }

  DateTime initialDate = DateTime(now.year, now.month, now.day, 0, 0, 0)
      .add(new Duration(days: 0));
  DateTime initialDate2 = DateTime.now().add(new Duration(days: 0));
  void selectDate(int selector) async {
    if (selector == 1) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100));
      if (picked != null && picked != initialDate) {
        doRefresh = true;
        setState(() {
          initialDate = picked;
        });
      }

      return;
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate2,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != initialDate2) {
      doRefresh = true;
      setState(() {
        initialDate2 = picked;
      });
    }
  }
}

class CalcDuration extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? vacType;
  const CalcDuration({Key? key, this.fromDate, this.toDate, this.vacType})
      : super(key: key);

  @override
  _CalcDurationState createState() => _CalcDurationState();
}

Future<dynamic> callAsyncFetch(DateTime d1, DateTime d2, int vt) async {
  if (!doRefresh) {
    return bdy;
  }
  var body = {
    "CompNo": '${me!.compNo}',
    "EmpNo": '${me!.empNum}',
    "FromDate": '${dateFormat.format(d1)}',
    "ToDate": '${dateFormat.format(d2)}',
    "VacType": '$vt',
    "pn": "HRP_Mobile_GetEmpVacDays"
  };
  String _baseUrl = Uri.encodeFull('$myProtocol$serverURL/General');
  var res = await http.post(Uri.parse(_baseUrl), headers: headers, body: body);
  if (res.statusCode == 200) {
    bdy = json.decode(utf8.decode(res.bodyBytes));
    doRefresh = false;
    return json.decode(utf8.decode(res.bodyBytes));
  }
  return null;
}

class _CalcDurationState extends State<CalcDuration> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: callAsyncFetch(widget.fromDate!, widget.toDate!, widget.vacType!),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          if (snapshot.data["result"] != null) {
            int days = snapshot.data["result"][0]['days'];
            dateDef = days;
            return Text(
                '${arEn('مدة الاجازة', 'duration of vacation')}  :  $days  ${arEn('يوم', 'day')}');
          }
        }
        return Text(
            '${arEn('مدة الاجازة', 'duration of vacation')}  :    ${arEn('يوم', 'day')}');
      },
    ));
  }
}
