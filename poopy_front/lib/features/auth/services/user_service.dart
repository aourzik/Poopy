import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_session.dart';
import '../../../shared/models/models.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  Future<String> getUserName(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['name'] ?? 'Ami';
      }
      return 'Ami';
    } catch (e) {
      print("❌ Erreur UserService getUserName: $e");
      return 'Ami';
    }
  }

  /// Crée un nouveau compte et sauvegarde la session
  Future<({bool success, String? error, UserModel? user})> register({
    required String name,
    required String email,
    required String password,
    String? diagnosis,
  }) async {
    try {
      final response = await _dio.post('/user', data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        if (diagnosis != null) 'diagnosis': diagnosis,
      });
      final user = UserModel.fromJson(response.data);
      await UserSession.save(user.id);
      return (success: true, error: null, user: user);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Erreur de connexion';
      return (success: false, error: msg as String, user: null);
    } catch (e) {
      return (success: false, error: 'Erreur inattendue', user: null);
    }
  }

  /// Connecte un utilisateur existant et sauvegarde la session
  Future<({bool success, bool needsPassword, String? userId, String? userName, String? error, UserModel? user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/user/login', data: {
        'email': email.trim(),
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;

      // Ancien compte sans mot de passe
      if (data['needsPassword'] == true) {
        return (success: false, needsPassword: true, userId: data['userId'] as String, userName: data['name'] as String, error: null, user: null);
      }

      final user = UserModel.fromJson(data);
      await UserSession.save(user.id);
      return (success: true, needsPassword: false, userId: null, userName: null, error: null, user: user);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Erreur de connexion';
      return (success: false, needsPassword: false, userId: null, userName: null, error: msg as String, user: null);
    } catch (e) {
      return (success: false, needsPassword: false, userId: null, userName: null, error: 'Erreur inattendue', user: null);
    }
  }

  /// Définit le mot de passe pour un compte existant sans mot de passe
  Future<({bool success, String? error})> setPassword({
    required String userId,
    required String password,
  }) async {
    try {
      await _dio.post('/user/$userId/set-password', data: {'password': password});
      return (success: true, error: null);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Erreur de connexion';
      return (success: false, error: msg as String);
    } catch (e) {
      return (success: false, error: 'Erreur inattendue');
    }
  }
}
