import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = "auth_token";

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
}
