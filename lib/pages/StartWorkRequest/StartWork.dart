import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';

class StartWork extends StatefulWidget {
  const StartWork({Key ?key}) : super(key: key);

  @override
  State<StartWork> createState() => _StartWorkState();
}

class _StartWorkState extends State<StartWork> {
  void doSave() async {
    if (descr == '') {
      showSnackBar(
          context,
          arEn('يرجى ادخال التفاصيل بشكل صحيح',
              'Please specify the details correctly'));
      return;
    }
    new Dialogs(context, (bool f) async {
      if (!f) return;
      await db.excute('General', {
        "EmpNo": '${me?.empNum}',
        "CompNo": '${me?.compNo}',
        "Date": '${dateFormat.format(date1)}',
        "descr": '$descr',
        "Lang": '$gLang',
        "pn": "HRP_Mobile_StartWorkPN"
      }).then((dynamic r) {
        int error = r['result'][0]['error'];
        if (error == 0) {
          toast(arEn(r['result'][0]['ar'], r['result'][0]['en']));
          Navigator.pop(context);
        } else {
          showSnackBar(
              context, arEn(r['result'][0]['ar'], r['result'][0]['en']));
        }
      });
    },
            '${arEn('ارسال', 'submit')}',
            '${arEn('هل تريد ارسال الطلب ؟', 'Do you want to send the request?')}',
            false)
        .yesOrNo();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: appBar(
          title: arEn('مباشرة عمل', 'Start work request'),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.transparent),
                overlayColor: WidgetStateProperty.all<Color>(
                    Colors.transparent), //splash
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              onPressed: doSave,
              child: Text(
                arEn('ارسال', 'Send'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                new Container(
                  child: Row(
                    children: <Widget>[
                      Text('${arEn('التاريخ : ', 'Start date : ')}'),
                      Button(
                        onPressed: () {
                          selectDate();
                        },
                        text: selectedDate,
                      ),
                    ],
                  ),
                ),
                new Container(
                  child: TextFormField(
                    // controller:
                    //     TextEditingController(text: widget.df.descr),
                    maxLines: 5,
                    maxLength: 550,
                    keyboardType: TextInputType.text,
                    onChanged: (val) => descr = '$val',
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(),
                        counterText: "",
                        labelText: '${arEn('التفاصيل : ', 'Details : ')}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get selectedDate =>
      date1.toString().split(' ')[0].replaceAll('-', '/');
  void selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != date1)
      setState(() {
        date1 = picked;
      });
  }

  String descr = '';
  DateTime date1 = now;
}
