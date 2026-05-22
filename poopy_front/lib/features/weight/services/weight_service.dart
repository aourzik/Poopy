import '../../../shared/models/models.dart';

class WeightService {
  // ⚡️ VIDE PAR DÉFAUT : Plus de données en dur !
  static final List<Weight> _mockWeights = [];

  Future<List<Weight>> getWeights(String userId) async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Petit temps réseau
    // On trie toujours par date pour la courbe
    _mockWeights.sort((a, b) => a.date.compareTo(b.date));
    return _mockWeights;
  }

  Future<bool> addWeight(Weight weight) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockWeights.add(weight);
    return true;
  }
}
