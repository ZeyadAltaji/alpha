import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:alpha/pages/RequestPages/GeneralRequest.dart';
import 'package:alpha/pages/TransPort/addTrans.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Transportation extends StatefulWidget {
  const Transportation({Key? key}) : super(key: key);

  @override
  State<Transportation> createState() => _TransportationState();
}

class _TransportationState extends State<Transportation> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransPage(
                  df: new TransDF(
                    amount: 0,
                    area: '',
                    city: '',
                    customer: '',
                    date: now,
                    reason: '',
                  ),
                  onSave: (TransDF r) {
                    transDFs.add(r);
                    saveTransDFs();
                    setState(() {});
                  },
                ),
              ),
            );
          },
        ),
        appBar: appBar(
          title: arEn('قسائم المواصلات', 'Coupons request'),
          actions: [
            TextButton(
              child: Text(arEn('ارسال', 'Send')),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.transparent),
                overlayColor: WidgetStateProperty.all<Color>(
                    Colors.transparent), //splash
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () async {
                if (transDFs.isEmpty) return;
                new Dialogs(context, (bool r) async {
                  if (r == true) {
                    Uri _baseUrl = Uri.parse('$myProtocol$serverURL/SaveTrans');
                    dynamic body = {
                      "CompNo": '${me?.compNo}',
                      "empNum": "${me?.empNum}",
                      "trans": "$getTrans",
                    };
                    final response = await http.post(
                      _baseUrl,
                      headers: headers,
                      body: body,
                    );

                    if (response.statusCode == 200) {
                      showDialog(
                        barrierColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) => successDialog(
                            arEn('تم ارسال الطلب', 'Request sent')),
                      );
                      transDFs.clear();
                      saveTransDFs();
                      setState(() {});
                    }
                  }
                },
                        '${arEn('ارسال', 'Send')}',
                        '${arEn('هل تريد ارسال هذا الطلب ؟', 'Do you want to send this request ?')}',
                        true)
                    .yesOrNo();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                for (var df in transDFs)
                  TrBlock(
                    df: df,
                    onRemove: () {
                      setState(() {});
                    },
                  ),
                Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          arEn(
                              'المجموع : ${fixed(transDFs.fold(0, (sum, item) => sum + item.amount!))}',
                              'Total : ${fixed(transDFs.fold(0, (sum, item) => sum + item.amount!))}'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fSize(2)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrBlock extends StatefulWidget {
  final TransDF? df;
  final Function? onRemove;
  const TrBlock({Key ?key, this.df, this.onRemove}) : super(key: key);

  @override
  State<TrBlock> createState() => _TrBlockState();
}

class _TrBlockState extends State<TrBlock> {
  @override
  Widget build(BuildContext context) {
    return badges.Badge(
        badgeAnimation: badges.BadgeAnimation.fade(),
        badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.square,
        badgeColor:Colors.transparent,
        padding: EdgeInsets.zero,
       
            elevation: 0,
      ),
     
            position: badges.BadgePosition.topEnd(top: -10, end: -12),

      badgeContent: Container(
        width: 75.0,
        height: 25.0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransPage(
                  df: widget.df!,
                  onSave: (TransDF r) {
                    widget.df!.amount = r.amount;
                    widget.df!.area = r.area;
                    widget.df!.city = r.city;
                    widget.df!.reason = r.reason;
                    widget.df!.customer = r.customer;
                    saveTransDFs();

                    setState(() {});
                  },
                ),
              ),
            );
          },
          child: Icon(
            Icons.edit,
            color: Colors.blue,
          ),
        ),
      ),
      child: badges.Badge(
      //    return badges.Badge(
      //   badgeAnimation: badges.BadgeAnimation.fade(),
      //   badgeStyle: badges.BadgeStyle(
      //   shape: badges.BadgeShape.square,
      //   badgeColor:Colors.transparent,
      //   padding: EdgeInsets.zero,
       
      //       elevation: 0,
      // ),
         badgeAnimation: badges.BadgeAnimation.fade(),
          badgeContent: Container(
          width: 25.0,
          height: 25.0,
          child: InkWell(
            onTap: () {
              new Dialogs(context, (bool c) {
                if (!c) return;
                transDFs.remove(widget.df);
                widget.onRemove!();
                saveTransDFs();
              },
                      '${arEn('ازالة', 'Remove')}',
                      '${arEn('هل تريد الإزالة ؟', 'Do you want to remove ?')}',
                      false)
                  .yesOrNo();
            },
            child: Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
        ),
       
        position: badges.BadgePosition.topEnd(top: 5, end: 5),
        child: badges.Badge(
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.transparent,
            shape: badges.BadgeShape.square,
            padding: EdgeInsets.zero,
            elevation: 0,
          ),
          badgeAnimation: badges.BadgeAnimation.rotation(
            animationDuration: Duration(seconds: 1),
          ),

          badgeContent: Text(
            'المبلغ : ${fixed(widget.df!.amount!)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fSize(2)),
          ),
          child: Card(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: MediaQuery.of(context).size.width,
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التاريخ : ${dateFormat2.format(widget.df!.date!)}',
                  ),
                  Text(
                    'المدينة : ${widget.df!.city}',
                  ),
                  Text(
                    'المنطقة : ${widget.df!.area}',
                  ),
                  Text(
                    'العميل : ${widget.df!.customer}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String get getTrans {
  return encodeTransDF(transDFs)!;
}

void saveTransDFs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('TransDFs', getTrans);
}
