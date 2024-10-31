import 'package:alpha/models/Modules.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper2 {
  Future<void> setMenus() async {
    final preferences = await SharedPreferences.getInstance();

    preferences.setBool('isSupervisor', me!.isSupervisor!);
    preferences.setBool('isInterviewer', me!.isInterviewer!);
    preferences.setBool('isResigned', me!.isResigned!);
    preferences.setString('sVR', serverURL);
    preferences.setString('username', me!.username!);
    preferences.setString('empName', me!.empName!);
    preferences.setString('empEngName', me!.empEngName!);
    preferences.setString('img', me!.img!);
    preferences.setString('socialNo', me!.socialNo!);
    preferences.setInt('compNo', me!.compNo!);
    preferences.setInt('empNum', me!.empNum!);
    preferences.setInt('clientNo', me!.clientNo!);
    preferences.setInt('defValuesCount', defValues.length);
    preferences.setInt('menusCount', menus.length);
    preferences.setInt('subsCount', subs.length);

    for (var i = 0; i < menus.length; i++) {
      preferences.setInt('menusId$i', menus[i].id!);
      preferences.setString('menusDescr$i', menus[i].descr!);
    }

    for (var i = 0; i < subs.length; i++) {
      preferences.setInt('subsId$i', subs[i].id!);
      preferences.setInt('subsId2_$i', subs[i].id2!);
      preferences.setString('subsDescr$i', subs[i].descr!);
      preferences.setString('subslink$i', subs[i].link!);
      preferences.setString('subsimg$i', subs[i].img!);
      preferences.setString('subscolor$i', subs[i].color!);
    }

    for (var i = 0; i < defValues.length; i++) {
      preferences.setInt('DparID$i', defValues[i].parID!);
      preferences.setDouble('DparValue_$i', defValues[i].value!);
      preferences.setInt('DparValue$i', defValues[i].parValue!);
      preferences.setString('DparNameAr$i', defValues[i].parNameAr!);
      preferences.setString('DparNameEn$i', defValues[i].parNameEn ?? "");
    }
  }

  Future<void> getMe() async {
    final preferences = await SharedPreferences.getInstance();
    int? compNo = preferences.getInt('compNo');
    int? empNum = preferences.getInt('empNum');
    String? username = preferences.getString('username');
    String? password = preferences.getString('password');
    bool? defaultDate = preferences.getBool('defaultDate');
    String? empName = preferences.getString('empName');
    String? empEngName = preferences.getString('empEngName');
    bool? isSupervisor = preferences.getBool('isSupervisor');
    bool? isInterviewer = preferences.getBool('isInterviewer');
    int? clientNo = preferences.getInt('clientNo');
    bool? isResigned = preferences.getBool('isResigned');
    String? socialNo = preferences.getString('socialNo');
    String? img = preferences.getString('img');

    me = User(
      compNo: compNo,
      empNum: empNum,
      username: username,
      password: password,
      defaultDate: defaultDate,
      empEngName: empEngName,
      empName: empName,
      isInterviewer: isInterviewer,
      isSupervisor: isSupervisor,
      clientNo: clientNo,
      isLogin: true,
      isResigned: isResigned,
      socialNo: socialNo,
      errorMessage: "",
      img: img,
    );
  }

  Future<void> getMenus() async {
    final preferences = await SharedPreferences.getInstance();
    menus.clear();
    subs.clear();

    int? menusCount = preferences.getInt('menusCount') ?? 0;
    int? subsCount = preferences.getInt('subsCount') ?? 0;
    int? defValuesCount = preferences.getInt('defValuesCount') ?? 0;

    // Retrieve User details
    await getMe(); // Call getMe to initialize the user object

    for (var i = 0; i < menusCount; i++) {
      int? id = preferences.getInt('menusId$i');
      String? descr = preferences.getString('menusDescr$i');
      if (id != null && descr != null) {
        menus.add(Menu(id: id, descr: descr));
      }
    }
    
    for (var i = 0; i < subsCount; i++) {
      int? id = preferences.getInt('subsId$i');
      int? id2 = preferences.getInt('subsId2_$i');
      String? descr = preferences.getString('subsDescr$i');
      String? color = preferences.getString('subscolor$i');
      String? link = preferences.getString('subslink$i');
      String? img = preferences.getString('subsimg$i');

      if (id != null && descr != null) {
        subs.add(SubMenu(
          id: id,
          id2: id2,
          descr: descr,
          link: link,
          color: color,
          img: img,
        ));
      }
    }

    for (var i = 0; i < defValuesCount; i++) {
      int? parID = preferences.getInt('DparID$i');
      int? parValue = preferences.getInt('DparValue$i');
      double? value = preferences.getDouble('DparValue_$i');
      String? parNameAr = preferences.getString('DparNameAr$i');
      String? parNameEn = preferences.getString('DparNameEn$i') ?? "";

      if (parID != null && parNameAr != null) {
        defValues.add(DefValue(
          parID: parID,
          parValue: parValue,
          parNameAr: parNameAr,
          parNameEn: parNameEn,
          value: value,
        ));
      }
    }
  }
}
