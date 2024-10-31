import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/General.dart';

class SalarySlip extends StatefulWidget {
  @override
  _SalarySlipState createState() => _SalarySlipState();
}

class _SalarySlipState extends State<SalarySlip> {
  FocusNode? monthsFocus;
  FocusNode? yearsFocus;
  int year = DateTime.now().year;
  int month = DateTime.now().month - 1;

  String bodyTableSubData1 = "";
  String bodyTableSubData2 = "";

  int monthDays = 0;
  double grossSalary = 0;
  double totalNetCash = 0;

  int workedDays = 0;
  double amountTrasnferredToBank = 0;
  double totalDeductions = 0;

  @override
  void initState() {
    super.initState();
    loadAd();
    yearsFocus = FocusNode();
    monthsFocus = FocusNode();
    super.initState();
  }

  void loadAd() async {}

  Future<void> submit() async {
    wait(context);
    await db.excute('GetSaralySlip', {
      "CompNo": "${me?.compNo}",
      "EmpNo": "${me?.empNum}",
      "Month": "$month",
      "Year": "$year",
      "Lang": gLang,
    }).then((dynamic value) {
      donex(value["result"], value["error"]);
    });
  }

  void donex(dynamic msg, bool error) async {
    done(context);
    setState(() {
      totalNetCash = msg["totalNetCash"];
      grossSalary = msg["grossSalary"];
      monthDays = msg["monthDays"];
      workedDays = msg["workedDays"];
      amountTrasnferredToBank = msg["amountTrasnferredToBank"];
      totalDeductions = msg["totalDeductions"];
      bodyTableSubData1 =
          msg["bodyTableSubData1"].toString().replaceAll('***', '\n');
      bodyTableSubData2 =
          msg["bodyTableSubData2"].toString().replaceAll('***', '\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    loadAd();
    var requestForm = AbsorbPointer(
      absorbing: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: new Column(
          children: <Widget>[
            new Form(
              key: extraKEY,
              child: new Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${arEn('الشهر', 'Month')} :   ',
                                  style: bold,
                                ),
                              ),
                              Container(
                                child: DropdownButton<int>(
                                  value: month == 0 ? 1 : month,
                                  icon: Icon(Icons.calendar_today),
                                  iconSize: 24,
                                  underline: Container(
                                    height: 0,
                                  ),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      month = newValue!;
                                    });
                                  },
                                  items: months.map(
                                    (int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              value.toString(),
                                              style: bold,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${arEn('السنة', 'Year')} :   ',
                                  style: bold,
                                ),
                              ),
                              Container(
                                child: DropdownButton<int>(
                                  value: year,
                                  icon: Icon(Icons.calendar_today),
                                  iconSize: 24,
                                  underline: Container(
                                    height: 0,
                                  ),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      year = newValue!;
                                    });
                                  },
                                  items: yearsList.map(
                                    (int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              value.toString(),
                                              style: bold,
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              // color: Color(0xfff2f2f2),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    '${arEn('رقم الموظف', 'Employee number')} : ${me?.empNum}',
                                    style: bold),
                                Text(
                                    '${arEn('الاسم', 'Name')} : ${arEn(me!.empName!, me!.empEngName!)}',
                                    style: bold),
                                Text(
                                    '${arEn('الرقم الاجتماعي', 'Social number')} : ${me?.socialNo}',
                                    style: bold),
                                Container(
                                  margin: EdgeInsets.only(top: 15, bottom: 5),
                                  child: Center(
                                    child: Text(
                                      '${arEn('علاوات الموظف', 'Employee bonuses')}',
                                      style: bold,
                                    ),
                                  ),
                                ),
                                Text('''$bodyTableSubData1'''),
                                Text(
                                    '${arEn('اجمالي الراتب', 'Total salary')} : $grossSalary'),
                                Text(
                                    '${arEn('الصافي النقدي', 'The cash net')} : $totalNetCash'),
                                Text(
                                    '${arEn('ايام الشهر', 'Days of the month')} : $monthDays'),
                                Container(
                                  margin: EdgeInsets.only(top: 15, bottom: 5),
                                  child: Center(
                                    child: Text(
                                      '${arEn('إقتطاعات الموظف', 'Employee deductions')}',
                                      style: bold,
                                    ),
                                  ),
                                ),
                                Text('''$bodyTableSubData2'''),
                                Text(
                                    '${arEn('إجمالي الإقتطاعات', 'Total Deductions')} : $totalDeductions'),
                                Text(
                                    '${arEn('المحول الى البنك', 'Transferred to the bank')} : $amountTrasnferredToBank'),
                                Text(
                                    '${arEn('ايام العمل', 'workdays')} : $workedDays'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
        appBar: appBar(title: arEn('كشف الراتب', 'Salary revealed'), actions: [
          TextButton(
            child: Text(arEn('بحث', 'Search')),
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.transparent),
              overlayColor:
                  WidgetStateProperty.all<Color>(Colors.transparent), //splash
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () async {
              submit();
              //if (await rewardAd.isLoaded) rewardAd.show();
            },
          ),
        ]),
        body: Container(
          //padding: EdgeInsets.only(bottom: 50),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: SingleChildScrollView(child: requestForm)),
            ],
          ),
        ),
      ),
    );
  }
}
