import 'dart:io';
import 'package:alpha/pages/Upload.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';

class AdvancePaymentPage extends StatefulWidget {
  @override
  _AdvancePaymentPageState createState() => _AdvancePaymentPageState();
}

class _AdvancePaymentPageState extends State<AdvancePaymentPage> {
  bool _isBusy = false;
  double _value = 0;
  String _notes = '';
  int _months = 0;
  late FocusNode valueFocus;
  late FocusNode monthsFocus;
  DefValue maxValue = defValues.where((x) => x.parID == 11).first;
  DefValue maxMonth = defValues.where((x) => x.parID == 12).first;

  @override
  void initState() {
    valueFocus = FocusNode();
    monthsFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    monthsFocus.dispose();
    valueFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = advanceKEY.currentState;
    if (_value <= 0 || _value == null) {
      setState(() {
        valueFocus.requestFocus();
      });
      return;
    }

    if (_months == 0 || _months == null) {
      setState(() {
        monthsFocus.requestFocus();
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

    await db.excute('InsertAdvanceRequest', {
      "CompNo": me!.compNo.toString(),
      "EmpNo": me!.empNum.toString(),
      "RequestDate": dateFormat.format(initialDate),
      "RequiredAmount": _value.toString(),
      "RequeridNote": _notes.toString(),
      "MonthNo": _months.toString(),
      "base64": base64Image,
      "path": 'http:/' + path
    }).then((dynamic value) {
      _done(value["result"].toString(), value["error"]);
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

  String base64Image = '';
  String path = '';
  File? selectedImage;
  DefValue? selectedItem;
  @override
  Widget build(BuildContext context) {
    String selectedDate =
        initialDate.toString().split(' ')[0].replaceAll('-', '/');
    var requestForm = AbsorbPointer(
      absorbing: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 20),
        child: new Column(
          children: <Widget>[
            new Form(
              key: advanceKEY,
              child: new Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                              '${arEn('تاريخ طلب سلفة', 'Advance request date')}'),
                          Button(
                            onPressed: () {
                              selectDate();
                            },
                            text: selectedDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _value = double.parse(val.toString()),
                        onChanged: (val) =>
                            _value = double.parse(val.toString()),
                        validator: (val) {
                          if (double.parse(val!) <= 0) {
                            return '${arEn('يرجى ادخال قيمة صحيحة', 'Please enter a valid value')}';
                          }
                          if (double.parse(val) > maxValue.parValue!) {
                            return arEn(
                                    maxValue.parNameAr!, maxValue.parNameEn!) +
                                ' ' +
                                maxValue.parValue.toString();
                          }
                          return null;
                        },
                        focusNode: valueFocus,
                        maxLength: 10,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText:
                                '${arEn('قيمة السلفة', 'Advance value')}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: false),
                        onSaved: (val) {
                          if (val == "") val = "0";
                          _months = int.parse('$val');
                        },
                        onChanged: (val) {
                          if (val == "") val = "0";
                          _months = int.parse('$val');
                        },
                        validator: (val) {
                          if (val == "") val = "0";
                          if (int.parse(val!) <= 0) {
                            return "${arEn('الرجاء ادخال عدد صحيح', 'Please enter an integer number')}";
                          }
                          if (int.parse(val!) > maxMonth.parValue!) {
                            return arEn(
                                    maxMonth.parNameAr!, maxMonth.parNameEn!) +
                                ' ' +
                                maxMonth.parValue.toString();
                          }
                          return null;
                        },
                        focusNode: monthsFocus,
                        maxLength: 2,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            suffixText: '${arEn('شهر', 'Month')}',
                            counterText: "",
                            labelText:
                                '${arEn('عدد الاشهر', 'Number of months')}'),
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
                        maxLines: 4,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: '${arEn('ملاحظات', 'Notes')}'),
                      ),
                    ),
                  ),
                  new Upload(
                    initialpath: path,
                    onSelectFile: (String? base64Image_, String ?path_) {
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
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );

    return Container(
      child: Directionality(
        textDirection: direction,
        child: Scaffold(
          bottomNavigationBar: AdPage(),

          appBar:
              appBar(title: '${arEn('طلب سلفة', 'Advance request')}', actions: [
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
          //bottomSheet: ad1,
        ),
      ),
    );
  }

  DateTime initialDate = DateTime.now();

  void selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != initialDate)
      setState(() {
        initialDate = picked;
      });
  }
}
