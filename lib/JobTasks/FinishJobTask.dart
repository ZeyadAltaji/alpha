import 'package:alpha/GeneralFiles/DateButton.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class FinishJobTask extends StatefulWidget {
  const FinishJobTask({Key? key}) : super(key: key);

  @override
  State<FinishJobTask> createState() => _FinishJobTaskState();
}

class _FinishJobTaskState extends State<FinishJobTask> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: appBar(
          title: arEn('انهاء مهمة عمل', 'Finish job task'),
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder(
            future: getMyMissions(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return badges.Badge(
                      position: badges.BadgePosition.topEnd(top: 0.5, end: 2),
                      badgeContent:
                          Text('    ${snapshot.data[index]['id']}    '),

                         badgeStyle: badges.BadgeStyle(
                        badgeColor: Colors.white,
                        shape: badges.BadgeShape.square,
                        padding: EdgeInsets.zero,
                      ), 
                      child: Card(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          // height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(arEn('جهة الزيارة : ',
                                      'Visiting destination : ') +
                                  '${snapshot.data[index]['destination']}'),
                              Text(arEn('سبب الزيارة : ', 'Visit reason : ') +
                                  '${snapshot.data[index]['reason']}'),
                              Text(arEn('من تاريخ: ', 'From date : ') +
                                  '${snapshot.data[index]['fromDate'].toString().split('T')[0].replaceAll('-', '/')}'),
                              Text(arEn('مدة الزيارة : ', 'Visit duration : ') +
                                  '${snapshot.data[index]['days']}'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DateButton(
                                    onchange: (DateTime m) {
                                      snapshot.data[index]['commencementDate'] =
                                          m;
                                      updateJobMission(snapshot.data[index], 0);
                                    },
                                    text: arEn('تاريخ المباشرة', 'Start date'),
                                    date: snapshot.data[index]
                                                ['commencementDate'] ==
                                            null
                                        ? null
                                        : DateTime.parse(
                                            '${snapshot.data[index]['commencementDate'].toString().split('T')[0]}'),
                                  ),
                                  DateButton(
                                    onchange: (DateTime m) {
                                      snapshot.data[index]['leaveDate'] = m;
                                      updateJobMission(snapshot.data[index], 0);
                                    },
                                    text: arEn('تاريخ المغادرة', 'Leave date'),
                                    date: snapshot.data[index]['leaveDate'] ==
                                            null
                                        ? null
                                        : DateTime.parse(
                                            '${snapshot.data[index]['leaveDate'].toString().split('T')[0]}'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (snapshot.data[index]
                                              ['commencementDate'] ==
                                          null) {
                                        showSnackBar(
                                            context,
                                            arEn('يرجى ادخال تاريخ المباشرة',
                                                'Please type commencement date'));
                                        return;
                                      }
                                      if (snapshot.data[index]['leaveDate'] ==
                                          null) {
                                        showSnackBar(
                                            context,
                                            arEn('يرجى ادخال تاريخ المغادرة',
                                                'Please type leave date'));
                                        return;
                                      }
                                      DateTime d1 = DateTime.parse(
                                          '${snapshot.data[index]['leaveDate']}');
                                      DateTime d2 = DateTime.parse(
                                          '${snapshot.data[index]['commencementDate']}');
                                      if (d1.compareTo(d2) < 0) {
                                        showSnackBar(
                                            context,
                                            arEn('يرجى التأكد من صحة التواريخ',
                                                'Please make sure the dates are correct.'));
                                        return;
                                      }

                                      new Dialogs(context, (bool r) async {
                                        if (r == true) {
                                          updateJobMission(
                                                  snapshot.data[index], 1)
                                              .then((value) {
                                            setState(() {});
                                          });
                                        }
                                      },
                                              '${arEn('إرسال', 'Change language')}',
                                              '${arEn('هل تريد إرسال الطلب حقاً ؟', 'Do you want to send the request ?')}',
                                              true)
                                          .yesOrNo();
                                    },
                                    child: Text(
                                      arEn(
                                        'ارسال',
                                        'Send',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

Future<dynamic> updateJobMission(dynamic d, int send) async {
  return await db.excute('General', {
    "Id": '${d['id']}',
    "send": '$send',
    "commencementDate": '${d['commencementDate']}',
    "leaveDate": '${d['leaveDate']}',
    "pn": "HRP_Mobile_UpdateMissions"
  });
}
