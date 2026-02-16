import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ocr_service.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';
import '../../models/scan_result.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Must be overridden');
});

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final storageProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider).valueOrNull;
  if (prefs == null) throw StateError('SharedPreferences not ready');
  return StorageService(prefs);
});

final scanControllerProvider =
    StateNotifierProvider<ScanController, AsyncValue<ScanResult?>>((ref) {
  return ScanController(ref);
});

class ScanController extends StateNotifier<AsyncValue<ScanResult?>> {
  final Ref _ref;
  final _ocrService = OcrService();

  ScanController(this._ref) : super(const AsyncValue.data(null));

  Future<ScanResult?> scanImage(String imagePath) async {
    state = const AsyncValue.loading();
    try {
      final storage = _ref.read(storageProvider);
      final apiKey = storage.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Please set your OpenAI API key in Settings');
      }

      // Check daily limit
      final todayScans = storage.getTodayScans();
      if (todayScans >= 3) {
        // TODO: Check for pro subscription
        throw Exception('Daily scan limit reached (3/day). Upgrade to Pro for unlimited scans!');
      }

      // OCR
      final text = await _ocrService.extractText(imagePath);
      if (text.trim().isEmpty) {
        throw Exception('No text detected in image. Try again with a clearer photo.');
      }

      // AI Analysis
      final profile = storage.loadProfile();
      if (profile.allAllergenNames.isEmpty) {
        throw Exception('Please set up your allergen profile first');
      }

      final aiService = AiService(apiKey: apiKey);
      final result = await aiService.analyzeIngredients(
        ocrText: text,
        userAllergens: profile.allAllergenNames,
        imagePath: imagePath,
      );

      // Save
      await storage.saveScanResult(result);
      await storage.incrementTodayScans();

      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
