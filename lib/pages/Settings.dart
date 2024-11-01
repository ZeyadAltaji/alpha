import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:alpha/ShadowText.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    // bannerSize = AdmobBannerSize.BANNER;
  }

  final serverTXT = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnController2 =
      new RoundedLoadingButtonController();
  void _submit() {
    // if (!isPhysicalDevice) {
    //   showSnackBar(context, trans.err1);
    //   _btnController.stop();
    //   _btnController2.stop();
    //   return;
    // }
    if (serverTXT.text.toString().trim() == "") {
      showSnackBar(context, trans.err2);
      _btnController.stop();
      _btnController2.stop();
      return;
    }
    if (isNumeric(serverTXT.text) == false) {
      _btnController.stop();
      _btnController2.stop();
      showSnackBar(context, trans.err3);
      return;
    }
    connectRequest();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size!.width;
    height = size!.height;
    return Directionality(
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: new Image(
                      image: AssetImage('images/login_background.png'),
                      width: double.infinity,
                      height: 120,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(
                      child: new ShadowText(
                        trans.companyNo,
                        style: TextStyle(
                            fontSize: fSize(5), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width - 40,
                        padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: TextFormField(
                          controller: serverTXT,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          maxLength: 70,
                          textAlign: trans.textAlign,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.vpn_key),
                            counterText: "",
                            labelText: trans.typeCompanyNo,
                          ),
                          style: TextStyle(
                              fontSize: fSize(3),
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  Text(trans.welcomeText),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: RoundedLoadingButton(
                          height: 40,
                          color: Colors.black,
                          child: Text(
                            trans.connect,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          controller: _btnController,
                          onPressed: _submit,
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        flex: 1,
                        child: RoundedLoadingButton(
                          controller: _btnController2,
                          height: 40,
                          color: Color(0xfff17f1f),
                          elevation: 0,
                          child: Text(
                            'Demo',
                            style: TextStyle(
                              color: Color(0xfff0f0f0),
                            ),
                          ),
                          onPressed: () {
                            connectRequest('951753');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> connectRequest([String? server]) async {
    if (server == null) server = serverTXT.text;
    final preferences = await SharedPreferences.getInstance();
    if (server == '951753') {
      preferences.setString('myCompanyNumber', '951753');
      myCompanyNumber = '951753';
    } else {
      preferences.setString('myCompanyNumber', '${serverTXT.text}');
      myCompanyNumber = '${serverTXT.text}';
    }

    serverURL = serverTXT.text.trim();

    Uri url = Uri.parse("http://gss.gcesoft.com.jo:8888/apicore/Connect");
    // Uri url = Uri.parse("http://192.168.12.64:80/API/Connect");

    var body = {
      "compNo": "$server",
      "deviceID": "$deviceID",
      "deviceMODEL": "$deviceMODEL",
      "deviceManufacturer": "$deviceManufacturer",
      "fingerprint": "$fingerprint",
    };
    try {
      var response;
      response = await http
          .post(
        url,
        headers: headers,
        body: body,
      )
          .timeout(
        Duration(seconds: 30),
        onTimeout: () {
          connectResponse('Time Out', '', '', true, '', '');
          _btnController.stop();
          _btnController2.stop();
           return http.Response('Time Out', 408); 
        },
      );
      if (response == null) {
        _btnController.stop();
        _btnController2.stop();
        connectResponse(
            '${arEn(' خطأ في الاتصال ...', 'Error at connection ...')}',
            '',
            '',
            true,
            '',
            '');
        throw Exception();
      }
      if (response.statusCode == 201 || response.statusCode == 200) {
        _btnController.stop();
        _btnController2.stop();

        try {
          var t = (json.decode(utf8.decode(response.bodyBytes)));
          connectResponse(
              t['result']['company'],
              t['result']['myURL'],
              t['result']['myProtocol'],
              t['error'],
              t['result']['adunit'],
              t['result']['image'],
              t['result']['shortcut']);
        } catch (e) {
          showSnackBar(context, translate('$e'));
        }
      } else {
        _btnController.stop();
        _btnController2.stop();
        connectResponse(
            '${arEn('يرجى التأكد من الرقم قبل الاتصال ...', 'Please verify the number before calling ...')}',
            '',
            '',
            true,
            '',
            '');
        throw Exception();
      }
    } on TimeoutException catch (error) {
      _btnController.stop();
      _btnController2.stop();
      connectResponse(error.message!, '', '', true, '', '');
    } on SocketException catch (error) {
      _btnController.stop();
      _btnController2.stop();
      connectResponse(error.osError!.message, '', '', true, '', '');
    }
  }

  void connectResponse(
      String companyN, String myURL, String myProtocol, bool r, String adunit,
      [String image = '', String shortcut = '']) async {
    _btnController.stop();
    _btnController2.stop();
    if (image != '') {
      if (r) {
        showSnackBar(context, translate(companyN));
        return;
      } else {
        saveSettings(companyN, myURL, myProtocol, image, adunit, shortcut);
      }
    } else {
      _btnController.stop();
      _btnController2.stop();
      showSnackBar(context,
          '${arEn('حدث خطأ في اعدادات الشركة', 'An error occurred in the company settings')}');
    }
  }

  void saveSettings(String companyN, String myURL, String prot, String myLogo,
      String adUnit, String shortcut) async {
    _btnController.success();
    companyName = companyN;
    if (shortcut != '') shortcut = '$shortcut@';
    WidgetsFlutterBinding.ensureInitialized();
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('sVR', myURL);
    preferences.setString('logo', myLogo);
    preferences.setString('myProtocol', prot);
    preferences.setString('companyName', companyN);
    preferences.remove('adUnit');
    preferences.setString('adUnit', adUnit);
    preferences.setString('shortcut', shortcut);
    short = shortcut;
    serverURL = preferences.getString('sVR')!;
    compLOGO = myLogo;
    myProtocol = preferences.getString('myProtocol')!;

    link = Uri.encodeFull("$myProtocol$serverURL");
    showSnackBar(
        context,
        "${arEn('تم الاتصال بنجاح', 'The connection was successful')} " +
            companyName);

    if (myProtocol == "https://") HttpOverrides.global = new MyHttpOverrides();
    Navigator.popAndPushNamed(context, "/login");
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
