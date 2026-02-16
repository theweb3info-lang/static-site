import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/members/model/member.dart';
import '../features/chores/model/chore.dart';
import '../features/chores/service/chore_service.dart';

// Current household
final currentHouseholdProvider = StateProvider<Household?>((ref) => null);
final currentMemberProvider = StateProvider<Member?>((ref) => null);

// Households list
final householdsProvider = FutureProvider<List<Household>>((ref) async {
  return ChoreService.getAllHouseholds();
});

// Members of current household
final membersProvider = FutureProvider<List<Member>>((ref) async {
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return [];
  return ChoreService.getMembers(household.id);
});

// Chores of current household
final choresProvider = FutureProvider<List<Chore>>((ref) async {
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return [];
  return ChoreService.getChores(household.id);
});

// Refresh trigger
final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// Logs
final choreLogsProvider = FutureProvider.family<List<ChoreLog>, ({DateTime? from, DateTime? to})>((ref, range) async {
  final household = ref.watch(currentHouseholdProvider);
  ref.watch(refreshTriggerProvider);
  if (household == null) return [];
  return ChoreService.getLogs(household.id, from: range.from, to: range.to);
});

// Stats
final memberPointsProvider = FutureProvider.family<Map<String, int>, ({DateTime? from, DateTime? to})>((ref, range) async {
  final household = ref.watch(currentHouseholdProvider);
  ref.watch(refreshTriggerProvider);
  if (household == null) return {};
  return ChoreService.getMemberPoints(household.id, from: range.from, to: range.to);
});

// Period selector
enum StatPeriod { week, month, all }

final statPeriodProvider = StateProvider<StatPeriod>((ref) => StatPeriod.week);

DateTime getStartOfWeek() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
}

DateTime getStartOfMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}
