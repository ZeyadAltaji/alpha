import 'dart:io';

// import 'package:admob_flutter/admob_flutter.dart';
import 'package:alpha/ShadowText.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/auth.dart';
import 'package:alpha/data/localdb.dart';
import 'package:alpha/models/Modules.dart';
import 'package:alpha/pages/Presenter.dart';
import 'package:alpha/pages/login.page.presenter.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>
    implements LoginScreenContract, AuthStateListener {
  @override
  void initState() {
    super.initState();
    // bannerSize = AdmobBannerSize.BANNER;
  }

  LoginScreenPresenter? _presenter;
  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
    provider.subscribe(this);
  }

  @override
  void onLoginError(String errorTxt) {
    _btnController.stop();
    showSnackBar(context, errorTxt);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size!.width;
    height = size!.height;

    var loginForm = new Column(
      children: <Widget>[
        SizedBox(
          height: height * 0.015,
        ),
        (compLOGO != '')
            ? new GestureDetector(
                onLongPress: () async {
                  final preferences = await SharedPreferences.getInstance();
                  preferences.remove('sVR');
                  preferences.remove('logo');
                  preferences.remove('myProtocol');
                  preferences.remove('companyName');
                  preferences.remove('adUnit');
                  serverURL = "";
                  compLOGO = '';
                  myProtocol = '';
                  new Provider().newWF();
                  Navigator.popAndPushNamed(context, '/settings');
                },
                child: new Image(
                    image: lOGO.image,
                    width: MediaQuery.of(context).size.width,
                    height: 150),
              )
            : SizedBox(),
        SizedBox(
          height: height * 0.015,
        ),
        Center(
            child: new ShadowText(
          companyName ?? '',
          style: TextStyle(fontSize: fSize(5), fontWeight: FontWeight.bold),
        )),
        SizedBox(
          height: height * 0.015,
        ),
        LoginForm(
          presenter: _presenter,
        ),
        companyName == 'شركة تجريبية' || companyName == 'Demo company'
            ? Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trans.demoMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(trans.demoUserName),
                  Text(trans.demoPassword)
                ],
              )
            : SizedBox()
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await Dialogs(
          context,
          (bool t) {
            if (t) {
              exit(0);
            }
          },
          trans.exit,
          trans.exitMessage,
          false,
        ).yesOrNo();

        return Future.value(shouldExit);
      },
      child: new Directionality(
        textDirection: trans.direction,
        child: Scaffold(
          appBar: appBar(title: trans.appTitle, actions: [
            IconButton(
                tooltip: '${arEn('تغيير اللغة', 'Change the language')}',
                icon: Icon(Icons.language, color: white),
                onPressed: () {
                  changeLang(context);
                }),
          ]),
          body: new SafeArea(
            child: new Container(
              padding: EdgeInsets.fromLTRB(width * .05, 0, width * .05, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    loginForm,
                  ],
                ),
              ),
            ),
          ),
          //bottomSheet: ad14,
        ),
      ),
    );
  }

  @override
  void onLoginSuccess(User user) async {
    // showSnackBar(context, 'تم تسجيل الدخول');
    _btnController.success();
    await new DatabaseHelper2().setMenus();
    if (weakPasswords.contains(password_)) {
      Navigator.popAndPushNamed(context, "/ChangePW");
    } else {
      Navigator.popAndPushNamed(context, "/home");
    }
  }

  @override
  void onNewNotification() {}
}

class LoginForm extends StatefulWidget {
  final LoginScreenPresenter? presenter;
  LoginForm({
    Key? key,
    this.presenter,
  }) : super(key: key);
  @override
  _LoginFormState createState() => _LoginFormState();
}

bool canLogin = false;
RoundedLoadingButtonController _btnController =
    new RoundedLoadingButtonController();

class _LoginFormState extends State<LoginForm> {
  bool showPassword = false;
 late FocusNode uFocus;
 late FocusNode pFocus;
  String? username, password;

  @override
  void initState() {
    super.initState();
    uFocus = FocusNode();
    pFocus = FocusNode();
  }

  @override
  void dispose() {
    uFocus.dispose();
    pFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final form = loginKEY.currentState;
    form!.save();
    if (username == '' || username == null) {
      uFocus.requestFocus();
      _btnController.stop();
      return;
    }

    if (password == '' || password == null) {
      pFocus.requestFocus();
      _btnController.stop();
      return;
    }

    if (form.validate()) {
      setState(() {
        FocusScope.of(context).unfocus();
      });
      form.save();
      username = username!.replaceAll(' ', '');
      password = password!.replaceAll(' ', '');
      username = username!.replaceAll('١', '1');
      username = username!.replaceAll('٢', '2');
      username = username!.replaceAll('٣', '3');
      username = username!.replaceAll('٤', '4');
      username = username!.replaceAll('٥', '5');
      username = username!.replaceAll('٦', '6');
      username = username!.replaceAll('٧', '7');
      username = username!.replaceAll('٨', '8');
      username = username!.replaceAll('٩', '9');
      username = username!.replaceAll('٠', '0');
      password = password!.replaceAll('١', '1');
      password = password!.replaceAll('٢', '2');
      password = password!.replaceAll('٣', '3');
      password = password!.replaceAll('٤', '4');
      password = password!.replaceAll('٥', '5');
      password = password!.replaceAll('٦', '6');
      password = password!.replaceAll('٧', '7');
      password = password!.replaceAll('٨', '8');
      password = password!.replaceAll('٩', '9');
      password = password!.replaceAll('٠', '0');
      if (short != '') username = username! + '@' + short.replaceAll('@', '');
      password_ = password!;
      widget.presenter!.doLogin(username!, password!, password!);
    }
  }
//192.168.12.79/API
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        new Form(
          key: loginKEY,
          child: new Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  bottom: height * 0.015,
                ),
                child: new Container(
                  child: TextFormField(
                    onChanged: (value) {
                      username = value;
                      setState(() {
                        if (username == null ||
                            username == '' ||
                            password == null ||
                            password == '') {
                          canLogin = false;
                        } else {
                          canLogin = true;
                        }
                      });
                    },
                    onSaved: (val) => username = val!.trim(),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return trans.err4;
                      }
                      return null;
                    },
                    focusNode: uFocus,
                    maxLength: 70,
                    textAlign: trans.textAlign,
                    textDirection: trans.direction,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                      ),
                      prefixIcon: Icon(Icons.supervised_user_circle),
                      counterText: "",
                      labelText: trans.username,
                      prefixText: short,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: height * 0.015,
                ),
                child: TextFormField(
                  onChanged: (value) {
                    password = value;

                    setState(() {
                      if (username == null ||
                          username == '' ||
                          password == null ||
                          password == '') {
                        canLogin = false;
                      } else {
                        canLogin = true;
                      }
                    });
                  },
                  onSaved: (val) => password = val!.trim(),
                  validator: (val) {
                    return val!.length < 1 ? trans.err5 : null;
                  },
                  focusNode: pFocus,
                  obscureText: !this.showPassword,
                  textAlign: trans.textAlign,
                  textDirection: trans.direction,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryColor,
                      ),
                    ),
                    labelText: trans.password,
                    prefixIcon: Icon(Icons.security),
                    suffixIcon: IconButton(
                      icon: Icon(
                        this.showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => this.showPassword = !this.showPassword);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        new Center(
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      if (remember == false) {
                        remember = true;
                      } else {
                        remember = false;
                      }
                    });
                    var preferences = await SharedPreferences.getInstance();
                    preferences.setBool('remember', remember);
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        focusColor: primaryColor,
                        onChanged: (value) async {
                          setState(() {
                            if (remember == false) {
                              remember = true;
                            } else {
                              remember = false;
                            }
                          });
                          var preferences =
                              await SharedPreferences.getInstance();
                          preferences.setBool('remember', remember);
                        },
                        value: remember == true ? true : false,
                        activeColor: primaryColor,
                      ),
                      Text(trans.remmemberData),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: RoundedLoadingButton(
                  height: 40,
                  color: primaryColor,
                  child: Text(
                    trans.login,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  controller: _btnController,
                  onPressed: canLogin ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
