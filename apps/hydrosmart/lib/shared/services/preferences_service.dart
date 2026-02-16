import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/water_record.dart';

// --- SharedPreferences instance ---
final sharedPrefsProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

// --- Theme Mode ---
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(sharedPrefsProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferencesAsync _prefs;
  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _load();
  }
  Future<void> _load() async {
    final v = await _prefs.getString('themeMode');
    if (v == 'light') state = ThemeMode.light;
    if (v == 'dark') state = ThemeMode.dark;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString('themeMode', mode.name);
  }
}

// --- Onboarding ---
final isOnboardedProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.read(sharedPrefsProvider);
  return await prefs.getBool('onboarded') ?? false;
});

// --- User Profile ---
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref.read(sharedPrefsProvider));
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferencesAsync _prefs;
  UserProfileNotifier(this._prefs) : super(const UserProfile()) {
    _load();
  }

  Future<void> _load() async {
    final w = await _prefs.getDouble('weightKg');
    final a = await _prefs.getInt('activityLevel');
    final c = await _prefs.getInt('caffeineCount');
    state = UserProfile(
      weightKg: w ?? 70,
      activityLevel:
          a != null ? ActivityLevel.values[a] : ActivityLevel.moderate,
      caffeineCount: c ?? 0,
    );
  }

  Future<void> update(UserProfile profile) async {
    state = profile;
    await _prefs.setDouble('weightKg', profile.weightKg);
    await _prefs.setInt('activityLevel', profile.activityLevel.index);
    await _prefs.setInt('caffeineCount', profile.caffeineCount);
    await _prefs.setBool('onboarded', true);
  }
}

// --- Water Records ---
final waterRecordsProvider =
    StateNotifierProvider<WaterRecordsNotifier, List<WaterRecord>>((ref) {
  return WaterRecordsNotifier(ref.read(sharedPrefsProvider));
});

class WaterRecordsNotifier extends StateNotifier<List<WaterRecord>> {
  final SharedPreferencesAsync _prefs;
  WaterRecordsNotifier(this._prefs) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _prefs.getString('waterRecords');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      state = list.map((e) => WaterRecord.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _save() async {
    await _prefs.setString(
        'waterRecords', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> addRecord(int amountMl) async {
    state = [...state, WaterRecord(timestamp: DateTime.now(), amountMl: amountMl)];
    await _save();
  }

  Future<void> removeRecord(WaterRecord record) async {
    state = state.where((r) => r.timestamp != record.timestamp).toList();
    await _save();
  }
}

// --- Derived: today's intake ---
final todayIntakeProvider = Provider<int>((ref) {
  final records = ref.watch(waterRecordsProvider);
  final now = DateTime.now();
  return records
      .where((r) =>
          r.timestamp.year == now.year &&
          r.timestamp.month == now.month &&
          r.timestamp.day == now.day)
      .fold(0, (sum, r) => sum + r.amountMl);
});

// --- Derived: adjusted daily goal (weather) ---
final adjustedGoalProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  final weather = ref.watch(weatherTempProvider);
  final base = profile.dailyGoalMl;
  // Add 10% for hot weather (>30°C), 5% for warm (>25°C)
  if (weather != null) {
    if (weather > 30) return (base * 1.15).round();
    if (weather > 25) return (base * 1.05).round();
  }
  return base;
});

// --- Weather temp (nullable) ---
final weatherTempProvider = StateProvider<double?>((ref) => null);
