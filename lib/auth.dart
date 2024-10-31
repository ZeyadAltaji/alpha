enum AuthState { LOGGED_IN, LOGGED_OUT, SET_SERVER }

abstract class AuthStateListener {
  void onNewNotification();
}

class AuthStateProvider {
  static final AuthStateProvider _instance = AuthStateProvider._internal();

  late List<AuthStateListener> _subscribers; // Marked as late

  factory AuthStateProvider() => _instance;

  AuthStateProvider._internal() {
    _subscribers = []; // Initialize here
    initState();
  }

  void initState() async {}

  void subscribe(AuthStateListener listener) {
    _subscribers.add(listener);
  }

  void dispose(AuthStateListener listener) {
    _subscribers.remove(listener);
  }

  int get subs => _subscribers.length;

  void newWF() {
    _subscribers.forEach((AuthStateListener s) => s.onNewNotification());
  }
}
