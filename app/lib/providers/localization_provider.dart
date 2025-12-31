import 'package:flutter/material.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  String get language => _locale.languageCode == 'bn' ? 'Bangla' : 'English';

  void setLanguage(String lang) {
    _locale = lang == 'Bangla' ? const Locale('bn') : const Locale('en');
    notifyListeners();
  }
}
