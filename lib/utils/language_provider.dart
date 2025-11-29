import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class LanguageProvider extends ChangeNotifier {
  final _storage = GetStorage();

  String _languageCode = 'en'; // default

  String get languageCode => _languageCode;

  LanguageProvider() {
    // Load saved language from GetStorage
    _languageCode = _storage.read('lang') ?? 'en';
  }

  void changeLanguage(String code) {
    _languageCode = code;
    _storage.write('lang', code);
    notifyListeners();
  }
}
