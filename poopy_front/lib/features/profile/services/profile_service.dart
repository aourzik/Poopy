import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/models.dart';

class ProfileService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));

  Future<List<MedicalLab>> getLabs(String userId) async {
    try {
      final response = await _dio.get('/lab/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MedicalLab.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Erreur Fetch Labs: $e");
      return [];
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("❌ Erreur Fetch User: $e");
      return null;
    }
  }

  Future<UserModel?> updateUser({
    required String userId,
    String? name,
    String? diagnosis,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.patch(
        '/user/$userId',
        data: {
          if (name != null) 'name': name,
          if (diagnosis != null) 'diagnosis': diagnosis,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("❌ Erreur Update User: $e");
      return null;
    }
  }

  Future<bool> addLab({
    required String userId,
    required LabType type,
    double? crp,
    double? calprotectin,
    double? b12,
    double? b9,
    double? ferritin,
    double? iron,
    String? notes,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.post(
        '/lab',
        data: {
          'userId': userId,
          'type': type.name,
          if (crp != null) 'crp': crp,
          if (calprotectin != null) 'calprotectin': calprotectin,
          if (b12 != null) 'b12': b12,
          if (b9 != null) 'b9': b9,
          if (ferritin != null) 'ferritin': ferritin,
          if (iron != null) 'iron': iron,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'date': (date ?? DateTime.now()).toIso8601String(),
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Erreur Add Lab: $e");
      return false;
    }
  }
}
