import 'dart:async';
import 'package:alpha/models/Modules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alpha/data/localdb.dart';

class DatabaseHelper {
  Future<int> deleteUsers() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('empNum');
    await preferences.remove('compNo');
    return 1;
  }

  Future<bool> isLoggedIn() async {
    bool logged = true;
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('empNum')) logged = false;
    if (!preferences.containsKey('compNo')) logged = false;
    if (logged == true) {
      await new DatabaseHelper2().getMenus();
    }
    return logged;
  }

Future<bool> saveUser(User user) async {
  bool logged = true;
  final preferences = await SharedPreferences.getInstance();
  await preferences.setInt('compNo', user.compNo!);
  await preferences.setInt('empNum', user.empNum ?? 0);
  await new DatabaseHelper2().setMenus();
  
  return logged;
}

}
