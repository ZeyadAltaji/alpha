import 'package:alpha/models/Modules.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';

class ExtraWorkPage extends StatefulWidget {
  @override
  _ExtraWorkPageState createState() => _ExtraWorkPageState();
}

class _ExtraWorkPageState extends State<ExtraWorkPage> {
  bool _isBusy = false;
  int _hours = 0;
  String _notes = '';
  int _minutes = 0;
  FocusNode? hoursFocus;
  FocusNode? minutesFocus;

  final hourscontroller = TextEditingController(text: '0');
  final minutescontroller = TextEditingController(text: '0');

  @override
  void initState() {
    hoursFocus = FocusNode();
    minutesFocus = FocusNode();

    hoursFocus!.addListener(() {
      if (hoursFocus!.hasFocus) {
        hourscontroller.selection = TextSelection(
            baseOffset: 0, extentOffset: hourscontroller.text.length);
      }
    });
    minutesFocus!.addListener(() {
      if (minutesFocus!.hasFocus) {
        minutescontroller.selection = TextSelection(
            baseOffset: 0, extentOffset: minutescontroller.text.length);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    minutesFocus!.dispose();
    hoursFocus!.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = extraKEY.currentState;
    initialDate = initialDate.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    initialDate2 = initialDate2.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    if (selectedItem == null || selectedItem!.parValue == 0) {
      toast(
          '${arEn('لا يمكن ارسال الطلب بدون نوع محدد', 'The request cannot be sent without a specific type')}');
      return;
    }
    if (initialDate2.isBefore(initialDate)) {
      toast(
          "${arEn('تاريخ البداية اقل من تاريخ النهاية', 'The start date is lower than the end date')}");
      return;
    }
    if (_hours <= 0 && _minutes <= 0) {
      setState(() {
        hoursFocus!.requestFocus();
      });
      return;
    }

    if (_minutes == 0) {
      setState(() {
        minutesFocus!.requestFocus();
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
    if (isDemo) {
      _done("تم ارسال طلبك", false);
      return;
    }
    if (!ok) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    await db.excute('InsertAdditionalWork', {
      "CompNo": me!.compNo.toString(),
      "EmpNo": me!.empNum.toString(),
      "RequestDate": dateFormat.format(initialDate),
      "RequestToDate": dateFormat.format(initialDate2),
      "RequeridHours": _hours.toString(),
      "RequeridMinut": _minutes.toString(),
      "RequeridNote": _notes.toString(),
      "OverTCode": "${selectedItem!.parValue!}"
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

  List<DefValue> overtimeTypes =
      defValues.where((x) => x.parID == 99996).toList();
  DefValue? selectedItem;
  bool canInsert = true;

  @override
  Widget build(BuildContext context) {
    String selectedDate =
        initialDate.toString().split(' ')[0].replaceAll('-', '/');
    String selectedDate2 =
        initialDate2.toString().split(' ')[0].replaceAll('-', '/');

    if (selectedItem == null) {
      if (defValues.where((x) => x.parID == 99996 && x.parValue != 0).length ==
          0) {
        if (defValues.where((x) => x.parID == 99996).length == 0) {
          defValues.add(new DefValue(
              parID: 99996,
              parNameAr: '${arEn('لا يوجد انواع', 'There are no types')}',
              parValue: 0,
              value: 0));
        }
        canInsert = false;
      }
      selectedItem = defValues.where((x) => x.parID == 99996).first;
    }

    var requestForm = AbsorbPointer(
      absorbing: false,
      child: new Column(
        children: <Widget>[
          new Form(
            key: extraKEY,
            child: Container(
              child: Container(
                padding: EdgeInsets.all(10),
                child: new Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${arEn('نوع العمل الاضافي :', 'Type of overtime :  ')}',
                          textDirection: direction,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        new Container(
                          child: DropdownButton<DefValue>(
                            value: selectedItem,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            underline: Container(
                              height: 0,
                            ),
                            onChanged: (DefValue? newValue) {
                              setState(() {
                                selectedItem = newValue!;
                              });
                            },
                            items: overtimeTypes.map(
                              (DefValue value) {
                                return DropdownMenuItem<DefValue>(
                                  value: value,
                                  child: Container(
                                    width: 200,
                                    child: Text(
                                      arEn(value.parNameAr!, value.parNameEn!),
                                      textDirection: direction,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .45,
                          child: TextFormField(
                            controller: hourscontroller,
                            keyboardType: TextInputType.number,
                            onSaved: (val) =>
                                _hours = int.parse(val.toString()),
                            onChanged: (val) {
                              if (val == "") {
                                val = "0";
                              }
                              _hours = int.parse(val.toString());
                            },
                            validator: (val) {
                              if (int.parse(val!) < 0) {
                                return '${arEn('قيمة غير صحيحة', 'Incorrect value')}';
                              }
                              return null;
                            },
                            focusNode: hoursFocus,
                            maxLength: 2,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                border: OutlineInputBorder(),
                                counterText: "",
                                labelText:
                                    '${arEn('عدد الساعات', 'The number of hours')}'),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .45,
                          child: TextFormField(
                            controller: minutescontroller,
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: false, signed: false),
                            onSaved: (val) =>
                                _minutes = int.parse(val.toString()),
                            onChanged: (val) =>
                                _minutes = int.parse(val.toString()),
                            validator: (val) {
                              if (int.parse(val!) < 0) {
                                return '${arEn('قيمة غير صحيحة', 'Incorrect value')}';
                              }
                              if (int.parse(val) >= 60) {
                                return "${arEn('ادخل عدد اقل من 60', 'Enter a number less than 60')}";
                              }
                              return null;
                            },
                            focusNode: minutesFocus,
                            maxLength: 2,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                border: OutlineInputBorder(),
                                counterText: "",
                                labelText:
                                    '${arEn('عدد الدقائق', 'Number of minutes')}'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      onSaved: (val) => _notes = val!.trim(),
                      onChanged: (val) => _notes = val.trim(),
                      maxLines: 4,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counterText: "",
                          labelText: '${arEn('ملاحظات', 'Notes')}'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(
            title: '${arEn('طلب عمل اضافي', 'Overtime work request')}',
            actions: [
              !_isBusy
                  ? TextButton(
                      child: Text(arEn('ارسال', 'Send')),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.transparent),
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
        //bottomSheet: ad2,
      ),
    );
  }

  DateTime initialDate = DateTime.now();
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
