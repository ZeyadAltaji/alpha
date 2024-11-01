import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/auth.dart';
import 'package:alpha/data/ApiBaseHelper.dart';
import 'package:alpha/data/localdb.dart';
import 'package:alpha/models/DBHelper.dart';
import 'package:alpha/pages/Presenter.dart';
import 'package:bubble/bubble.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as format;
import 'package:alpha/models/Modules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

String macAddress = 'Unknown';
bool byNameGroup = true;
bool byDateGroup = true;
String myCompanyNumber = '';
// ignore: non_constant_identifier_names
var ADlist = [];
final _random = new Random();
String adUnitdId = ADlist[_random.nextInt(ADlist.length)];

String get adUnitId => isInDebugMode
    ? 'ca-app-pub-3940256099942544/6300978111'
    : (Platform.isIOS)
        ? 'ca-app-pub-5618954201464445/2320765833'
        : 'ca-app-pub-5618954201464445/9177818227';
String get appVersion => "1.10.1";
List<String> get whatsNew => gLang == "1" ? whatsNewAr : whatsNewEn;
Locale get local => gLang == "1" ? Locale("ar", "JO") : Locale("en", "US");
List<String> get whatsNewAr => [
      'ما الجديد :',
      'طلب مهمة عمل',
      'طلب مباشرة عمل',
      'تحسين الأداء',
    ];
List<String> get whatsNewEn => [
      "What's new :",
      'Job mission request',
      'work start request',
      'Performance improvement',
    ];

LinearGradient get twoColors => LinearGradient(
    colors: darkTheme
        ? [
            Colors.black.withOpacity(0.2),
            primaryColor,
          ]
        : [
            Colors.white.withOpacity(.5),
            primaryColor,
          ],
    begin: const FractionalOffset(0.0, 0.0),
    end: const FractionalOffset(1.0, 0.0),
    stops: const [0.0, 1.0],
    tileMode: TileMode.clamp);
AuthStateProvider provider = new AuthStateProvider();
bool remember = true;

ApiBaseHelper get db => new ApiBaseHelper();
GlobalKey<FormState> loginKEY = new GlobalKey<FormState>();
GlobalKey<FormState> salaryKEY = new GlobalKey<FormState>();
GlobalKey<FormState> dayOffKEY = new GlobalKey<FormState>();
GlobalKey<FormState> leaveKEY = new GlobalKey<FormState>();
GlobalKey<FormState> itKEY = new GlobalKey<FormState>();
GlobalKey<FormState> insuranceKEY = new GlobalKey<FormState>();
GlobalKey<FormState> generalKEY = new GlobalKey<FormState>();
GlobalKey<FormState> fingerKEY = new GlobalKey<FormState>();
GlobalKey<FormState> extraKEY = new GlobalKey<FormState>();
GlobalKey<FormState> bonusKEY = new GlobalKey<FormState>();
GlobalKey<FormState> advanceKEY = new GlobalKey<FormState>();
bool darkTheme = false;
bool allowCRNotifications = true;
bool allowNotifications = true;
bool allowMNotifications = true;
List<WorkFlowRecord> wFrecords = [];
List<News> news = [];
List<String> wFTypes = [];
List<String> wFNews = [];

List? myEmployees;
TextStyle get bold =>
    TextStyle(fontSize: fSize(0), fontWeight: FontWeight.bold);
List<int> get months => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
List<int> get yearsList {
  List<int> y = [];
  for (var i = 0; i < 10; i++) {
    y.add(DateTime.now().year - i);
  }
  return y;
}

Widget get noData => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 60,
          ),
          Text(
            arEn('لا يوجد بيانات', 'No Data'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
void changeLang(BuildContext context) {
  new Dialogs(context, (bool r) async {
    if (r == true) {
      recordedStamps.clear();
      if (gLang == "1") {
        gLang = "2";
      } else {
        gLang = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('gLang', gLang);
      new Provider().newWF();
    }
  },
          '${arEn('تغيير اللغة', 'Change language')}',
          '${arEn('هل تريد تغيير اللغة للانجليزية ؟', 'Do you want to change the language to Arabic ?')}',
          true)
      .yesOrNo();
}

TextDirection get direction => trans.direction;
String arEn(String ar, String en) => trans.arEn(ar, en);
List<String> recordedStamps = [];

Future<List<String>> getStamp() async {
  if (recordedStamps.isNotEmpty) return recordedStamps;
  List<String> f = [];
  await db.excute('General', {
    "CompNo": '${me?.compNo}',
    "EmpNo": '${me?.empNum}',
    "Lang": '$gLang',
    "pn": "HRP_Mobile_GetAttendance"
  }).then((dynamic r) {
    List t = r['result'];
    for (var tm in t) {
      String inOut = "";
      if (tm['checkIn'] == 0) {
        inOut = arEn('دخول', 'In');
      } else if (tm['checkIn'] == 2) {
        inOut = arEn('مغادرة', 'Leave');
      } else {
        inOut = arEn('خروج', 'Out');
      }
      String time = tm['time'];
      String date = tm['date'];
      String ro =
          '${arEn('تسجيل', 'Register')} $inOut ${arEn('الساعة', 'on')} $time ${arEn('بتاريخ', 'Dated')} $date';
      f.add(ro);
    }
  });
  recordedStamps = f;
  return f;
}

void setStamp(String x) async {
  var preferences = await SharedPreferences.getInstance();

  List<String>? l = [];
  if (preferences.containsKey('times')) {
    l = preferences.getStringList('times');
  }
  if (l!.length >= 60) {
    l.removeAt(0);
  }
  l.add(x);
  preferences.setStringList('times', l);
}

Future<List> getMyMissions() async {
  List t = [];
  await db.excute('General', {
    "CompNo": '${me?.compNo}',
    "EmpNo": '${me?.empNum}',
    "pn": "HRP_Mobile_MyMissions"
  }).then((dynamic r) {
    t = r['result'];
  });
  return t;
}

Widget get circular => Padding(
      padding: const EdgeInsets.all(5.0),
      child: new CircularProgressIndicator(
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        strokeWidth: 2,
      ),
    );
bool offLine = false;
bool get showNotifications => wFrecords.length == 0 ? false : true;
format.DateFormat get timeFormat => new format.DateFormat('hh:mm a');
format.DateFormat get timeFormat2 => new format.DateFormat('hh:mm:ss a');
format.DateFormat get timeFormat24 => new format.DateFormat('HH:mm');
format.DateFormat get dateFormat => new format.DateFormat('yyyy-MM-dd');
format.DateFormat get dateFormat2 => new format.DateFormat('yyyy/MM/dd');
format.DateFormat get datetimeFormat =>
    new format.DateFormat('yyyy-MM-ddThh:mm:ss');
format.DateFormat get dtFormat => new format.DateFormat('yyyy-M-d (h:mm)');
int canUseFP = 0;
int canUseAD = 0;
int canUseINC = 0;
void loadBTNPER() async {
  if (me == null) return;

  await db.excute('General', {
    "CompNo": '${me?.compNo}',
    "empNum": '${me?.empNum}',
    "pn": "HRP_Mobile_FP"
  }).then((dynamic r) {
    canUseFP = r["result"][0]['fp'];
    canUseAD = r["result"][0]['ad'];
    canUseINC = r["result"][0]['inc'];
  });
}

String dayName(DateTime n) {
  if (n.weekday == 6 && gLang == "1") return 'السبت';
  if (n.weekday == 7 && gLang == "1") return 'الاحد';
  if (n.weekday == 1 && gLang == "1") return 'الاثنين';
  if (n.weekday == 2 && gLang == "1") return 'الثلاثاء';
  if (n.weekday == 3 && gLang == "1") return 'الاربعاء';
  if (n.weekday == 4 && gLang == "1") return 'الخميس';
  if (n.weekday == 5 && gLang == "1") return 'الجمعة';
  if (n.weekday == 6 && gLang == "2") return 'Saturday';
  if (n.weekday == 7 && gLang == "2") return 'Sunday';
  if (n.weekday == 1 && gLang == "2") return 'Monday';
  if (n.weekday == 2 && gLang == "2") return 'Tuesday';
  if (n.weekday == 3 && gLang == "2") return 'Wednesday';
  if (n.weekday == 4 && gLang == "2") return 'Thursday';
  if (n.weekday == 5 && gLang == "2") return 'Friday';
  return '';
}

bool isNumeric(String s) {
  return double.parse(s) != null;
}

int get randomInt => Random().nextInt(pow(2, 31).toInt());
double width = 0;
double height = 0;
double get bwidth => width / 100;
double get bheight => height / 100;

Size? size;
List<News>? myNews;
String truncate(String s, int truncateAt) {
  if (s.length <= truncateAt) {
    return s;
  }
  String elepsis = "...";
  String truncated = "";
  truncated = s.substring(0, truncateAt - elepsis.length) + elepsis;
  return truncated.toString();
}

String username_ = '';
String password_ = '';
List<String> get weakPasswords => ['212', '002', '123', '454', '333'];
// List<String> get weakPasswords => [];
PreferredSizeWidget appBar(
    {required String title,
     List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool? back}) {
  if (back == null) back = true;
  return AppBar(
    automaticallyImplyLeading: back,
    // backgroundColor: Colors.transparent,
    // shadowColor: Colors.transparent,
    bottom: bottom,
    iconTheme: IconThemeData(color: Colors.white),
    title: Text(
      title,
      style: TextStyle(fontSize: fontSize + 3, color: Colors.white),
    ),
    centerTitle: true,
    actions: actions,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: twoColors,
      ),
    ),
  );
}

void startSignalR() {
  //
}

bool noti = false;

BuildContext? cont;
Future onSelectNotification(String payload) async {
  if (noti && cont != null) {
    Navigator.of(cont!).pushNamed('/workflow');
  }
}

Future onSelectAlert(String payload) async {
  if (noti && cont != null) {
    Navigator.of(cont!).pushNamed('/mylog');
  }
}

PopupMenuItem pop(int id, String text) {
  return PopupMenuItem(
    value: id,
    child: Container(
      width: double.infinity,
      child: Container(
        child: Text(text),
      ),
    ),
  );
}

void dataSource({ValueChanged<bool>? onDone}) {
  showDialog(
    barrierColor: Colors.transparent,
    context: cont!,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Directionality(
          textDirection: direction,
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
                arEn('اختر مصدر البيانات', 'choose data source'),
                style: TextStyle(fontSize: fSize(7)),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            content: Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: width,
                        child: Text(arEn('اختر مصدر البيانات لرفع الصور',
                            'choose data source to upload your files')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Directionality(
                textDirection:
                    gLang == "1" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      greenOK('${arEn('الكاميرا', 'CAMERA')}', () {
                        Navigator.pop(context);
                        onDone!(true);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                      greenOK('${arEn('الاستوديو', 'GALLERY')}', () {
                        Navigator.pop(context);
                        onDone!(false);
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

String errorMSG = '';
Color gren = Color(0xff00875f);
Color lightGren = Color(0xff2b9a79);
Color white = Colors.white;
Color black = Colors.black;
Color transparent = Colors.transparent;
Color ogrentext = Color(0xff0b815e);
Color olightGren = Color(0xffa8d6c9);
String compLOGO = '';
Uint8List get bytes => base64Decode(compLOGO);
Image get lOGO => Image.memory(bytes);
int maxFileSize = 1;
int get maxSize => maxFileSize * 1048576;
String fingerprint = '';
String deviceID = '';
String deviceMODEL = '';
String deviceManufacturer = '';
bool isPhysicalDevice = false;
String imei = '';
double attchmentWidth = 0;
double attchmentHeight = 0;
Color pc = Color.fromARGB(255, 3, 169, 244);
Color get secondaryColor => Color.fromARGB(255, 255 - primaryColor.red,
    255 - primaryColor.green, 255 - primaryColor.blue);
Color get primaryColor => darkTheme ? pc.withAlpha(50) : pc;
String serverURL = '';
String myProtocol = 'http://';
int chatwith = 0;
String companyName = '';
DateTime get now => DateTime.now();
String link = Uri.encodeFull("$myProtocol$serverURL");

List<DefValue> defValues = [];
bool language = true;
String gLang = "2";

User? me;
bool get isDemo {
  if (me == null) return true;
  if (me?.empNum == 1 && me?.compNo == 1555 && myCompanyNumber == '951753')
    return true;
  return false;
}

User get getme => me!;
String short = '';

List<Menu> menus = [];

List<SubMenu> subs = [];
double fontSize = 10;
double fSize([double x = 0]) => fontSize + x;
Map<String, String> get headers => {
      'Authorization': 'Basic UG93ZXJlZC1CeSA6IEhhc2FuIEFidSBHaGFseW91bg==',
      "Content-Type": "application/x-www-form-urlencoded",
      "UserName": "${me == null ? 0 : me?.empNum}",
      "CompanyNo": "${me == null ? 0 : me?.compNo}",
      "Version": "$appVersion",
    };

void toast(String msg, [Color color = Colors.red]) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: '$msg',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: fSize(4));
}

bool isArabic(String string) =>
    string.contains(new RegExp(r'^[\u0621-\u064A]'));

void showSnackBar(BuildContext context, String text) {
  text = translate(text);
  try {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        backgroundColor: !darkTheme ? Color(0xff424242) : Colors.white,
        content: new Text(
          text,
          style: new TextStyle(
            color: darkTheme ? Color(0xff424242) : Colors.white,
          ),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    toast(text);
  }
}

String translate(String s) {
  if (gLang == "1") return s;
  if (s == "لا يمكنك تسجيل الدوام عن بعد")
    s = "You cannot register attendance remotely";
  if (gLang == "1") return s;
  if (s == "يرجى تحديث النسخة من المتجر")
    s = "Please update the app from the store";
  if (s == "يرجى تسجيل الدوام من هاتف الموظف نفسه")
    s = "Please try from the employee's phone himself";

  if (s == "تم ارسال طلبك") s = "Your request has been sent";
  if (s == "تم حظرك من الاتصال") s = "You have been blocked";
  if (s == "الشركة تجاوزت عدد المستخدمين")
    s = "The company has exceeded the number of users";
  if (s == "هذا الرقم غير صحيح , يرجى التأكد من الرقم قبل المحاولة مجدداً")
    s = "This number is incorrect, please check the number before trying again";
  if (s == "لا يمكنك تسجيل الدوام من هذا الموقع")
    s = "You cannot register from this location";
  if (s == "كلمة المرور خاطئة") s = "wrong password";
  if (s == "اسم الدخول غير مسجل") s = "Login name not registered";
  if (s == "طلب احتساب عمل اضافي") s = "Request for additional work";
  if (s.trim() == "تم حذف الطلب") s = "The request has been deleted";
  if (s.trim() == "تم ارسال طلب الغاء")
    s = "A cancellation request has been sent";
  return s;
}

wait(BuildContext context, [String message = "يرجى الانتظار"]) async {
  if (message == "يرجى الانتظار") {
    message = arEn("يرجى الانتظار", "Please wait");
  }
  if (isWaiting) {
    Navigator.pop(context);
    isWaiting = false;
    return;
  }
  isWaiting = true;
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing the dialog
    barrierColor: Colors.black54, // Sets a transparent black background
    useRootNavigator: false,
    builder: (BuildContext ctx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15.0),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SpinKitPouringHourGlass(
                  color: primaryColor, // Make sure primaryColor is defined
                  size: 35.0,
                  duration: Duration(milliseconds: 800),
                ),
              ),
              SizedBox(height: 15.0),
              Center(child: Text(message, style: TextStyle(fontSize: 16))), // Text style can be adjusted
              SizedBox(height: 15.0),
            ],
          ),
        ),
      );
    },
  );
}

bool isWaiting = false;
void done(BuildContext context) {
  if (isWaiting) {
    Navigator.pop(context);
    isWaiting = false;
  }
}

void reportError(String error) async {
  var url = Uri.tryParse("http://gss.gcesoft.com.jo:8888/apicore6/general");
  await http.post(
    url!,
    headers: headers,
    body: {
      "Client": '$companyName',
      "CompNo": '${me?.compNo}',
      "empNum": '${me?.empNum}',
      "error": '$error',
      "pn": "HRP_Mobile_Errors"
    },
  ).then(
    (value) {
      toast(
        arEn(
          'تم ارسال التقرير وسيتم العمل على حل المشكلة',
          'The report has been sent and the issue will be resolved',
        ),
      );
    },
  );
}

void Function(int)? callbackx;

successDone(BuildContext context, [String msg = ""]) async {
  Navigator.pop(context);
  new Future.delayed(new Duration(seconds: 0), () async {
    if (msg != "") {
      return await showDialog(
          barrierDismissible: false,
          useRootNavigator: false,
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) => successDialog(msg));
    }
  });
}

void errorDone(BuildContext context, [String msg = ""]) {
  new Future.delayed(new Duration(seconds: 0), () async {
    Navigator.pop(context);
    if (msg != "") {
      return showDialog(
          barrierDismissible: false,
          useRootNavigator: false,
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) => errorDialog(msg));
    }
  });
}

void msgBox(String message) {
  new Future.delayed(new Duration(seconds: 0), () async {
    return showDialog(
        barrierDismissible: true,
        useRootNavigator: false,
        barrierColor: Colors.transparent,
        context: cont!,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(cont!);
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Directionality(
                textDirection: trans.direction,
                child: Container(
                    width: 300.0,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 15.0),
                          Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 40.0,
                          ),
                          new Padding(
                            padding: EdgeInsets.only(
                                right: 10, left: 10, top: 15, bottom: 15),
                            child: new Text(
                              message,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          );
        });
  });
}

Future<bool> isConnected(String mylink) async {
  try {
    final result = await InternetAddress.lookup(mylink);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    // errorDone('لم ينجح الاتصال بالخادم');
    return false;
  }
  return false;
}

BackdropFilter errorDialog(String msg) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
    child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(cont!);
        },
        child: Directionality(
          textDirection: direction,
          child: Container(
              width: 300.0,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 15.0),
                    Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 40.0,
                    ),
                    new Padding(
                      padding: EdgeInsets.only(
                          right: 10, left: 10, top: 15, bottom: 15),
                      child: new Text(
                        msg,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    ),
  );
}

BackdropFilter successDialog(String msg) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
    child: Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: GestureDetector(
        onTap: () {
          Navigator.pop(cont!);
        },
        child: Directionality(
          textDirection: direction,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              width: 300.0,
              child: Container(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 15.0),
                    Icon(
                      Icons.done,
                      color: Colors.green,
                      size: 40.0,
                    ),
                    new Padding(
                      padding: EdgeInsets.only(
                          right: 10, left: 10, top: 15, bottom: 15),
                      child: new Text(
                        msg,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    ),
  );
}

bool boolParse(String v) {
  if (v == "1" || v.toLowerCase() == "true") {
    return true;
  } else {
    return false;
  }
}

void loadConversations() async {
  if (me == null) return;
  int lastId = 0;
  conversations = await DBHelper().getMessages();
  if (conversations.length > 0) {
    conversations.sort((a, b) => a.id!.compareTo(b.id!));
    lastId = conversations.last.id!;
  }
  Uri _baseUrl = Uri.parse('$link/General');
  final response = await http.post(
    _baseUrl,
    headers: headers,
    body: {
      "CompNo": '${me?.compNo}',
      "Emp_num": '${me?.empNum}',
      "LastId": '$lastId',
      "pn": "HRP_Mobile_MyConversations",
    },
  );
  if (response.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(response.bodyBytes));
    List data = snapshot["result"];
    List<Mssage> conv = data.map((m) => new Mssage.map(m)).toList();
    for (var ms in conv) {
      await DBHelper().savemessage(ms);
      conversations.add(new Mssage(
          date: ms.date,
          descr: ms.descr,
          id: ms.id,
          reciver: ms.reciver,
          refId: ms.refId,
          seen: ms.seen,
          sender: ms.sender));
    }
  }
}

extension MyDateUtils on DateTime {
  DateTime copyWith(
      {int? year,
      int? month,
      int? day,
      int? hour,
      int? minute,
      int? second,
      int? millisecond,
      int? microsecond}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

// class AlphaStyleInformation extends DefaultStyleInformation {
//   const AlphaStyleInformation({
//     bool htmlFormatContent = true,
//     bool htmlFormatTitle = true,
//   }) : super(htmlFormatContent, htmlFormatTitle);
// }

double px = 1 / MediaQuery.of(cont!).devicePixelRatio;
List<Mssage> conversations = [];
BubbleStyle get styleSomebody => BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.green,
      elevation: 2 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );
BubbleStyle get styleMe => BubbleStyle(
      nip: BubbleNip.rightTop,
      shadowColor: primaryColor,
      color: Colors.blue,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
    );
Future<List<Colleague>> getColleagues() async {
  List<Colleague> l = [];
  final preferences = await SharedPreferences.getInstance();
  int? c = preferences.getInt('ColleagueCount');
  if (c == null) c = 0;
  for (var i = 0; i < c; i++) {
    l.add(new Colleague(
      empname: preferences.getString('ColleagueEmpname$i'),
      empnum: preferences.getInt('ColleagueEmpnum$i'),
      image:
          '$myProtocol$serverURL/files/employees/${me?.compNo}/${preferences.getInt('ColleagueEmpnum$i')}/profile.png',
      sort: preferences.getInt('ColleagueSort$i') ?? 0,
      room: preferences.getInt('ColleagueRoom$i') ?? 1,
    ));
  }
  return l;
}

void removeColleague() async {
  final preferences = await SharedPreferences.getInstance();
  int? c = preferences.getInt('ColleagueCount');
  if (c == null) c = 0;
  for (var i = 0; i < c; i++) {
    preferences.remove('ColleagueEmpname$i');
    preferences.remove('ColleagueEmpnum$i');
    preferences.remove('ColleagueSort$i');
    preferences.remove('ColleagueRoom$i');
  }
  preferences.remove('ColleagueCount');
}

void refreshData() async {
  Uri _baseUrl = Uri.parse('$link/General');
  var defs = await http.post(_baseUrl,
      headers: headers,
      body: {"CompNo": '${me?.compNo}', "pn": "HRP_Mobile_Def"});
  if (defs.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(defs.bodyBytes));
    List res = snapshot["result"];
    defValues = res.map((m) => new DefValue.map2(m)).toList();
  }

  var gMenu = await http.post(_baseUrl, headers: headers, body: {
    "gLang": gLang,
    "UserID": "${me?.empNum}",
    "CompNo": '${me?.compNo}',
    "pn": "HRP_Mobile_GetMenu"
  });
  if (gMenu.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(gMenu.bodyBytes));
    List res = snapshot["result"];
    subs = res.map((m) => new SubMenu.map(m)).toList();
  }

  var gMainMenu = await http.post(_baseUrl, headers: headers, body: {
    "gLang": gLang,
    "CompNo": '${me?.compNo}',
    "pn": "HRP_Mobile_GetMainMenu"
  });
  if (gMainMenu.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(gMainMenu.bodyBytes));
    List res = snapshot["result"];
    menus = res.map((m) => new Menu.map(m)).toList();
  }
  await new DatabaseHelper2().setMenus();
  new Provider().newWF();
}

ButtonTheme greenOK(String text, VoidCallback onPressed) =>
    mkButton(text, onPressed, gren, lightGren, white);

ButtonTheme redOK(String text, VoidCallback onPressed) =>
    mkButton(text, onPressed, Color(0xffc81c34), Color(0xffd04054), white);

ButtonTheme greenCancel(String text, VoidCallback onPressed) =>
    mkButton(text, onPressed, Colors.transparent, olightGren, ogrentext);

ButtonTheme redCancel(String text, VoidCallback onPressed) => mkButton(
    text, onPressed, Colors.transparent, Color(0xffecb1c5), Color(0xffbf2056));

ButtonTheme mkButton(
    String text, VoidCallback  onPressed, Color f, Color s, Color t) {
  return ButtonTheme(
    padding: EdgeInsets.zero,
    child: TextButton(
      child: Text(text),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(f),
        overlayColor: WidgetStateProperty.all<Color>(s),
        foregroundColor: WidgetStateProperty.all<Color>(t),
      ),
      onPressed: onPressed,
    ),
  );
}

class CustomPageRoute<T> extends PageRoute<T> {
  CustomPageRoute(this.child);
  @override
  Color get barrierColor => Colors.black;

  @override
  String? get barrierLabel => null;

  final Widget child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}

String fireBaseTopic(String channel) =>
    "hr-$myCompanyNumber-${me?.compNo}-${me?.empNum}";

Future<void> notificationSubscribe(String channel) async {
  String key = fireBaseTopic(channel);
  if (!Platform.isWindows)
    await FirebaseMessaging.instance.subscribeToTopic(key);
}

Future<void> companySubscribe() async {
  String key = "hr-$myCompanyNumber";
  if (!Platform.isWindows)
    await FirebaseMessaging.instance.subscribeToTopic(key);
}

Future<void> companyUnSubscribe() async {
  String key = "hr-$myCompanyNumber";
  if (!Platform.isWindows)
    await FirebaseMessaging.instance.unsubscribeFromTopic(key);
}

Future<void> notificationUnSubscribe(String channel) async {
  String key = fireBaseTopic(channel);
  if (!Platform.isWindows)
    await FirebaseMessaging.instance.unsubscribeFromTopic(key);
}

void doLogOut() async {
  notificationUnSubscribe('m');
  notificationUnSubscribe('n');
  notificationUnSubscribe('cr');
  notificationUnSubscribe('logout');
  notificationUnSubscribe('refresh');
  companyUnSubscribe();
  news.clear();
  conversations.clear();

  if (companyName == 'شركة تجريبية' || companyName == 'Demo company') {
    me = null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('sVR');
    preferences.remove('logo');
    preferences.remove('myProtocol');
    preferences.remove('companyName');
    preferences.remove('empNum');
    preferences.remove('compNo');
    preferences.remove('username');
    preferences.remove('password');
    preferences.remove('defaultDate');
    preferences.remove('empName');
    preferences.remove('empEngName');
    preferences.remove('isSupervisor');
    preferences.remove('isInterviewer');
    preferences.remove('clientNo');
    preferences.remove('isResigned');
    preferences.remove('socialNo');
    preferences.remove('img');
    preferences.reload();
    wFrecords.clear();
    news.clear();
    wFTypes.clear();
    wFNews.clear();
    removeColleague();
    new DBHelper().delete();
    if (cont != null) Navigator.popAndPushNamed(cont!, "/settings");
  } else {
    me = null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('empNum');
    preferences.remove('compNo');
    preferences.remove('username');
    preferences.remove('password');
    preferences.remove('defaultDate');
    preferences.remove('empName');
    preferences.remove('empEngName');
    preferences.remove('isSupervisor');
    preferences.remove('isInterviewer');
    preferences.remove('clientNo');
    preferences.remove('isResigned');
    preferences.remove('socialNo');
    preferences.remove('img');
    preferences.reload();
    wFrecords.clear();
    news.clear();
    wFTypes.clear();
    wFNews.clear();
    removeColleague();

    if (cont != null) Navigator.popAndPushNamed(cont!, "/login");
  }
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);

  return inDebugMode;
}

class AdPage extends StatefulWidget {
  const AdPage({Key? key}) : super(key: key);

  @override
  _AdPageState createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      child: IgnorePointer(
        ignoring: !canClickAd,
        child: Container(
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

bool get canClickAd {
  final seconds = DateTime.now().difference(lastclickOn).inSeconds;
  bool heClickToday = lastclickOn.year == now.year &&
      lastclickOn.month == now.month &&
      now.day == lastclickOn.day;
  if (seconds <= 60) {
    // Block directly No1
    return false;
  }
  if (heClickToday && clicks >= 2) {
    // Block directly No2
    return false;
  }
  return true;
}

int clicks = 0;
DateTime lastclickOn = DateTime.now().add(Duration(days: -1));

List? absenceData;
List? delaysData;
List? forgetStampsData;
List? otherUsers;
String fixed(double value) {
  return value.toStringAsFixed(2);
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

Widget rowBlock({
  String? label,
  Function(String value)? onChanged,
  int lines = 1,
  TextInputType keyboardType = TextInputType.text,
  int maxLength = 150,
  bool border = false,
  String defaultString = '',
  bool paste = false,
  eid,
  Widget? child,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label!,
          ),
        ),
        child == null
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: TextEditingController(text: defaultString),
                    onChanged: onChanged,
                    maxLines: lines,
                    maxLength: maxLength,
                    keyboardType: keyboardType,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: border
                          ? OutlineInputBorder()
                          : UnderlineInputBorder(),
                      counterText: "",
                      labelText: label,
                    ),
                    style: TextStyle(
                        fontSize: fSize(3), fontWeight: FontWeight.normal),
                  ),
                ),
              )
            : child,
        paste
            ? Container(
                width: 30,
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero),
                  ),
                  child: Icon(
                    Icons.paste,
                  ),
                  onPressed: () {},
                ),
              )
            : SizedBox(),
      ],
    ),
  );
}
