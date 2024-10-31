abstract class PresenterVoids {
  void onChangeLanguage();
}

enum AuthState { LOGGED_IN, LOGGED_OUT, SET_SERVER }

abstract class GeneralListener {
  void onChangeLanguage();
}

class Provider {
  static final Provider _instance = Provider._internal();

  // Initialize _subscribers directly
  List<GeneralListener> _subscribers = [];

  factory Provider() => _instance;

  Provider._internal() {
    initState();
  }

  void initState() async {
    // Add any initialization code here
  }

  void subscribe(GeneralListener listener) {
    _subscribers.add(listener);
  }

  void dispose(GeneralListener listener) {
    _subscribers.remove(listener); // Simplified removal
  }

  void newWF() {
    _subscribers.forEach((GeneralListener s) => s.onChangeLanguage());
  }
}
