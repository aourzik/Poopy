import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/models/models.dart';
import '../../../core/constants/app_constants.dart';

class AppointmentService {
  final String baseUrl = "http://10.0.2.2:3000/appointment"; // 10.0.2.2 pour Android

  Future<Map<String, List<Appointment>>> getAppointments(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/user/$userId"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'upcoming': (data['upcoming'] as List).map((a) => Appointment.fromJson(a)).toList(),
          'past': (data['past'] as List).map((a) => Appointment.fromJson(a)).toList(),
        };
      }
      return {'upcoming': [], 'past': []};
    } catch (e) {
      print("❌ Erreur Fetch RDV: $e");
      return {'upcoming': [], 'past': []};
    }
  }

  Future<bool> addAppointment(Appointment appt, String userId) async {
  try {
    print("📡 Envoi du RDV au serveur...");
    final response = await http.post(
      Uri.parse(baseUrl), // Doit être http://10.0.2.2:3000/appointment
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(appt.toJson(userId)),
    );
    print("📡 Réponse serveur : ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("❌ Erreur de connexion : $e");
    return false;
  }
}
}