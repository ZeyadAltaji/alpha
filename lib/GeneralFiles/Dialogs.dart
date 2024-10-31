import 'package:alpha/GeneralFiles/General.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

typedef IntCallback = Function(bool result);
typedef IntCallback2 = Function(bool result, String response);

class Dialogs {
  Dialogs(this.context, this.callBack, this.title, this.message, this.danger);
  final String title;
  final bool danger;
  final String message;
  final IntCallback callBack;
  final BuildContext context;

  yesOrNo() {
    return showDialog(
      barrierDismissible: true,
      useRootNavigator: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Directionality(
            textDirection: trans.direction,
            child: AlertDialog(
              elevation: 10,
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              title: Container(
                padding: const EdgeInsets.only(right: 30, top: 10, left: 30),
                child: Text(
                  title,
                  style: TextStyle(fontSize: fSize(5)),
                ),
              ),
              content: Builder(
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    width: MediaQuery.of(context).size.width,
                    child: Text(message),
                  );
                },
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              actions: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: darkTheme ? Colors.black12 : const Color(0xfff3f3f3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        danger == true
                            ? redOK(title, () {
                                Navigator.pop(context, true);
                                callBack(true);
                              })
                            : greenOK(title, () {
                                Navigator.pop(context, true);
                                callBack(true);
                              }),
                        SizedBox(
                          width: 5,
                        ),
                        danger == true
                            ? redCancel(trans.cancel, () {
                                Navigator.pop(context, false);
                                callBack(false);
                              })
                            : greenCancel(trans.cancel, () {
                                Navigator.pop(context, false);
                                callBack(false);
                              }),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Modal {
  void newModal(
      {required Widget body,required Widget actions,required String title,required BuildContext context}) {
    showDialog(
      barrierDismissible: true,
      useRootNavigator: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Directionality(
            textDirection: trans.direction,
            child: AlertDialog(
              elevation: 10,
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              title: Container(
                padding: EdgeInsets.only(right: 30, top: 10, left: 30),
                child: Text(
                  title,
                  style: TextStyle(fontSize: fSize(7)),
                ),
              ),
              content: Builder(
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: width,
                    child: body,
                  );
                },
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              actions: <Widget>[actions],
            ),
          ),
        );
      },
    );
  }
}
