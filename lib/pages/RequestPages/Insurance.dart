import 'package:alpha/pages/Upload.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';

class InsuranceJoin extends StatefulWidget {
  @override
  _InsuranceJoinState createState() => _InsuranceJoinState();
}

class _InsuranceJoinState extends State<InsuranceJoin> {
  bool _isBusy = false;
  FocusNode? tpFocus;
  String _notes = '';
  // SubMenu selectedItem;

  @override
  void initState() {
    tpFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    tpFocus!.dispose();
    super.dispose();
  }

  DateTime initialDate = DateTime.now();

  void selectDate() async {
    final DateTime ?picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != initialDate)
      setState(() {
        initialDate = picked;
      });
  }

  Future<void> _submit() async {
    if (selectedItem == null || selectedItem!.parValue == 0) {
      toast(
          '${arEn('لا يمكن ارسال الطلب بدون نوع محدد', 'The request cannot be sent without a specific type')}');
      return;
    }
    //  if (base64Image == '') {
    //    toast('يجب ارفاق ملف');
    //    return;
    //  }
    final form = insuranceKEY.currentState;

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

    await db.excute('InsertReqHealthServices', {
      "CompNo": me!.compNo.toString(),
      "EmpNo": me!.empNum.toString(),
      "RequestTypeHealthServ": selectedItem!.parValue.toString(),
      "RequestDate": dateFormat.format(initialDate),
      "RequeridNote": _notes,
      "base64": base64Image,
      "path": 'http:/' + path
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

  DefValue ?selectedItem;

  String base64Image = '';
  String path = '';

  bool canInsert = true;
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String title = arguments['desc'].toString();

    if (selectedItem == null) {
      if (defValues.where((x) => x.parID == 2222 && x.parValue != 0).length ==
          0) {
        if (defValues.where((x) => x.parID == 2222).length == 0) {
          defValues.add(new DefValue(
              parID: 2222,
              parNameAr: '${arEn('لا يوجد انواع', 'There are no types')}',
              parValue: 0,
              value: 0));
        }
        canInsert = false;
      }
      selectedItem = defValues.where((x) => x.parID == 2222).first;
    }

    String selectedDate =
        initialDate.toString().split(' ')[0].replaceAll('-', '/');
    var requestForm = AbsorbPointer(
      absorbing: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 20),
        child: new Column(
          children: <Widget>[
            new Form(
              key: insuranceKEY,
              child: new Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                              '${arEn('تاريخ طلب الانضمام', 'Join request date')}'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${arEn(': نوع الطلب', 'Type of Request :')}',
                        textDirection: TextDirection.ltr,
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
                          items: defValues
                              .where((x) => x.parID == 2222)
                              .toList()
                              .map(
                            (DefValue value) {
                              return DropdownMenuItem<DefValue>(
                                value: value,
                                child: Container(
                                  width: 200,
                                  child: Container(
                                    child: Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        arEn(value.parNameAr!, value.parNameEn!),
                                        textDirection: direction,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
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
                    onSelectFile: (String? base64Image_, String? path_) {
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
        //bottomSheet: ad5,
      ),
    );
  }
}
