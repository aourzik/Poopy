import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/models/models.dart';

class MedicationService {
  final String baseUrl = "http://10.0.2.2:3000/medication"; // Emulator IP

  Future<List<Medication>> getMeds(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/user/$userId"));
    if (response.statusCode == 200) {
      print("📡 Données reçues du serveur: ${response.body}");
      List data = json.decode(response.body);
      return data.map((m) => Medication.fromJson(m)).toList();
    } else {
    print("❌ Erreur serveur: ${response.statusCode}");
    return [];
  } }

  Future<bool> addMed(Medication med, String userId) async {
  print("📡 Envoi au serveur pour l'user: $userId"); // DEBUG
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(med.toJson(userId)),
    );
    print("✅ Réponse serveur: ${response.statusCode}"); // DEBUG
    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    print("❌ Erreur de connexion: $e"); // DEBUG
    return false;
  }
}

  Future<bool> markAsTaken(String medicationId) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/log"), // <-- Vérifie bien le chemin /medication/log
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"medicationId": medicationId}),
    );
    print("📡 MarkAsTaken Status: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("❌ Erreur Service Take: $e");
    return false;
  }
}

Future<bool> deleteMedication(String id) async {
  try {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"), // <-- Vérifie bien /medication/ID
    );
    print("📡 Delete Status: ${response.statusCode}");
    return response.statusCode == 200;
  } catch (e) {
    print("❌ Erreur Service Delete: $e");
    return false;
  }
}
}
