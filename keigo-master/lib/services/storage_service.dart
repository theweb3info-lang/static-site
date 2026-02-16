import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion.dart';
import '../utils/constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

class StorageService {
  final SharedPreferences _prefs;
  StorageService(this._prefs);

  // API Key
  String? getApiKey() => _prefs.getString(AppConstants.apiKeyStorageKey);
  Future<void> setApiKey(String key) =>
      _prefs.setString(AppConstants.apiKeyStorageKey, key);

  // History
  List<Conversion> getHistory() {
    final json = _prefs.getString(AppConstants.historyStorageKey) ?? '';
    return Conversion.listFromJson(json);
  }

  Future<void> saveHistory(List<Conversion> history) =>
      _prefs.setString(AppConstants.historyStorageKey, Conversion.listToJson(history));

  Future<void> addToHistory(Conversion conversion) async {
    final history = getHistory();
    history.insert(0, conversion);
    if (history.length > 100) history.removeLast();
    await saveHistory(history);
  }

  Future<void> clearHistory() =>
      _prefs.remove(AppConstants.historyStorageKey);

  // Daily count
  int getDailyCount() {
    final date = _prefs.getString(AppConstants.dailyCountDateKey) ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (date != today) return 0;
    return _prefs.getInt(AppConstants.dailyCountKey) ?? 0;
  }

  Future<void> incrementDailyCount() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final date = _prefs.getString(AppConstants.dailyCountDateKey) ?? '';
    if (date != today) {
      await _prefs.setString(AppConstants.dailyCountDateKey, today);
      await _prefs.setInt(AppConstants.dailyCountKey, 1);
    } else {
      final count = _prefs.getInt(AppConstants.dailyCountKey) ?? 0;
      await _prefs.setInt(AppConstants.dailyCountKey, count + 1);
    }
  }

  bool isFreeTierExhausted() =>
      getDailyCount() >= AppConstants.freeTierDailyLimit;
}
