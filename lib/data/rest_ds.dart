import 'dart:async';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:alpha/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final loginUrl = "/Login";
  static final menuUrl = "/Menu";
  static final apiKey = "UG93ZXJlZC1CeSA6IEhhc2FuIEFidSBHaGFseW91bg==";

  Future<User> login(String username, String password) async {
    if (serverURL == '') {
      throw Exception(trans.err6);
    }
    if (myProtocol == '') {
      throw Exception(trans.err7);
    }

    try {
      final res = await _netUtil.post(
        '$loginUrl',
        body: {
          "token": apiKey,
          "UserName": username,
          "Password": password,
        },
      );
      User user = User.map(res["result"]);
      if (!user.isLogin!) {
        throw Exception(user.errorMessage);
      }

      List dM = res["menus"];
      List sdM = res["submenus"];
      List def = res["def"];
      menus = dM.map((m) => Menu.map(m)).toList();
      subs = sdM.map((m) => SubMenu.map(m)).toList();
      defValues = def.map((m) => DefValue.map(m)).toList();
      me = user;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setInt('empNum', me!.empNum!);
      preferences.setInt('compNo', me!.compNo!);
      preferences.reload();
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

