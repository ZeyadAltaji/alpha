import 'dart:convert';

import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class KickOut extends StatefulWidget {
  const KickOut({Key? key}) : super(key: key);

  @override
  _KickOutState createState() => _KickOutState();
}

String filter = '';
List get mList => myEmployees!
    .where((element) => element["empName"].toString().contains(filter))
    .toList();

class _KickOutState extends State<KickOut> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => filter = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: trans.direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(
          title: arEn('تسجيل خروج الموظف', 'Sign out form employee'),
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
                                      Map data = {
                                        "to":
                                            "/topics/hr-logout-$myCompanyNumber-${me?.compNo}-${g["empNum"]}",
                                        "notification": {
                                          "title": "نظام الخدمة الذاتية",
                                          "body": "تسجيل الخروج"
                                        },
                                        "data": {"Type": "logout"},
                                        "time_to_live": 600
                                      };
                                      var body = json.encode(data);
                                      var _baseUrl = Uri.parse(
                                          'https://fcm.googleapis.com/fcm/send');
                                      var res = await http.post(_baseUrl,
                                          headers: {
                                            'Authorization':
                                                'key=AAAAutseYrM:APA91bEoVdqZryae-ICNYjmZu4iUzexi54tFTKd3m5NLDMg_Wfz-j6cridoCapS_Wn19Xn2VUJVUIrhnbPqCsKblNwzagV-ZNpIzd71_NMdPd3_U3ItjZIzsnZhOrN_HeXrNPw8QQIOW',
                                            "Content-Type": "application/json"
                                          },
                                          body: body);
                                      if (res.statusCode == 200) {
                                        toast(arEn('تم اخراج الموظف',
                                            'Employee signed out'));
                                      }
                                    } else {}
                                  },
                                          '${arEn('إخراج', 'Sign out')}',
                                          '${arEn('هل انت متأكد من إخراج الموظف من النظام ؟', 'Are you sure to remove the employee from the system?')}',
                                          true)
                                      .yesOrNo();
                                },
                                icon: Icon(Icons.outbond_outlined,
                                    color: darkTheme ? Colors.red : Colors.red),
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
      ),
    );
  }
}
