import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

// ignore: must_be_immutable
class LocationUsers extends StatefulWidget {
  int all = 0;
  @override
  _LocationUsersState createState() => _LocationUsersState();
}

String filter = '';
List get mList => myEmployees!
    .where((element) => element["empName"].toString().contains(filter))
    .toList();

class _LocationUsersState extends State<LocationUsers> {
  bool _isBusy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => filter = '');
    });
  }

  void _submit() {
    new Dialogs(context, (t) async {
      if (t == false) return;
      //
      _isBusy = false;
      List<int> allowedList = [];
      List<int> notAllowedList = [];

      for (int i = 0; i < myEmployees!.length; i++) {
        if (myEmployees![i]["access"] == 1) {
          allowedList.add(myEmployees![i]["empNum"]);
          notAllowedList.add(myEmployees![i]["empNum"]);
        } else {
          notAllowedList.add(myEmployees![i]["empNum"]);
        }
      }
      String al = "(CompNo,empNum,CanUse)values";
      for (var i in allowedList) {
        al += "(${me?.compNo},$i,1)";
        if (allowedList.indexOf(i) == allowedList.length - 1) {
          al += ';';
        } else {
          al += ',';
        }
      }
      if (allowedList.length == 0) al = '';

      await db.excute('SavePermission', {
        "CompNo": me?.compNo.toString(),
        "notAllowedList": notAllowedList.toString(),
        "al": al,
      }).then((dynamic value) {
        toast(value["result"].toString());
        Navigator.pop(context);
      });
    }, trans.save, trans.saveDialog, true)
        .yesOrNo();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: trans.direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(title: trans.attendanceRegistration, actions: [
          !_isBusy
              ? TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.transparent),
                    overlayColor:
                        WidgetStateProperty.all<Color>(primaryColor), //splash
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text(trans.save),
                  onPressed: _submit,
                )
              : circular,
        ]),
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
                    Container(
                      width: 70,
                      height: 80,
                      padding: EdgeInsets.zero,
                      child: Checkbox(
                        // focusColor: primaryColor,
                        value: (widget.all == 1),
                        onChanged: (val) {
                          setState(() {
                            if (widget.all == 1) {
                              widget.all = 0;
                            } else {
                              widget.all = 1;
                            }
                            for (var g in mList) {
                              g['access'] = widget.all;
                            }
                          });
                        },
                      ),
                    )
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
                          child: Container(
                            child: CheckboxListTile(
                              // activeColor: primaryColor,
                              selected: (g['access'] == 1),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Text("${g['empName']}"),
                                    ),
                                  ),
                                ],
                              ),
                              value: (g['access'] ==
                                  1), // Ensure g['access'] is not null before comparing
                              onChanged: (val) {
                                // Set access value based on the toggle state
                               if(val != null){
                                 g['access'] = val ? 1 : 0;

                                int allCount = 0;
                                for (var gg in mList) {
                                  // Check if gg['access'] is not null before comparing
                                  if (gg['access'] == 1) {
                                    allCount += 1;
                                  }
                                }

                                // Update widget.all based on the count
                                widget.all = (allCount == mList.length) ? 1 : 0;

                                // Call setState to update the UI
                                setState(() {});
                               }
                              },
                            ),
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
