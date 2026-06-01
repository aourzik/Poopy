import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/models.dart';

class AppointmentService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  Future<Map<String, List<Appointment>>> getAppointments(String userId) async {
    try {
      final response = await _dio.get('/appointment/user/$userId');
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'upcoming': (data['upcoming'] as List)
              .map((a) => Appointment.fromJson(a))
              .toList(),
          'past': (data['past'] as List)
              .map((a) => Appointment.fromJson(a))
              .toList(),
        };
      }
      return {'upcoming': [], 'past': []};
    } catch (e) {
      print("❌ Erreur AppointmentService getAppointments: $e");
      return {'upcoming': [], 'past': []};
    }
  }

  Future<bool> addAppointment(Appointment appt, String userId) async {
    try {
      final response = await _dio.post(
        '/appointment',
        data: appt.toJson(userId),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Erreur AppointmentService addAppointment: $e");
      return false;
    }
  }
}
