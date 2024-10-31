import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/ShadowText.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class VacationsPage extends StatefulWidget {
  @override
  _VacationsPageState createState() => _VacationsPageState();
}

Future<List<dynamic>> _fetchExpences() async {
  DateTime fDate = new DateTime(DateTime.now().year, 1, 1);

  final response = await db.excute('getVac', {
    "CompNo": '${me?.compNo}',
    "FromEmpNo": '${me?.empNum}',
    'FromDate': '${fDate.toString().split(' ')[0]}',
    'ToDate': '${DateTime.now().toString().split(' ')[0]}',
    'gLang': gLang,
  });

  List result = response["result"];
  return result;
}

class _VacationsPageState extends State<VacationsPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: trans.direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(title: trans.vacationBalance),
        body: Container(
          child: FutureBuilder<List<dynamic>>(
            future: _fetchExpences(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<dynamic> data = snapshot.data!;
                if (data.length == 0) return noData;

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      for (var item in data)
                        Card(
                          elevation: 4,
                          clipBehavior: Clip.hardEdge,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // color: primaryColor,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Center(
                                    child: ShadowText(
                                      '${item["vac_EngDesc"].toString().toUpperCase()}',
                                      style: TextStyle(
                                          fontSize: fSize(3),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: primaryColor.withOpacity(0.35),
                                ),
                                item["added_Hrs"] != null
                                    ? Text(
                                        '${trans.arEn('الرصيد المضاف', 'Added balance')} : ${item["added_Hrs"]}',
                                      )
                                    : SizedBox(),
                                Text(
                                  '${trans.arEn('الرصيد المدور', 'Rounded balance')} : ${item["roundedBal"]}',
                                ),
                                Text(
                                  '${trans.arEn('الرصيد الإفتتاحي', 'Beginning balance')} : ${item["openingBal"]}',
                                ),
                                Text(
                                  '${trans.arEn('الرصيد الكامل', 'Full balance')} : ${item["dueBal"]}',
                                ),
                                Text(
                                  '${trans.arEn('الرصيد المستهلك', 'Consumed balance')} : ${item["consBal"]}',
                                ),
                                Text(
                                  '${trans.arEn('الرصيد المتبقي لتاريخه', 'Current remaining balance')}  : ${item["remBal"]}',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: circular,
                ),
              );
            },
          ),
        ),
        ////bottomSheet: ad19,
      ),
    );
  }
}
