class AppConstants {
  AppConstants._();

  // 1. Correction de l'URL pour l'émulateur Android (10.0.2.2 au lieu de localhost)
  static const String baseUrl = 'http://localhost:3000';
  
  // 2. Ajout de la variable manquante pour ton utilisateur test Neon
  // Remplace bien cet ID par le vrai UUID qui est dans ta base Neon
  static const String currentUserId = '99e5b5bb-14c0-4daa-9b07-bb0e33a1912b';

  static const String appName = 'Poopy';
  static const String appTagline = 'Ton allié MICI au quotidien';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}