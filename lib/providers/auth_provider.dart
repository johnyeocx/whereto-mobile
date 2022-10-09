import 'package:flutter/material.dart';

enum FilterBy { likes, queueTime, currentGenre, energyLevels, ratio }

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void toggleIsLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}
