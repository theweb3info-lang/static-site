import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/scan_result.dart';

class StorageService {
  static const _profileKey = 'user_profile';
  static const _historyKey = 'scan_history';
  static const _apiKeyKey = 'openai_api_key';
  static const _dailyScansKey = 'daily_scans';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Profile
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  UserProfile loadProfile() {
    final data = _prefs.getString(_profileKey);
    if (data == null) return const UserProfile();
    return UserProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  // History
  Future<void> saveScanResult(ScanResult result) async {
    final history = loadHistory();
    history.insert(0, result);
    if (history.length > 100) history.removeLast();
    await _prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  List<ScanResult> loadHistory() {
    final data = _prefs.getString(_historyKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // API Key
  Future<void> saveApiKey(String key) async {
    await _prefs.setString(_apiKeyKey, key);
  }

  String? getApiKey() => _prefs.getString(_apiKeyKey);

  // Daily scan counter
  int getTodayScans() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final stored = _prefs.getString(_dailyScansKey);
    if (stored == null) return 0;
    final parts = stored.split(':');
    if (parts.length != 2 || parts[0] != today) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  Future<void> incrementTodayScans() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final count = getTodayScans() + 1;
    await _prefs.setString(_dailyScansKey, '$today:$count');
  }
}
