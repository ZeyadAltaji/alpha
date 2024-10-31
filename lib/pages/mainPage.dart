import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;
import 'package:alpha/ShadowText.dart';
import 'package:alpha/auth.dart';
import 'package:alpha/data/localdb.dart';
import 'package:alpha/pages/InfoPage.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/BigButton.dart';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new MainPageState();
  }
}

void doExit(bool t) {
  if (t) {
    exit(1);
  }
}

class MainPageState extends State<MainPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin
    implements AuthStateListener {
  MainPageState() {
    provider.subscribe(this);
  }

  String localPath ='';
  bool mounted = true;
  int nID = 0;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();

    _tabController = null;
    _tabController = new TabController(vsync: this, length: 1, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkUPDATE();
    });
  }

void checkUPDATE() async {
  final response0 = await http.post(
    Uri.parse('$link/General'),
    headers: headers,
    body: {
      "CompNo": '${me?.compNo}',
      "UserID": '${me?.empNum}',
      "gLang": gLang,
      "pn": "HRP_Mobile_GetMenu",
    },
  );

  if (response0.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(response0.bodyBytes));
    List data = snapshot["result"];
    subs = data.map((m) => new SubMenu.map(m)).toList();
    subs.sort((a, b) => a.id2!.compareTo(b.id2!));
    await new DatabaseHelper2().setMenus();
  }

  int isAndroid = Platform.isAndroid ? 1 : 0;
  String url =
      Uri.encodeFull("http://gss.gcesoft.com.jo:8888/apicore/UpdateApp");

  var response = await http
      .get(
        Uri.parse(
            '$url?android=$isAndroid&compNo=1&version=${int.parse(appVersion.replaceAll('.', ''))}'),
        headers: headers,
      )
      .timeout(
        Duration(seconds: 30),
        onTimeout: () => throw TimeoutException("The connection has timed out."),
      );

  if (response.statusCode == 200 || response.statusCode == 201) {
    var t = json.decode(utf8.decode(response.bodyBytes));
    int update = int.parse('${t['result'][0]['update']}');
    int mandatory = int.parse('${t['result'][0]['mandatory']}');

    if (update == 1) {
      final appStoreUrl = Platform.isAndroid
          ? 'https://play.google.com/store/apps/details?id=jo.com.gcesoft.HRV'
          : 'https://apps.apple.com/app/id1531830422';

      await showUpdateDialog(
        update: update,
        mandatory: mandatory,
        context: context,
        appStoreUrl: appStoreUrl,
      );
    } else {
      startLoad();
    }
  }
}

Future<void> showUpdateDialog({
  required int update,
  required int mandatory,
  required BuildContext context,
  required String appStoreUrl,
}) async {
  String title = 'تحديث';
  String content = mandatory == 1
      ? 'يوجد تحديث اجباري , يجب عمل تحديث حتى تتمكن من استخدام التطبيق'
      : 'يوجد تحديث , هل تريد عمل عمل تحديث ؟';

  new Dialogs(context, (bool r) async {
    if (r == true) {
      if (await canLaunch(appStoreUrl)) {
        await launch(appStoreUrl);
        if (mandatory == 1) exit(0);
      } else {
        Fluttertoast.showToast(msg: "Could not launch store URL");
      }
    } else if (mandatory == 1) {
      exit(0);
    } else {
      startLoad();
    }
  }, title, content, false).yesOrNo();
}
  // void checkUPDATE() async {
  //   final response0 = await http.post(
  //     Uri.parse('$link/General'),
  //     headers: headers,
  //     body: {
  //       "CompNo": '${me?.compNo}',
  //       "UserID": '${me?.empNum}',
  //       "gLang": gLang,
  //       "pn": "HRP_Mobile_GetMenu",
  //     },
  //   );
  //   if (response0.statusCode == 200) {
  //     dynamic snapshot = json.decode(utf8.decode(response0.bodyBytes));
  //     List data = snapshot["result"];
  //     subs = data.map((m) => new SubMenu.map(m)).toList();
  //     subs.sort((a, b) => a.id2!.compareTo(b.id2!));
  //     await new DatabaseHelper2().setMenus();
  //   }

  //   int isAndroid = 0;
  //   if (Platform.isAndroid) {
  //     isAndroid = 1;
  //   }
  //   String url =
  //       Uri.encodeFull("http://gss.gcesoft.com.jo:8888/apicore/UpdateApp");
  //   var response = await http
  //       .get(
  //           Uri.parse(url +
  //               '?android=$isAndroid&compNo=1&version=${int.parse(appVersion.replaceAll('.', ''))}'),
  //           headers: headers)
  //       .timeout(
  //     Duration(seconds: 30),
  //     onTimeout: () {
  //       throw TimeoutException("The connection has timed out."); // Throwing exception on timeout
  //     },
  //   );

  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     var t = (json.decode(utf8.decode(response.bodyBytes)));
  //     int update = int.parse('${t['result'][0]['update']}');
  //     int mandatory = int.parse('${t['result'][0]['mandatory']}');
  //     if (update == 1 && mandatory == 1) {
  //       new Dialogs(context, (bool r) {
  //         if (r == true) {
  //           LaunchReview.launch(
  //               androidAppId: 'jo.com.gcesoft.HRV', iOSAppId: '1531830422');
  //           exit(0);
  //         } else {
  //           exit(0);
  //         }
  //       },
  //               'تحديث',
  //               'يوجد تحديث اجباري , يجب عمل تحديث حتى تتمكن من استخدام التطبيق',
  //               false)
  //           .yesOrNo();
  //     }
  //     if (update == 1 && mandatory == 0) {
  //       new Dialogs(context, (bool r) {
  //         if (r == true) {
  //           LaunchReview.launch(
  //               androidAppId: 'jo.com.gcesoft.HRV', iOSAppId: '1531830422');
  //           exit(0);
  //         } else {
  //           startLoad();
  //         }
  //       }, 'تحديث', 'يوجد تحديث , هل تريد عمل عمل تحديث ؟', false)
  //           .yesOrNo();
  //     }
  //     if (update == 0 && mandatory == 0) {
  //       startLoad();
  //     }
  //   }
  // }

  void startLoad() {
    if (conversations.length == 0) {
      loadConversations();
    }
    loadBTNPER();
    loadNewsAndEvents();
  }

  @override
  void onNewNotification() {
    setState(() {});
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  @mustCallSuper
  void deactivate() {
    super.deactivate();
  }

  @mustCallSuper
  @protected
  void dispose() {
    //rewardAd.dispose();
    mounted = false;
    _tabController!.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool>? restartApp() {
    Dialogs(
            context,
            doExit,
            '${arEn('خروج', 'Exit')}',
            '${arEn('هل تريد الخروج حقاً ؟', 'Do you really want to exit?')}',
            false)
        .yesOrNo();

    return null;
  }

  void loadNewsAndEvents() async {
    companySubscribe();
    if (me == null) return;
    await http.post(
      Uri.parse('$myProtocol$serverURL/General'),
      headers: headers,
      body: {
        "CompNo": '${me!.compNo}',
        "empNum": '${me!.empNum}',
        "pn": "HRP_Mobile_UsersList"
      },
    ).then(
      (value) {
        dynamic snapshot = json.decode(utf8.decode(value.bodyBytes));
        List data = snapshot["result"];
        myEmployees = data;
      },
    );

    if (news != null && news.length > 0 ||
        wFrecords != null && wFrecords.length > 0) return;
    Uri _baseUrl = Uri.parse('$myProtocol$serverURL/notifications');
    var res = await http.post(
      _baseUrl,
      headers: headers,
      body: {
        "CompNo": '${me!.compNo}',
        "EmpNo": '${me!.empNum}',
        "Lang": gLang
      },
    );
    if (res.statusCode == 200) {
      dynamic value = json.decode(res.body);
      Iterable list = value["result"];
      Iterable d = value["news"];
      news = d.map((m) => new News.map(m)).toList();
      wFrecords = list.map((model) => WorkFlowRecord.map(model)).toList();
      for (var record in wFrecords) {
        wFTypes.add(record.fDescAr!);
      }
      setState(() {
        wFTypes = wFTypes.toSet().toList();
      });
    }
  }

  Widget myBody(BuildContext context) {
    if (myProtocol == "https://") HttpOverrides.global = new MyHttpOverrides();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.only(bottom: 20, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var menu in menus.toList())
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: ShadowText(
                          gLang == "1" ? menu.descr : menu.descrEn,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: primaryColor),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    //color: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    margin: EdgeInsets.zero,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      direction: Axis.horizontal,
                      textDirection: trans.direction,
                      spacing: 0,
                      runSpacing: 0,

                      // verticalDirection: VerticalDirection.up,
                      children: <Widget>[
                        for (var submenu
                            in subs.where((x) => x.id == menu.id).toList())
                          Container(
                            color: Colors.transparent,
                            width: bwidth * 32,
                            height: bwidth * 30,
                            padding: EdgeInsets.all(3),
                            margin: EdgeInsets.zero,
                            child: BigButton(
                              disabled: submenu.disabled == 1,
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                              // badge: '',
                              backgroundColor: primaryColor,
                              onPressed: () async {
                                Fluttertoast.cancel();
                                if (submenu.link!.length > 1) {
                                  Navigator.pushNamed(
                                    context,
                                    submenu.link!,
                                    arguments: {
                                      'id': submenu.id2.toString(),
                                      'desc': gLang == "1"
                                          ? submenu.descr
                                          : submenu.descrEn,
                                    },
                                  );
                                } else
                                  toast('Not working');
                              },
                              fontSize: fSize(4),
                              text: gLang == "1"
                                  ? submenu.descr!
                                  : submenu.descrEn!,
                              height: bwidth * 18,
                              width: bwidth * 18,
                              imagePath:
                                  '$myProtocol$serverURL/images/' + submenu.img!,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (me == null) {
      doLogOut();
    }
    if (myNews == null) {}
    cont = context;

    size = MediaQuery.of(context).size;
    width = size!.width;
    height = size!.height;

    String myIMAGE =
        "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";
    try {
      if (myIMAGE != "AA==") {
        myIMAGE = me!.img!;
      }
    } catch (e) {}

    return new WillPopScope(
      onWillPop: () => restartApp()!,
      child: Directionality(
        textDirection: trans.direction,
        child: Scaffold(
          bottomNavigationBar: AdPage(),
          appBar: appBar(
            title: trans.appTitle,
            actions: <Widget>[
              new GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/News');
                },
                child: badges.Badge(
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.red.withOpacity(0.7),
                    elevation: 0,
                  ),
                  showBadge: news.isNotEmpty,
                  position:
                      badges.BadgePosition.bottomStart(bottom: 0, start: 0),
                  badgeContent: Text(
                    '${news.length}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  child: IconButton(
                    tooltip: trans.news,
                    icon: Icon(
                      Icons.public,
                      color: (wFTypes != null && wFTypes.length > 0)
                          ? white
                          : white.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/News');
                    },
                  ),
                ),
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/workflow').then((value) async {
                    await new DatabaseHelper2().getMe();
                  });
                },
                child: badges.Badge(
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.red.withOpacity(0.7),
                    elevation: 0,
                  ),
                  showBadge: wFTypes.isNotEmpty,
                  position:
                      badges.BadgePosition.bottomStart(bottom: 0, start: 0),
                  badgeContent: Text(
                    '${wFrecords.length}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  child: IconButton(
                    tooltip: trans.workflow,
                    icon: Icon(
                      Icons.notifications_active,
                      color: (wFTypes != null && wFTypes.length > 0)
                          ? white
                          : white.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/workflow')
                          .then((value) async {
                        await new DatabaseHelper2().getMe();
                      });
                    },
                  ),
                ),
              ),
              badges.Badge(
                showBadge: conversations
                        .where((s) => s.sender != me!.empNum && s.seen == 0)
                        .length >
                    0,
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.red.withOpacity(0.7),
                  borderRadius: new BorderRadius.circular(0.0),
                  elevation: 0,
                ),
                position: badges.BadgePosition.bottomStart(bottom: 0, start: 0),
                badgeContent: Text(
                  '${conversations.where((s) => s.sender != me!.empNum && s.seen == 0).length}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "Refresh") {
                      refreshData();
                      loadNewsAndEvents();
                    }
                    if (value == "Language") {
                      changeLang(context);
                    }
                    if (value == "Team") {
                      Navigator.pushNamed(context, '/myTeam');
                    }
                    if (value == "LogOut") {
                      new Dialogs(context, (bool r) async {
                        if (r == true) doLogOut();
                      }, trans.drawer7, trans.logOutMessage, true)
                          .yesOrNo();
                    }
                  },
                  // icon: Icon(
                  //   Icons.apps,
                  //   color: white,
                  // ),
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        child: Directionality(
                          textDirection: direction,
                          child: TextButton.icon(
                              onPressed: null,
                              icon: Icon(LineIcons.syncIcon),
                              label: Text(arEn('تحديث', 'Refresh'))),
                        ),
                        value: 'Refresh'),
                    new PopupMenuItem<String>(
                        child: Directionality(
                          textDirection: direction,
                          child: TextButton.icon(
                              onPressed: null,
                              icon: Icon(LineIcons.language),
                              label: Text(arEn('اللغة', 'Language'))),
                        ),
                        value: 'Language'),
                    new PopupMenuItem<String>(
                        child: badges.Badge(
                          showBadge: conversations
                                  .where((s) =>
                                      s.sender != me!.empNum && s.seen == 0)
                                  .length >
                              0,
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.red.withOpacity(0.7),
                            borderRadius: new BorderRadius.circular(0.0),
                            elevation: 0,
                          ),
                          position: badges.BadgePosition.bottomStart(
                              bottom: 0, start: 0),
                          badgeContent: Text(
                            '${conversations.where((s) => s.sender != me!.empNum && s.seen == 0).length}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          child: Directionality(
                            textDirection: direction,
                            child: TextButton.icon(
                                onPressed: null,
                                icon: Icon(LineIcons.comments),
                                label: Text(arEn('فريق العمل', 'Team'))),
                          ),
                        ),
                        value: 'Team'),
                    new PopupMenuItem<String>(
                        child: Directionality(
                          textDirection: direction,
                          child: TextButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.power_settings_new),
                              label: Text(trans.drawer7)),
                        ),
                        value: 'LogOut'),
                  ],
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: primaryColor,
                  ),
                  accountName: (me != null)
                      ? Text(arEn(me!.empName!, me!.empEngName!))
                      : Text(''),
                  accountEmail: (me != null) ? Text(me!.username!) : Text(''),
                  currentAccountPicture: new Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10000.0),
                      child: CachedNetworkImage(
                        filterQuality: FilterQuality.high,
                        placeholderFadeInDuration: Duration(milliseconds: 300),
                        imageUrl:
                            '$myProtocol$serverURL/files/employees/${me!.compNo}/${me!.empNum}/profile.png${now.minute}',
                        placeholder: (context, url) => new SizedBox(),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                      ),
                    ),
                    width: 164.0,
                    height: 164.0,
                    padding: const EdgeInsets.all(1.5),
                    // borde width
                    decoration: new BoxDecoration(
                      color: Colors.white.withAlpha(90), // border color
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                me!.isSupervisor!
                    ? ListTile(
                        leading: Icon(LineIcons.toggleOff),
                        title:
                            Text(arEn('تسجيل الخروج للموظفين', 'Emp sign out')),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/KickOut');
                        },
                      )
                    : SizedBox(),
                me!.isSupervisor!
                    ? ListTile(
                        leading: Icon(LineIcons.lockOpen),
                        title: Text(arEn('فك ارتباط هاتف', 'Device unblock')),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/UnBlock');
                        },
                      )
                    : SizedBox(),
                (myEmployees != null && myEmployees!.length != 0)
                    ? ListTile(
                        leading: Icon(LineIcons.userLock),
                        title: Text(trans.attendanceRegistration),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/locationUsers');
                        },
                      )
                    : SizedBox(),
                (myEmployees != null && myEmployees!.length != 0)
                    ? ListTile(
                        leading: Icon(LineIcons.stamp),
                        title: Text(trans.drawer2),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/InOutLog');
                        },
                      )
                    : SizedBox(),
                (myEmployees != null && myEmployees!.length != 0)
                    ? ListTile(
                        leading: Icon(LineIcons.fingerprint),
                        title: Text(trans.drawer8),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/InOutLog2');
                        },
                      )
                    : SizedBox(),
                // ListTile(
                //   leading: Icon(Icons.calendar_today),
                //   title: Text(arEn('تقرير الموافقة والرفض', 'Workflow report')),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, '/WorkFlowReport');
                //   },
                // ),
                Divider(
                  height: 0.0,
                ),
                ListTile(
                  leading: Icon(LineIcons.userClock),
                  title: Text(trans.drawer4),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/mylog');
                  },
                ),
                ListTile(
                  leading: Icon(LineIcons.cog),
                  title: Text(trans.drawer5),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/MySettings');
                  },
                ),
                ListTile(
                  leading: Icon(LineIcons.info),
                  title: Text(trans.drawer6),
                  onTap: () {
                    final page = BubblesPage();
                    Navigator.pop(context);
                    Navigator.of(context).push(CustomPageRoute(page));
                    // Navigator.pushNamed(context, '/info').then((value) {
                    // setState(() {});
                    // });
                  },
                ),
                ListTile(
                  leading: Icon(LineIcons.powerOff),
                  title: Text(trans.drawer7),
                  onTap: () {
                    Navigator.pop(context);
                    new Dialogs(context, (bool r) async {
                      if (r == true) doLogOut();
                    }, trans.drawer7, trans.logOutMessage, true)
                        .yesOrNo();
                  },
                ),
              ],
            ),
          ),
          // backgroundColor: Colors.white,
          body: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: myBody(context),
                ),
              ],
            ),
          ),
          //bottomSheet: ad15,
        ),
      ),
    );
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
