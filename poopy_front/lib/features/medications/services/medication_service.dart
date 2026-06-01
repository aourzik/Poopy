import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/models.dart';

class MedicationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  Future<List<Medication>> getMeds(String userId) async {
    try {
      final response = await _dio.get('/medication/user/$userId');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((m) => Medication.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Erreur MedicationService getMeds: $e");
      return [];
    }
  }

  Future<bool> addMed(Medication med, String userId) async {
    try {
      final response = await _dio.post('/medication', data: med.toJson(userId));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Erreur MedicationService addMed: $e");
      return false;
    }
  }

  Future<bool> markAsTaken(String medicationId) async {
    try {
      final response = await _dio.post(
        '/medication/log',
        data: {'medicationId': medicationId},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Erreur MedicationService markAsTaken: $e");
      return false;
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      final response = await _dio.delete('/medication/$id');
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erreur MedicationService deleteMedication: $e");
      return false;
    }
  }
}
