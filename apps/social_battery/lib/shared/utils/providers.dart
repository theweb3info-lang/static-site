import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/activities/model/activity_model.dart';
import '../../features/activities/service/database_service.dart';
import '../constants/app_constants.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDark') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', state);
  }
}

// Battery level provider
final batteryLevelProvider =
    StateNotifierProvider<BatteryLevelNotifier, double>((ref) {
  return BatteryLevelNotifier();
});

class BatteryLevelNotifier extends StateNotifier<double> {
  BatteryLevelNotifier() : super(AppConstants.defaultBattery) {
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getDouble('batteryLevel');
    final lastUpdate = prefs.getString('lastBatteryUpdate');

    if (savedLevel != null && lastUpdate != null) {
      final lastDate = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      final daysDiff = now.difference(lastDate).inDays;

      // Recharge overnight
      double rechargedLevel = savedLevel + (daysDiff * AppConstants.dailyRecharge);
      state = rechargedLevel.clamp(AppConstants.minBattery, AppConstants.maxBattery);
    }

    // Subtract today's activities
    final todayCost = await DatabaseService.getTodayTotalCost();
    state = (state - todayCost).clamp(AppConstants.minBattery, AppConstants.maxBattery);
    _save();
  }

  Future<void> consume(double amount) async {
    state = (state - amount).clamp(AppConstants.minBattery, AppConstants.maxBattery);
    await _save();
    await DatabaseService.saveBatteryLevel(state);
  }

  Future<void> recharge(double amount) async {
    state = (state + amount).clamp(AppConstants.minBattery, AppConstants.maxBattery);
    await _save();
    await DatabaseService.saveBatteryLevel(state);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('batteryLevel', state);
    await prefs.setString('lastBatteryUpdate', DateTime.now().toIso8601String());
  }
}

// Activities provider
final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<SocialActivity>>((ref) {
  return ActivitiesNotifier(ref);
});

class ActivitiesNotifier extends StateNotifier<List<SocialActivity>> {
  final Ref ref;

  ActivitiesNotifier(this.ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    state = await DatabaseService.getActivities(from: startOfWeek, to: now);
  }

  Future<void> addActivity(SocialActivity activity) async {
    await DatabaseService.insertActivity(activity);
    ref.read(batteryLevelProvider.notifier).consume(activity.energyCost);
    await _load();
  }

  Future<void> removeActivity(String id) async {
    await DatabaseService.deleteActivity(id);
    await _load();
  }
}

// Weekly stats provider
final weeklyStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  ref.watch(activitiesProvider);
  return DatabaseService.getWeeklyStats();
});

// Navigation provider
final currentTabProvider = StateProvider<int>((ref) => 0);
