import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannedLabResult {
  final double? crp;
  final double? b12;
  final double? b9;
  final double? ferritin;
  final double? iron;
  final double? calprotectin;

  const ScannedLabResult({
    this.crp,
    this.b12,
    this.b9,
    this.ferritin,
    this.iron,
    this.calprotectin,
  });

  bool get hasBloodValues =>
      crp != null || b12 != null || b9 != null || ferritin != null || iron != null;

  bool get hasCalproValues => calprotectin != null;

  bool get isEmpty => !hasBloodValues && !hasCalproValues;
}

class LabScanService {
  static final _picker = ImagePicker();
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<ScannedLabResult?> scanFromCamera() =>
      _scan(ImageSource.camera);

  static Future<ScannedLabResult?> scanFromGallery() =>
      _scan(ImageSource.gallery);

  static Future<ScannedLabResult?> _scan(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );
      if (picked == null) return null;

      final inputImage = InputImage.fromFilePath(picked.path);
      final recognized = await _recognizer.processImage(inputImage);
      final text = recognized.text;

      return ScannedLabResult(
        crp: _extract(text, [
          r'crp',
          r'protéine c.{0,10}réactive',
          r'proteine c.{0,10}reactive',
          r'c-réactif',
        ]),
        b12: _extract(text, [
          r'vitamine b\.?12',
          r'vit\.? b\.?12',
          r'\bb12\b',
          r'cobalamine',
          r'cyanocobalamine',
        ]),
        b9: _extract(text, [
          r'vitamine b\.?9',
          r'vit\.? b\.?9',
          r'\bb9\b',
          r'folate',
          r'acide folique',
        ]),
        ferritin: _extract(text, [
          r'ferritine',
          r'ferritin',
        ]),
        iron: _extract(text, [
          r'fer s[eé]rique',
          r'fer total',
          r'\bfer\b',
        ]),
        calprotectin: _extract(text, [
          r'calprotectine',
          r'calprotectin',
          r'fécale',
        ]),
      );
    } catch (e) {
      print("❌ Erreur OCR: $e");
      return null;
    }
  }

  static double? _extract(String text, List<String> patterns) {
    final lower = text.toLowerCase();
    for (final pattern in patterns) {
      // Cherche le pattern suivi d'un nombre (avec espace, deux-points, etc.)
      final regex = RegExp('$pattern.{0,30}?(\\d+[,.]\\d+|\\d+)',
          caseSensitive: false, dotAll: true);
      final match = regex.firstMatch(lower);
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '.');
        final value = double.tryParse(raw);
        if (value != null && value > 0 && value < 100000) return value;
      }
    }
    return null;
  }

  static void dispose() => _recognizer.close();
}
