import 'package:flutter/material.dart';

class LocalizationProvider with ChangeNotifier {
  String _language = 'English';

  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }
}
