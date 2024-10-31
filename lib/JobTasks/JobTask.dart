import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';

class JobTask extends StatefulWidget {
  const JobTask({Key? key}) : super(key: key);

  @override
  State<JobTask> createState() => _JobTaskState();
}

enum MissionType { internal, external }

class _JobTaskState extends State<JobTask> {
  MissionType _character = MissionType.internal;
  String destination = '';
  String reason = '';
  @override
  Widget build(BuildContext context) {
    void requestFinish(String msg, bool suc) async {
      await showDialog(
          barrierDismissible: true,
          useRootNavigator: true,
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) =>
              suc ? successDialog(msg) : errorDialog(msg));
      Navigator.pop(context);
    }

    void doSave() async {
      int days = date2.difference(date1).inDays + 1;
      if (days <= 0) {
        showSnackBar(
            context,
            arEn('يرجى تحديد فترة الزيارة بشكل صحيح',
                'Please specify the visit period correctly'));
        return;
      }
      if (destination == '') {
        showSnackBar(
            context,
            arEn('يرجى تحديد جهة الزيارة بشكل صحيح',
                'Please specify the visit destination correctly'));
        return;
      }
      if (reason == '') {
        showSnackBar(
            context,
            arEn('يرجى تحديد سبب الزيارة بشكل صحيح',
                'Please specify the visit reason correctly'));
        return;
      }
      new Dialogs(context, (bool f) async {
        if (!f) return;
        await db.excute('General', {
          "EmpNo": '${me?.empNum}',
          "CompNo": '${me?.compNo}',
          "FromDate": '${dateFormat.format(date1)}',
          "ToDate": '${dateFormat.format(date2)}',
          "Days": '$days',
          "Destination": '$destination',
          "Reason": '$reason',
          "internal": '${_character == MissionType.internal ? 1 : 0}',
          "Lang": '$gLang',
          "pn": "HRP_Mobile_JobMission"
        }).then((dynamic r) {
          dynamic t = r['result'];
          requestFinish(arEn(t[0]['ar'], t[0]['en']), t[0]['error'] == 0);
        });
      },
              '${arEn('ارسال', 'submit')}',
              '${arEn('هل تريد ارسال الطلب ؟', 'Do you want to send the request?')}',
              false)
          .yesOrNo();
    }

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: appBar(
          title: arEn('مهمة عمل', 'Job task'),
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
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(arEn('نوع المهمة : ', 'Mission Type : ')),
                      ),
                      Expanded(
                        child: ListTile(
                          onTap: () {
                            if (_character == MissionType.external)
                              _character = MissionType.internal;
                            setState(() {});
                          },
                          title: Text(arEn('داخلي', 'Local')),
                          leading: Radio<MissionType>(
                            value: MissionType.internal,
                            groupValue: _character,
                            onChanged: (MissionType? value) {
                              setState(() {
                                _character = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          onTap: () {
                            if (_character == MissionType.internal)
                              _character = MissionType.external;

                            setState(() {});
                          },
                          title: Text(arEn('خارجي', 'Inter')),
                          leading: Radio<MissionType>(
                            value: MissionType.external,
                            groupValue: _character,
                            onChanged: (MissionType? value) {
                              setState(() {
                                _character = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  child: Row(
                    children: <Widget>[
                      Text('${arEn('من تاريخ : ', 'From date : ')}'),
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
                  child: Row(
                    children: <Widget>[
                      Text('${arEn('الى تاريخ : ', 'To date : ')}'),
                      Button(
                        onPressed: () {
                          selectDate2();
                        },
                        text: selectedDate2,
                      ),
                    ],
                  ),
                ),
                new Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    enableInteractiveSelection: false,
                    focusNode: new AlwaysDisabledFocusNode(),
                    controller: TextEditingController(
                        text: '${date2.difference(date1).inDays + 1}'),

                    keyboardType: TextInputType.text,
                    // onChanged: (val) => widget.df.reason = '$val',
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(),
                        counterText: "",
                        labelText: '${arEn('عدد الأيام : ', 'Days : ')}'),
                  ),
                ),
                new Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    maxLength: 50,
                    keyboardType: TextInputType.text,
                    onChanged: (val) => destination = '$val',
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(),
                        counterText: "",
                        labelText:
                            '${arEn('جهة الزيارة : ', 'Visiting destination : ')}'),
                  ),
                ),
                new Container(
                  child: TextFormField(
                    // controller:
                    //     TextEditingController(text: widget.df.reason),
                    maxLines: 5,
                    maxLength: 550,
                    keyboardType: TextInputType.text,
                    onChanged: (val) => reason = '$val',
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(),
                        counterText: "",
                        labelText:
                            '${arEn('سبب الزيارة : ', 'Visit reason : ')}'),
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
  String get selectedDate2 =>
      date2.toString().split(' ')[0].replaceAll('-', '/');
  DateTime date1 = now;
  DateTime date2 = now;
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

  void selectDate2() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != date2)
      setState(() {
        date2 = picked;
      });
  }
}
