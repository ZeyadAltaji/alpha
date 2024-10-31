import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePW extends StatefulWidget {
  const ChangePW({Key? key}) : super(key: key);

  @override
  State<ChangePW> createState() => _ChangePWState();
}

String password0 = '';
String password1 = '';

class _ChangePWState extends State<ChangePW> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    password0 = '';
    password1 = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: arEn('تغيير كلمة المرور', 'Change the password'), actions: []),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(25),
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.warning_amber,
                          color: Colors.yellow[800],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          arEn(
                            '''يجب تغيير كلمة المرور الافتراضية , يرجى ادخال كلمة مرور جديدة . وفقاً للشروط التالية :''',
                            '''The default password must be changed. Please enter a new password. According to the following conditions:''',
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(arEn('''
* ان تتكون من 8 احرف و كلما زاد عدد الأحرف ، كان ذلك أفضل.
* مزيج من الأحرف الكبيرة والصغيرة.
* مزيج من الحروف والأرقام.
* تضمين رموز خاصة واحدة على الأقل ، على سبيل المثال ،! @ #؟ ]''', '''
* It is 8 characters long and the more characters, the better.
* A combination of uppercase and lowercase letters.
* A combination of letters and numbers.
* Include at least one special character, for example, ! @ #? ]''')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  onChanged: (val) {
                    password0 = val.trim();
                  },
                  // obscureText: true,
                  style: TextStyle(fontSize: 14),
                  textAlign: gLang == "1" ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(right: 10, left: 10),
                    border: new OutlineInputBorder(),
                    labelText: arEn('كلمة المرور', 'Password'),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (val) {
                    password1 = val.trim();
                  },
                  // obscureText: true,
                  style: TextStyle(fontSize: 14),
                  textAlign: gLang == "1" ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(right: 10, left: 10),
                    border: new OutlineInputBorder(),
                    labelText: arEn('تأكيد كلمة المرور', 'Retype the password'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(
                      onPressed: () async {
                        new Dialogs(context, (bool r) async {
                          if (r == true) {
                            doLogOut();
                            Navigator.popAndPushNamed(context, "/login");
                          }
                        },
                                arEn('تسجيل الخروج', 'Logout'),
                                arEn(
                                    'هل تريد حقاً تسجيل الخروج من هذا المستخدم ؟',
                                    'Are you sure to logout ?'),
                                true)
                            .yesOrNo();
                      },
                      text: arEn('تسجيل الخروج', 'Logout'),
                    ),
                    Button(
                      onPressed: () async {
                        await db.excute('General', {
                          "CompNo": '${me?.compNo}',
                          "EmpNo": '${me?.empNum}',
                          "OldPass": '$password_',
                          "NewPass": '$password0',
                          "ConfirmPass": '$password1',
                          "pn": "HRP_Mobile_UpdatePasswod"
                        }).then((dynamic r) async {
                          if (!r["result"][0]['valid']) {
                            showDialog(
                                barrierDismissible: true,
                                useRootNavigator: true,
                                barrierColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) =>
                                    errorDialog(arEn(
                                      r["result"][0]['ar']
                                          .toString()
                                          .replaceAll('error - ', ''),
                                      r["result"][0]['en']
                                          .toString()
                                          .replaceAll('error - ', ''),
                                    )));
                          } else {
                            final preferences =
                                await SharedPreferences.getInstance();
                            password_ = password0;
                            preferences.setString('password', password0);
                            Navigator.popAndPushNamed(context, "/home");
                          }
                        });
                      },
                      text: arEn('حفظ', 'Save'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
