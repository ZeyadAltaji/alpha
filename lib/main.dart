import 'dart:io';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/SplashScreen.dart';
import 'package:alpha/data/localdb.dart';
import 'package:alpha/models/Modules.dart';
import 'package:alpha/pages/RequestPages/GeneralRequest.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_ios/shared_preferences_ios.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
  if (Platform.isIOS) SharedPreferencesIOS.registerWith();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // RemoteNotification? notification = message.notification;
  // AndroidNotification? android = message.notification?.android;
  if ('${message.data["Type"]}' == "cr") newCR(message);
  if ('${message.data["Type"]}' == "n") newN( message);
  // if (notification != null && android != null) {
    
  // }
}
Future<void> _firebaseMessaginForeroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    if ('${message.data["Type"]}' == "cr") newCR(message);
    if ('${message.data["Type"]}' == "n") newN(message);
    if ('${message.data["Type"]}' == "m") newM(message);
    if ('${message.data["Type"]}' == "logout") doLogOut();
    if ('${message.data["Type"]}' == "refresh") refreshData();
    if ('${message.data["Type"]}' == "news") newNews(message);
  }
}
// void _firebaseMessaginForeroundHandler(RemoteMessage message) {
//   if ('${message.data["Type"]}' == "cr") newCR(message);
//   if ('${message.data["Type"]}' == "n") newN(message);
//   if ('${message.data["Type"]}' == "m") newM(message);
//   if ('${message.data["Type"]}' == "logout") doLogOut();
//   if ('${message.data["Type"]}' == "refresh") refreshData();
//   if ('${message.data["Type"]}' == "news") newNews(message);
// }
Future onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {}

Future selectNotification(NotificationResponse notificationResponse) async {}
 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   FirebaseMessaging messaging = FirebaseMessaging.instance;


    // await messaging.subscribeToTopic("hr-n-ClientNumber-1-UsersTarget-2");
    await messaging.subscribeToTopic("news");

const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
await flutterLocalNotificationsPlugin.initialize(initializationSettings);

 

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectNotification,
  );
 const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  FirebaseMessaging.onMessage.listen(_firebaseMessaginForeroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MaterialApp(
      home: SplashScreen(),
    ),
  );
}

Future<bool> initalize() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey('shortcut'))
    short = preferences.getString('shortcut')!;
  if (preferences.containsKey('imei')) {
    imei = preferences.getString('imei')!;
  } else {
 DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo; // Await the method call
    imei = androidInfo.id; 
    preferences.setString('imei', imei);
  }

  if (preferences.containsKey('fontSize'))
    fontSize = preferences.getDouble('fontSize')!;
  if (preferences.containsKey('remember')) {
    remember = preferences.getBool('remember')!;
  } else {
    preferences.setBool('remember', true);
    remember = true;
  }
  if (preferences.containsKey('byNameGroup'))
    byNameGroup = preferences.getBool('byNameGroup')!;

  if (preferences.containsKey('byDateGroup'))
    byDateGroup = preferences.getBool('byDateGroup')!;

  if (preferences.containsKey('myProtocol'))
    myProtocol = preferences.getString('myProtocol')!;

  allowNotifications = true;
  if (preferences.containsKey('allowNotifications'))
    allowNotifications = preferences.getBool('allowNotifications')!;

  allowCRNotifications = true;
  if (preferences.containsKey('allowCRNotifications'))
    allowCRNotifications = preferences.getBool('allowCRNotifications')!;

  allowMNotifications = true;
  if (preferences.containsKey('allowMNotifications'))
    allowMNotifications = preferences.getBool('allowMNotifications')!;

  if (preferences.containsKey('myCompanyNumber'))
    myCompanyNumber = preferences.getString('myCompanyNumber')!;

  if (preferences.containsKey('username'))
    username_ = preferences.getString('username')!;

  if (preferences.containsKey('password'))
    password_ = preferences.getString('password')!;

  deviceID = 'Iphone';
  fingerprint = 'Iphone Mobile';
  deviceMODEL = 'Iphone';
  deviceManufacturer = 'Apple';
  isPhysicalDevice = true;

  // androidInfo.isPhysicalDevice;
  bool logged = true;
  if (preferences.containsKey('TransDFs')) {
    transDFs = decodeTransDF(preferences.getString('TransDFs'));
  }

  if (!preferences.containsKey('empNum')) logged = false;
  if (!preferences.containsKey('compNo')) logged = false;
  if (!preferences.containsKey('darkTheme')) {
    darkTheme = false;
  } else {
    darkTheme = preferences.getBool('darkTheme')!;
  }
  if (!preferences.containsKey('gLang')) {
    gLang = "1";
  } else {
    gLang = preferences.getString('gLang')!;
  }
  if (logged == true) {
    await new DatabaseHelper2().getMenus();
  }
  serverURL = preferences.getString('sVR')!;
  compLOGO = preferences.getString('logo')!;
  companyName = preferences.getString('companyName')!;
String theme = preferences.getString('theme') ?? '1';

  if (theme == "1") {
    pc = Colors.lightBlue;
  }
  if (theme == "2") {
    pc = Colors.green;
  }
  if (theme == "3") {
    pc = Colors.grey;
  }
  if (theme == "4") {
    pc = Colors.orangeAccent;
  }
  if (theme == "5") {
    int a = int.parse(preferences.getString('themeColorA')!);
    int r = int.parse(preferences.getString('themeColorR')!);
    int g = int.parse(preferences.getString('themeColorG')!);
    int b = int.parse(preferences.getString('themeColorB')!);
    pc = Color.fromARGB(a, r, g, b);
  }
  timeDilation = 0.80;
  if (myProtocol == "https://") HttpOverrides.global = new MyHttpOverrides();
  return true;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// void _firebaseMessaginForeroundHandler(RemoteMessage message) {
//   if ('${message.data["Type"]}' == "cr") newCR(message);
//   if ('${message.data["Type"]}' == "n") newN(message);
//   if ('${message.data["Type"]}' == "m") newM(message);
//   if ('${message.data["Type"]}' == "logout") doLogOut();
//   if ('${message.data["Type"]}' == "refresh") refreshData();
//   if ('${message.data["Type"]}' == "news") newNews(message);
// }

void newCR(RemoteMessage message) {
  String empName = '${message.data["EmpName"]}';
  int fID = int.parse('${message.data["FID"]}');
  int requestType = int.parse('${message.data["RequestType"]}');
  int vacationOrLeave = int.parse('${message.data["VacationOrLeave"]}');
  String fDescAr = '${message.data["fDescAr"]}';
  DateTime addDate = DateTime.parse('${message.data["addDate"]}');
  String form = '${message.data["form"]}';
  wFrecords
      .where((x) =>
          x.fID == fID &&
          x.requestType == requestType &&
          x.empName == empName)
      .length;
  WorkFlowRecord n = new WorkFlowRecord(
      addDate: addDate,
      empName: empName,
      fID: fID,
      fDescAr: fDescAr,
      form: form,
      requestType: requestType,
      vacationOrLeave: vacationOrLeave);
  wFrecords.add(n);
  wFTypes = [];
  for (var record in wFrecords) {
    wFTypes.add(record.fDescAr!);
  }
  wFTypes = wFTypes.toSet().toList();
  provider.newWF();

  Modal().newModal(
    title: message.notification!.body!,
    context: cont!,
    actions: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(arEn('اخفاء', 'Dismiss')),
          onPressed: () {
            Navigator.pop(cont!);
          },
        ),
      ],
    ),
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(arEn('لديك طلب جديد , يرجى الموافقة او الرفض',
            'You have new request , please approve or reject')),
        Row(
          children: [
            Text('${arEn('الطلب : ', 'Request : ')}'),
            Text('${message.data["fDescAr"]}'),
          ],
        ),
        Row(
          children: [
            Text('${arEn('الموظف : ', 'Employee : ')}'),
            Text('${message.data["EmpName"]}'),
          ],
        ),
        Row(
          children: [
            Text('${arEn('التاريخ : ', 'Date : ')}'),
            Text('${message.data["addDate"]}'),
          ],
        ),
      ],
    ),
  );
}

 

void newN(RemoteMessage message) {
  try {
    if (cont != null) {
      showModalBottomSheet(
        context: cont!,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.notification?.body != null)
                  Text(
                    message.notification!.body!,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 16.0),
                Text(
                  message.data["fDescAr"] == 'c'
                      ? arEn('تمت الموافقة على طلبك', 'Your request has been approved')
                      : arEn('تم رفض طلبك', 'Your request has been rejected'),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(arEn('الطلب : ', 'Request : ')),
                    Expanded(child: Text('${message.data["fDescAr"]}')),
                  ],
                ),
                Row(
                  children: [
                    Text(arEn('المدير : ', 'Admin : ')),
                    Expanded(child: Text('${message.data["EmpName"]}')),
                  ],
                ),
                Row(
                  children: [
                    Text(arEn('التاريخ : ', 'Date : ')),
                    Expanded(child: Text('${message.data["addDate"]}')),
                  ],
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(arEn('اخفاء', 'Dismiss')),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // name
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }

    provider.newWF();
  } catch (ex) {
    print("Error in newN: $ex");
    throw ex;
  }
}


void newNews(RemoteMessage message) {
  int fID = int.parse('${message.data["FID"]}');
  String subject = '${message.data["Subject"]}';
  String description = '${message.data["fDescAr"]}';
  news.where((x) => x.srl == fID).length;
  News nwe = new News(srl: fID, description: description, subject: subject);
  news.add(nwe);
  wFNews = [];
  for (var record in news) {
    wFNews.add(record.description!);
  }
  wFNews = wFNews.toSet().toList();
  provider.newWF();

  Modal().newModal(
    title: arEn('لديك اعلان جديد', 'You have new advertisement'),
    context: cont!,
    actions: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(arEn('اخفاء', 'Dismiss')),
          onPressed: () {
            Navigator.pop(cont!);
          },
        ),
      ],
    ),
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('${arEn('الموضوع : ', 'Subject : ')}'),
                Text('${message.data["Subject"]}'),
              ],
            ),
            Row(
              children: [
                Text('${arEn('تفاصيل : ', 'Details : ')}'),
                Text('${message.data["fDescAr"]}'),
              ],
            )
          ],
        ),
      ],
    ),
  );
  provider.newWF();
}

void newM(RemoteMessage message) {
  //Id,  DateTime, ReciverNum, SenderNum, CompNo,Message,seen,GroupId,refId
  int id = int.parse('${message.data["Id"]}');
  DateTime dateTime = DateTime.parse('${message.data["DateTime"]}');
  int reciverNum = int.parse('${message.data["ReciverNum"]}');
  int senderNum = int.parse('${message.data["SenderNum"]}');
  String m = '${message.data["Message"]}';
  int seen = int.parse('${message.data["seen"]}');
//  int groupId = int.parse('${message.data["GroupId"]}');
  int refId = 0;
  //int.parse('${message.data["refId"]}');
  conversations.add(new Mssage(
    date: dateTime,
    descr: m,
    id: id,
    reciver: reciverNum,
    seen: seen,
    sender: senderNum,
    refId: refId,
  ));
  provider.newWF();
  if (chatwith != senderNum) {
    showSnackBar(cont!, arEn('رسالة جديدة', 'new message'));
  }
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await initalize().then((v) async {
//   //   if (v) {

//   await Firebase.initializeApp();
//   if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
//   if (Platform.isIOS) SharedPreferencesIOS.registerWith();
//   SharedPreferences preferences = await SharedPreferences.getInstance();

//   if ('${message.data["Type"]}' == "cr") newCR(message);
//   if ('${message.data["Type"]}' == "n") newN(message);
//   if ('${message.data["Type"]}' == "m") newM(message);
//   if ('${message.data["Type"]}' == "news") newNews(message);

//   if ('${message.data["Type"]}' == "logout") {
//     await preferences.reload();
//     myCompanyNumber = '';
//     if (preferences.containsKey('myCompanyNumber'))
//       myCompanyNumber = preferences.getString('myCompanyNumber')!;
//     await preferences.clear();
//     if (myCompanyNumber != '') {
//       preferences.setString('myCompanyNumber', myCompanyNumber);
//       exit(0);
//     }
//   }
//   if ('${message.data["Type"]}' == "refresh") {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     preferences.reload();
//     preferences.setBool('refreshData', true);
//     preferences.reload();
//   }

//   return null;
// }
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   RemoteNotification? notification = message.notification;
//   AndroidNotification? android = message.notification?.android;

//   if (notification != null && android != null) {
//     flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel', // id
//           'High Importance Notifications', // name
//           icon: '@mipmap/ic_launcher',
//         ),
//       ),
//     );
//   }
// }