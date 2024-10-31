import 'package:alpha/pages/Upload.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';

class SalaryIncreasePage extends StatefulWidget {
  @override
  _SalaryIncreasePageState createState() => _SalaryIncreasePageState();
}

class _SalaryIncreasePageState extends State<SalaryIncreasePage> {
  bool _isBusy = false;
  String _notes = '';
  FocusNode? valueFocus;

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

  Future<void> _submit() async {
    if (selectedItem == null || selectedItem!.parValue == 0) {
      toast(
          '${arEn('لا يمكن ارسال الطلب بدون نوع محدد', 'The request cannot be sent without a specific type')}');
      return;
    }
    final form = salaryKEY.currentState;

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

    await db.excute('InsertSocialAssistance', {
      "CompNo": me!.compNo.toString(),
      "EmpNo": me!.empNum.toString(),
      "ReqTypeSocialAssistance": "${selectedItem!.parValue!}",
      "RequestDate": dateFormat.format(initialDate),
      "RequiredAmount": '${selectedItem!.value!}',
      "RequeridNote": _notes.toString(),
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

  List<DefValue> requestTypes =
      defValues.where((x) => x.parID == 99997).toList();
  String base64Image = '';
  String path = '';
  DefValue? selectedItem;

  bool canInsert = true;
  @override
  Widget build(BuildContext context) {
    String selectedDate =
        initialDate.toString().split(' ')[0].replaceAll('-', '/');
    // DefValue requestType = defValues.where((x) => x.parID == 99997).first;

    if (selectedItem == null) {
      if (defValues.where((x) => x.parID == 99997 && x.parValue != 0).length ==
          0) {
        if (defValues.where((x) => x.parID == 99997).length == 0) {
          defValues.add(new DefValue(
              parID: 99997,
              parNameAr: '${arEn('لا يوجد انواع', 'There are no types')}',
              parValue: 0,
              value: 0));
        }
        canInsert = false;
      }
      selectedItem = defValues.where((x) => x.parID == 99997).first;
    }
    var requestForm = Container(
        child: AbsorbPointer(
      absorbing: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 20),
        child: new Column(
          children: <Widget>[
            new Form(
              key: salaryKEY,
              child: new Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: new Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                              '${arEn('تاريخ الطلب :     ', 'Request date :     ')}'),
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
                        '${arEn('نوع العلاوة :     ', 'Type of bonus :     ')}',
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
                          items: requestTypes.map(
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
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: new Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                              '${arEn('قيمة العلاوة', 'Bonus value')} :     ${selectedItem!.value}'),
                        ],
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
    ));
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(
            title: '${arEn('طلب علاوة معونة اجتماعية', 'Social aid request')}',
            actions: [
              !_isBusy
                  ? (canInsert)
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
                      : SizedBox()
                  : Center(
                      child: circular,
                    ),
            ]),
        body: SingleChildScrollView(
          child: Container(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  requestForm,
                ],
              ),
            ),
          ),
        ),
        //bottomSheet: ad9,
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
