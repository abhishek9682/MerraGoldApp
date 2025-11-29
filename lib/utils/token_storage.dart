import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = "auth_token";
  static Map<String, dynamic> _langData = <String,dynamic>{};
  static const String  _keyLang ="lang";

  /// Save Token
  static Future<bool> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyToken, token);
  }

  /// Get Token
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Remove Token
  static Future<bool> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyToken);
  }

  /// Check if logged in
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  /// Save language data (JSON string)
  static Future<bool> saveLang(String langJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyLang, langJson);
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString(_keyLang) ?? '{}';
    _langData = jsonDecode(jsonString);
  }

// Get language data (JSON string)
  static String translate(String key) {
    return (_langData[key]?.toString() ?? key).toString();
  }

// Remove language data
  static Future<bool> removeLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyLang);
  }

// Check if saved language exists
  static Future<bool> hasLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyLang);
  }

}
