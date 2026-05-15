import 'package:dio/dio.dart';
import '../models/stool_model.dart';
import '../../../core/constants/app_constants.dart';

class StoolService {
  final Dio _dio = Dio(BaseOptions(
  baseUrl: AppConstants.baseUrl, // On utilise la variable du fichier qu'on vient de modifier
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  contentType: 'application/json',
));

  Future<bool> saveStool(Stool stool) async {
  try {
    final response = await _dio.post('/stool', data: stool.toJson());

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return true;
    }
    return false;
  } catch (e) {
    print("⚠️ Note : Erreur de réponse, mais vérification DB nécessaire : $e");
    return false; 
  }
}

  Future<List<Stool>> getStools(String userId) async {
    try {
      final response = await _dio.get('/stool/user/$userId');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Stool.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Erreur récupération : $e");
      return [];
    }
  }
}