import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class UnBlock extends StatefulWidget {
  const UnBlock({Key? key}) : super(key: key);

  @override
  _UnBlockState createState() => _UnBlockState();
}

String filter = '';
List get mList => myEmployees!
    .where((element) => element["empName"].toString().contains(filter))
    .toList();

class _UnBlockState extends State<UnBlock> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => filter = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AdPage(),

      appBar: appBar(
        title: arEn('الغاء ربط هاتف مستخدم', 'Unbind user mobile'),
        actions: [],
      ),
      body: Container(
        //padding: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              // color: primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          // color: Colors.black,
                          ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          // color: Colors.black,
                        ),
                        labelText: trans.search,
                        // labelStyle: TextStyle(color: Colors.black),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Builder(
                builder: (context) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: mList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var g = mList[index];
                      return Container(
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                new Dialogs(context, (bool ok) async {
                                  if (ok == true) {
                                    var gMenu = await http.post(
                                        Uri.parse('$link/General'),
                                        headers: headers,
                                        body: {
                                          "empNum": "${g['empNum']}",
                                          "CompNo": '${me?.compNo}',
                                          "pn": "HRP_Mobile_MobileUnLock"
                                        });
                                    if (gMenu.statusCode == 200) {
                                      setState(() {
                                        toast(arEn('تم فك الارتباط',
                                            'Employee unbinded with phone'));
                                      });
                                    }
                                  } else {}
                                },
                                        '${arEn('فك ربط', 'Unbind')}',
                                        '${arEn('هل تريد فك ربط هاتف الموظف ${g["empName"]} ؟', 'Do you want to unbind ${g["empEngName"]} mobile ?')}',
                                        true)
                                    .yesOrNo();
                              },
                              icon: Icon(Icons.phonelink_lock,
                                  color: darkTheme ? Colors.grey : black),
                              label: Container(
                                width: MediaQuery.of(context).size.width - 50,
                                child: Text(
                                  "${g['empName']}",
                                  style: TextStyle(
                                      color: darkTheme ? Colors.grey : black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      //bottomSheet: ad13,
    );
  }
}
