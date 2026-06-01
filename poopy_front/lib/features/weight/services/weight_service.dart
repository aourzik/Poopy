import 'package:dio/dio.dart';
import '../../../shared/models/models.dart';
import '../../../core/constants/app_constants.dart';

class WeightService {
  // Initialisation de Dio (S'aligne avec l'adresse IP/Port de ton serveur Elysia)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    contentType: 'application/json',
  ));

  /// 📥 Récupère tout l'historique des poids réels depuis Neon
  Future<List<Weight>> getWeights(String userId) async {
    try {
      final response = await _dio.get('/weight/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Convertit le JSON de Prisma en objets Weight (Flutter)
        final List<Weight> weights =
            data.map((json) => Weight.fromJson(json)).toList();

        // On s'assure que c'est trié du plus ancien au plus récent pour la courbe fl_chart
        weights.sort((a, b) => a.date.compareTo(b.date));
        return weights;
      }
      return [];
    } catch (e) {
      print("❌ Erreur HTTP Fetch Weight: $e");
      return [];
    }
  }

  /// 📤 Envoie une nouvelle pesée vers Elysia -> Neon
  Future<bool> addWeight(Weight weight) async {
    try {
      final response = await _dio.post(
        '/weight',
        data: {
          'userId': weight.userId,
          'value': weight.value,
          'date': weight.date.toIso8601String(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Erreur HTTP Post Weight: $e");
      return false;
    }
  }
}
