import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? _userId;

  static String? get userId => _userId;
  static bool get isLoggedIn => _userId != null && _userId!.isNotEmpty;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
  }

  static Future<void> save(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    _userId = id;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _userId = null;
  }
}
