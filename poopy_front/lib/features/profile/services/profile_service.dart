import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import 'package:poopy/shared/models/models.dart';

class ProfileService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl, 
    contentType: 'application/json',
  ));

  /// 📥 Récupère toutes les analyses réelles depuis Neon
  Future<List<MedicalLab>> getLabs(String userId) async {
    try {
      final response = await _dio.get('/lab/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MedicalLab.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Erreur HTTP Fetch Labs: $e");
      return [];
    }
  }

  /// 👤 Récupère les infos de l'utilisateur
  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("❌ Erreur API Fetch User: $e");
      return null;
    }
  }

  /// 📤 Envoie une nouvelle analyse
  Future<bool> addLab({
    required String userId,
    double? crp,
    double? calprotectin,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/lab',
        data: {
          'userId': userId,
          'crp': crp,
          'calprotectin': calprotectin,
          'notes': notes,
          'date': DateTime.now().toIso8601String(),
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Erreur HTTP Post Lab: $e");
      return false;
    }
  }
}