import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  // On s'assure que le nom est EXACTEMENT getUserName
  Future<String> getUserName(String userId) async {
    try {
      // On utilise ta route qui liste tout pour le test
      final response = await _dio.get('/user/all-test');
      final List users = response.data;
      
      // On cherche l'utilisateur
      final user = users.firstWhere(
        (u) => u['id'] == userId, 
        orElse: () => null
      );
      
      return user != null ? user['name'] : "Ami";
    } catch (e) {
      print("❌ Erreur UserService: $e");
      return "Ami";
    }
  }
}