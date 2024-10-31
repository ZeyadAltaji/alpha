import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/data/rest_ds.dart';
import 'package:alpha/models/Modules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(User user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);
RoundedLoadingButtonController _btnController =
    new RoundedLoadingButtonController();
  void doLogin(String username, String password, String pas) async {
  try {
    final user = await RestDatasource().login(username, password);
    _view.onLoginSuccess(user);

    final preferences = await SharedPreferences.getInstance();
    preferences.setBool('allowNotifications', allowNotifications);
    preferences.setString('username', username);
    preferences.setString('password', pas);
    username_ = username;
    password_ = password;
    allowNotifications = true;
    notificationSubscribe('cr');
    notificationSubscribe('m');
    notificationSubscribe('n');
    notificationSubscribe('logout');
    notificationSubscribe('refresh');
    // startSignalR();
  } catch (e) {
    _view.onLoginError(e.toString());
    _btnController.stop();
  }
}
}
