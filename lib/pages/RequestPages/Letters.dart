import 'dart:convert';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/ShadowText.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmpLetters extends StatefulWidget {
  @override
  _EmpLettersState createState() => _EmpLettersState();
}

Future<dynamic> callAsyncFetch() async {
  var res =
      await http.post(Uri.parse('$link/General'), headers: headers, body: {
    "gLang": gLang,
    "EmpNo": "${me!.empNum}",
    "Year": "${now.year}",
    "CompNo": '${me!.compNo}',
    "pn": "HRP_Mobile_Letters"
  });

  if (res.statusCode == 200) {
    return json.decode(utf8.decode(res.bodyBytes));
  }
  return null;
}

FutureBuilder loadData() {
  return FutureBuilder(
    future: callAsyncFetch(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData &&
          snapshot.data != null) {
        List list = snapshot.data["result"];
        if (list.length == 0) return noData;
        return Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(colors: [
              primaryColor.withOpacity(0.01),
              primaryColor.withOpacity(0.01),
            ]),
          ),
          //padding: EdgeInsets.only(bottom: 50),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: list.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  //   toast('msg');
                },
                child: Card(
                  elevation: 4,
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          // color: primaryColor,
                          margin: EdgeInsets.only(bottom: 5),
                          child: Center(
                            child: ShadowText(
                              arEn(
                                list[i]["codeDesc"],
                                list[i]["codeEngDesc"],
                              ),
                              style: TextStyle(
                                  fontSize: fSize(3),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor.withOpacity(0.35),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(list[i]["aldd_type"]
                                ? arEn('علاوة', 'BONUS')
                                : arEn('اقتطاع', 'DEDUCTION')),
                            Text(list[i]["letterNo"]),
                          ],
                        ),
                        Row(
                          children: [
                            Text(arEn('التاريخ : ', 'Date : ')),
                            Text(list[i]["letterDate"]),
                          ],
                        ),
                        double.parse('${list[i]["aldd_amount"]}') > 0
                            ? Row(
                                children: [
                                  Text(arEn('القيمة : ', 'AMOUNT : ')),
                                  Text('${list[i]["aldd_amount"]}'),
                                  int.parse('${list[i]["aldd_Amount_type"]}') ==
                                          2
                                      ? Text(' % ')
                                      : int.parse('${list[i]["aldd_Amount_type"]}') ==
                                              1
                                          ? Text('') // JOD / USD
                                          : Text(''),
                                  int.parse('${list[i]["aldd_period"]}') != 0
                                      ? Text(int.parse(
                                                  '${list[i]["aldd_period"]}') ==
                                              99
                                          ? arEn(' دائمة ', ' PERMANENT ')
                                          : arEn(
                                              ' تكرر ${list[i]["aldd_period"]} مرة',
                                              ' repeat ${list[i]["aldd_period"]} times',
                                            ))
                                      : Text('')
                                ],
                              )
                            : Container(),
                        Row(
                          children: [
                            Text(arEn(
                              '${list[i]["aldd_Desc"]}',
                              '${list[i]["aldd_DescEng"]}',
                            )),
                          ],
                        ),
                        Container(
                          color: Colors.blueGrey.withOpacity(0.05),
                          child: ConstrainedBox(
                            constraints: new BoxConstraints(
                              minHeight: 50.0,
                              maxHeight: 200.0,
                            ),
                            child: SingleChildScrollView(
                              child: Container(
                                width: width,
                                padding: EdgeInsets.all(10),
                                child: Text('${list[i]["letterNotes"]}'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(

                  // color: primaryColor.withOpacity(0.35),
                  );
            },
          ),
        );
      }
      return Center(
        child: circular,
      );
    },
  );
}

class _EmpLettersState extends State<EmpLetters> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(title: arEn("كتب ووثائق", "Letters & documents")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: loadData(),
        ),
      ),
    );
  }
}
