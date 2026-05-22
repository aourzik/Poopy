class AppConstants {
  AppConstants._();


  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiBaseUrl = baseUrl;
  // 2. Ajout de la variable manquante pour ton utilisateur test Neon

  static const String currentUserId = '99e5b5bb-14c0-4daa-9b07-bb0e33a1912b';

  static const String appName = 'Poopy';
  static const String appTagline = 'Ton allié MICI au quotidien';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}