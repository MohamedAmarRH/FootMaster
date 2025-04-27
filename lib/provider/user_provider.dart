import 'package:flutter/material.dart';
import '../classes/user.dart';

class UserProvider extends ChangeNotifier {
  UserData? _userData;

  UserData? get userData => _userData;

  void setUserData(UserData? data) {
    _userData = data;
    notifyListeners();
  }
}
