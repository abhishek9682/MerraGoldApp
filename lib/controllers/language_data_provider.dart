import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goldproject/api_client/apiClient.dart';
import 'package:goldproject/constants/end_points.dart';

import '../utils/token_storage.dart';

class LanguageDataProvider with ChangeNotifier {
  ApiClient appClient = ApiClient();

  bool _isSelected = false;
  bool get isSelected => _isSelected;
  Map<String, dynamic> langData = {};

  Future<void> getLanguageData(String id) async {

    try {
      final response = await appClient.getMethod('$languageData$id');


      if (response != null) {

        // Convert Map<String, dynamic> → Map<String, String>
        langData = response.map<String, String>((key, value) {
          return MapEntry(key.toString(), value.toString());
        });

        String jsonData=jsonEncode(langData); // json because share_prefered use json
        TokenStorage.saveLang(jsonData.toString());
        print("Converted langData -------- $jsonData");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Language API Error: $e");
    }
  }


  void setSelected(bool value) {
    _isSelected = value;
    notifyListeners();
  }
}
