import '../services/user_session.dart';

class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://10.0.2.2:3001';
  static const String apiBaseUrl = baseUrl;

  static String get currentUserId => UserSession.userId ?? '';

  static const String appName = 'Poopy';
  static const String appTagline = 'Ton allié MICI au quotidien';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}