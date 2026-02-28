import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyCart = 'cart_items';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyCart);
  }



  static Future<void> saveCartJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCart, json);
  }

  static Future<String?> getCartJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCart);
  }




  static Future<void> saveUserJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json);
  }

  static Future<String?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUser);
  }
}
