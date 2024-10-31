import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alpha/GeneralFiles/BigButton.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;
import 'package:alpha/models/Modules.dart';
import 'package:alpha/pages/Presenter.dart';

class MySettings extends StatefulWidget {
  @override
  _MySettingsState createState() => _MySettingsState();
}

String password0 = '';
String password1 = '';
String password2 = '';

File? selectedImage;
bool image = false;
String path = '';

class _MySettingsState extends State<MySettings> {
  var pF0 = Container(
    margin: EdgeInsets.only(bottom: 5),
    child: Theme(
      data: new ThemeData(
        primaryColor: Colors.grey,
        primaryColorDark: Colors.grey,
      ),
      child: TextField(
        onChanged: (val) => password0 = val.trim(),
        obscureText: true,
        textAlign: trans.textAlign,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(right: 10, left: 10),
          border: new OutlineInputBorder(),
          labelText: trans.currentPassword,
        ),
      ),
    ),
  );

  var pF1 = Container(
    margin: EdgeInsets.only(bottom: 5),
    child: Theme(
      data: new ThemeData(
        primaryColor: Colors.grey,
        primaryColorDark: Colors.grey,
      ),
      child: TextField(
        onChanged: (val) => password1 = val.trim(),
        obscureText: true,
        textAlign: trans.textAlign,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(right: 10, left: 10),
          border: new OutlineInputBorder(),
          labelText: trans.newPassword,
        ),
      ),
    ),
  );

  var pF2 = Container(
    margin: EdgeInsets.only(bottom: 5),
    child: Theme(
      data: new ThemeData(
        primaryColor: Colors.grey,
        primaryColorDark: Colors.grey,
      ),
      child: TextField(
        onChanged: (val) => password2 = val.trim(),
        obscureText: true,
        textAlign: trans.textAlign,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(right: 10, left: 10),
          border: new OutlineInputBorder(),
          labelText: trans.confirmPassword,
        ),
      ),
    ),
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_) async => loadLog());
  }

  List<SubMenu> get myButtons => [
        new SubMenu(
            descr: '${arEn('تغيير الالوان', 'Change colors')}',
            img: 'http://gss.gcesoft.com.jo/images/artist.png'),
        new SubMenu(
            descr: '${arEn('تغيير الصورة', 'change photo')}',
            img: 'http://gss.gcesoft.com.jo/images/profile.png'),
      ];

  passWordDialog() {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Directionality(
            textDirection: trans.direction,
            child: AlertDialog(
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: Container(
                padding: EdgeInsets.only(right: 30, top: 10, left: 30),
                child: Text(
                  trans.changePassword,
                  style: TextStyle(fontSize: fSize(7)),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              content: Builder(
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    width: width * .9,
                    child: Directionality(
                      textDirection: trans.direction,
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: pF0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: pF1,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: pF2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      greenOK(trans.change, changePassword),
                      SizedBox(
                        width: 5,
                      ),
                      greenCancel(trans.cancel, () {
                        Navigator.pop(context);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> changePassword() async {
    if (password0 == '') {
      toast(
          '${arEn('يجب ادخال كلمة المرور الحالية', 'The current password must be entered')}');
      return;
    }
    if (password1 == '') {
      toast(
          '${arEn('يجب ادخال كلمة المرور الجديدة', 'The new password is required')}');
      return;
    }
    if (password2 == '') {
      toast('${arEn('يجب تأكيد كلمة المرور', 'Password must be confirmed')}');
      return;
    }
    if (password2 != password1) {
      toast(
          '${arEn('كلمة المرور الجديدة لا تطابق التأكيد', 'The new password does not match the confirmation')}');
      return;
    }
    wait(context);

    await db.excute('ChangeUserPassword', {
      "CompNo": '${me?.compNo}',
      "EmpID": '${me?.empNum}',
      "OldPassword": password0,
      "NewPassword": password1,
      "ConfPassword": password2,
      "gLang": gLang,
    }).then((dynamic value) {
      _done(value["result"], value["error"]);
    });
  }

  void _done(String msg, bool error) async {
    if (msg == "" && error) {
      setState(() {
        // _isBusy = false;
      });
      return;
    }
    msg = msg.replaceAll('error - ', '');
    msg = translate(msg);
    done(context);
    new Future.delayed(new Duration(seconds: 0), () async {
      return await showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) =>
              error ? errorDialog(msg) : successDialog(msg)).then((value) {
        if (!error) Navigator.pop(context);
      });
    });
  }

  Future<void> changeColor(Color color) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('theme', "5");
    preferences.setString('themeColorA', color.alpha.toString());
    preferences.setString('themeColorR', color.red.toString());
    preferences.setString('themeColorG', color.green.toString());
    preferences.setString('themeColorB', color.blue.toString());
    pc = color;
    new Provider().newWF();
  }

  void changeMyColor() async {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: AlertDialog(
            titlePadding: const EdgeInsets.all(0.0),
            contentPadding: const EdgeInsets.all(0.0),
            actionsPadding: EdgeInsets.zero,
            actionsOverflowButtonSpacing: 0,
            buttonPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: primaryColor,
                onColorChanged: changeColor,
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectAttachment(bool s) async {
    ImagePicker _picker = ImagePicker();
    try {
      final pickedFile = await _picker.pickImage(
        source: s ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 70,
      );
      File sFILE;
      sFILE = File(pickedFile!.path);
      if (sFILE.lengthSync() > maxSize) {
        toast(
            '${arEn('لا يمكن اختيار ملف بهذا الحجم', 'A file of this size cannot be selected')}');
        return;
      } else {
        setState(() {
          selectedImage = sFILE;
          image = true;
          List<int> imageBytes = selectedImage!.readAsBytesSync();
          path = pickedFile!.path;
          saveMyImage(base64Encode(imageBytes));
        });
      }
    } catch (e) {
      image = false;
    }
  }

  void saveMyImage(String base64Image) async {
    final response = await http.post(
      Uri.parse('$link/setImage'),
      headers: headers,
      body: {
        "CompNo": '${me?.compNo}',
        "EmpNo": '${me?.empNum}',
        "base64": '$base64Image',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        toast('${arEn('تم تحديث الصورة', 'Image has been updated')}');
      });
    } else {
      toast(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: trans.direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(title: trans.drawer5),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.only(bottom: 50, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: bwidth * 7,
                  margin: EdgeInsets.only(right: bwidth * 5, left: bwidth * 5),
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  child: Text(
                    trans.change,
                    style: TextStyle(
                      fontSize: fSize(4),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    color: Colors.transparent,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: bwidth,
                      runSpacing: bwidth,
                      children: <Widget>[
                        Container(
                          color: Colors.transparent,
                          width: bwidth * 30,
                          height: bwidth * 30,
                          padding: EdgeInsets.only(
                              left: bwidth,
                              top: bwidth,
                              bottom: bwidth,
                              right: bwidth),
                          margin: EdgeInsets.zero,
                          child: BigButton2(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            disabled: false,
                            badge: '',
                            backgroundColor: primaryColor,
                            onPressed: () async {
                              changeMyColor();
                            },
                            fontSize: fSize(4),
                            text: trans.colors,
                            height: bwidth * 18,
                            width: bwidth * 18,
                            imagePath: 'images/artist-min.png',
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          width: bwidth * 30,
                          height: bwidth * 30,
                          padding: EdgeInsets.only(
                              left: bwidth,
                              top: bwidth,
                              bottom: bwidth,
                              right: bwidth),
                          margin: EdgeInsets.zero,
                          child: BigButton2(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            disabled: false,
                            badge: '',
                            backgroundColor: primaryColor,
                            onPressed: () async {
                              passWordDialog();
                            },
                            fontSize: fSize(4),
                            text: trans.password,
                            height: bwidth * 18,
                            width: bwidth * 18,
                            imagePath: 'images/privacy-min.png',
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          width: bwidth * 30,
                          height: bwidth * 30,
                          padding: EdgeInsets.only(
                              left: bwidth,
                              top: bwidth,
                              bottom: bwidth,
                              right: bwidth),
                          margin: EdgeInsets.zero,
                          child: BigButton(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            disabled: false,
                            badge: '',
                            backgroundColor: primaryColor,
                            onPressed:  () {
                              dataSource(
                                onDone: (bool v) {
                                  _selectAttachment(v);
                                },
                              );
                            },
                            fontSize: fSize(4),
                            text: trans.photo,
                            height: bwidth * 18,
                            width: bwidth * 18,
                            imagePath:
                                '$myProtocol$serverURL/files/employees/${me?.compNo}/${me?.empNum}/profile.png${now.minute}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(
                            right: bwidth * 5, left: bwidth * 5),
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        child: Text(
                          trans.fontSize,
                          style: TextStyle(
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Slider(
                        activeColor: darkTheme
                            ? primaryColor.withOpacity(0.7)
                            : primaryColor,
                        inactiveColor: Colors.white.withOpacity(0.2),
                        value: fontSize,
                        min: 7,
                        max: 13,
                        divisions: 13,
                        label: fontSize.round().toString(),
                        onChanged: (double value) async {
                          final preferences =
                              await SharedPreferences.getInstance();
                          preferences.setDouble('fontSize', value);
                          setState(() {
                            fontSize = value;
                          });
                        },
                        onChangeEnd: (value) {
                          new Provider().newWF();
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 80,
                      child: Switch(
                        // activeThumbImage: AssetImage('images/waning-moon.png'),
                        // inactiveThumbImage: AssetImage('images/sun.png'),
                        activeTrackColor: Colors.grey,
                        activeColor: primaryColor,
                        value: darkTheme,
                        onChanged: (bool f) async {
                          darkTheme = f;
                          final preferences =
                              await SharedPreferences.getInstance();
                          preferences.setBool('darkTheme', darkTheme);
                          new Provider().newWF();
                        },
                      ),
                    ),
                    InkWell(
                      child: Row(
                        children: [
                          Icon(
                            darkTheme ? Icons.brightness_2 : Icons.wb_sunny,
                            color: darkTheme ? Colors.grey : Colors.yellow[800],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            darkTheme
                                ? trans.darkTheme
                                : arEn('الوضع المضيء', 'Light theme'),
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (darkTheme) {
                          darkTheme = false;
                        } else {
                          darkTheme = true;
                        }
                        final preferences =
                            await SharedPreferences.getInstance();
                        preferences.setBool('darkTheme', darkTheme);
                        new Provider().newWF();
                      },
                    )
                  ],
                ),
                SwitchRow(
                  iconActive: Icons.notifications_active,
                  iconNotActive: Icons.notifications_off,
                  arActive: 'اشعارات طلباتي تعمل',
                  arNotActive: 'اشعارات طلباتي لا تعمل',
                  enActive: 'Notifications working',
                  enNotActive: 'Notifications not working',
                  mkey: 'allowNotifications',
                  boo: allowNotifications,
                  function: 'n',
                ),
                SwitchRow(
                  iconActive: Icons.notifications_active,
                  iconNotActive: Icons.notifications_off,
                  arActive: 'اشعارات الموافقات تعمل',
                  arNotActive: 'اشعارات الموافقات لا تعمل',
                  enActive: 'Notifications working',
                  enNotActive: 'Notifications not working',
                  mkey: 'allowCRNotifications',
                  boo: allowCRNotifications,
                  function: 'cr',
                ),
                SwitchRow(
                  iconActive: Icons.notifications_active,
                  iconNotActive: Icons.notifications_off,
                  arActive: 'اشعارات الرسائل تعمل',
                  arNotActive: 'اشعارات الرسائل لا تعمل',
                  enActive: 'Notifications working',
                  enNotActive: 'Notifications not working',
                  mkey: 'allowMNotifications',
                  boo: allowMNotifications,
                  function: 'm',
                ),
              ],
            ),
          ),
        ),
        //bottomSheet: ad16,
      ),
    );
  }
}

class SwitchRow extends StatefulWidget {
  final IconData? iconActive;
  final IconData? iconNotActive;
  final String? arActive;
  final String? arNotActive;
  final String? enActive;
  final String? enNotActive;
  final String? function;
  final bool? boo;
  final String? mkey;
  const SwitchRow(
      {Key? key,
      this.iconActive,
      this.iconNotActive,
      this.arActive,
      this.arNotActive,
      this.enActive,
      this.enNotActive,
      this.function,
      this.mkey,
      this.boo})
      : super(key: key);

  @override
  _SwitchRowState createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          // activeTrackColor: primaryColor,
          activeColor: !darkTheme ? Colors.black : Colors.white,
          fillColor: darkTheme
              ? WidgetStateProperty.all<Color>(Colors.grey)
              : WidgetStateProperty.all<Color>(Colors.black),
          value: widget.boo,
        onChanged: (bool? f) {
            if (f != null) _handleCheckboxChange(f);
          },
        ),
        InkWell(
          child: Row(
            children: [
              Icon(
                widget.boo! ? widget.iconActive : widget.iconNotActive,
                color: widget.boo!
                    ? !darkTheme
                        ? Colors.black
                        : Colors.white
                    : Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.boo!
                    ? arEn(widget.arActive!, widget.enActive!)
                    : arEn(widget.arNotActive!, widget.enNotActive!),
                style: TextStyle(
                    fontSize: fontSize,
                    color: widget.boo!
                        ? !darkTheme
                            ? Colors.black
                            : Colors.white
                        : Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onTap: () async {
            final preferences = await SharedPreferences.getInstance();
            if (widget.boo!) {
              if (widget.function == 'n') allowNotifications = false;
              if (widget.function == 'm') allowMNotifications = false;
              if (widget.function == 'cr') allowCRNotifications = false;
              preferences.setBool(widget.mkey!, false);
              notificationUnSubscribe(widget.function!);
            } else {
              if (widget.function == 'n') allowNotifications = true;
              if (widget.function == 'm') allowMNotifications = true;
              if (widget.function == 'cr') allowCRNotifications = true;
              preferences.setBool(widget.mkey!, true);
              notificationSubscribe(widget.function!);
            }

            new Provider().newWF();
          },
        )
      ],
    );
  }
   Future<void> _handleCheckboxChange(bool f) async {
    if (widget.function == 'n') allowNotifications = f;
    if (widget.function == 'm') allowMNotifications = f;
    if (widget.function == 'cr') allowCRNotifications = f;

    final preferences = await SharedPreferences.getInstance();
    preferences.setBool(widget.mkey!, f);

    if (f) {
      notificationSubscribe(widget.function!);
    } else {
      notificationUnSubscribe(widget.function!);
    }
    setState(() {});
    new Provider().newWF();
  }
}
