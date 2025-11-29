import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../api_client/apiClient.dart';
import '../constants/end_points.dart';
import '../models/Language.dart';

class LanguageProvider with ChangeNotifier {
  final ApiClient apiClient = ApiClient();
  final _box = GetStorage();

  List<LanguageData> _languages = [];
  bool _loading = false;
  String _currentLang = "en";

  List<LanguageData> get languages => _languages;
  bool get loading => _loading;

  String get currentLanguage => _currentLang; // IMPORTANT

  LanguageProvider() {
    loadSavedLanguage();
  }

  /// Load saved language from storage
  void loadSavedLanguage() {
    _currentLang = _box.read("app_lang") ?? "en";
    notifyListeners();
  }

  /// Fetch languages from API
  Future<void> fetchLanguages() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await apiClient.getMethod(language);

      if (response != null) {
        LanguageResponse langResponse = LanguageResponse.fromJson(response);
        _languages = langResponse.data?.languages ?? [];
      } else {
        _languages = [];
      }
    } catch (e) {
      debugPrint("Error fetching languages: $e");
      _languages = [];
    }

    _loading = false;
    notifyListeners();
  }

  /// Change the language
  void changeLanguage(String code) {
    _currentLang = code;
    _box.write("app_lang", code);
    notifyListeners(); // Reloads UI
  }
}
