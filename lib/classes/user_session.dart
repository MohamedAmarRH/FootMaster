import 'package:untitled1/classes/user.dart';


class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  UserData? currentUser;

  void setUser(UserData user) {
    currentUser = user;
  }

  UserData? getUser() {
    return currentUser;
  }

  void clearUser() {
    currentUser = null;
  }
}
