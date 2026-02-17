import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'database_service.dart';

class GoalProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Goal> _goals = [];
  bool _loading = true;

  List<Goal> get goals => _goals;
  bool get loading => _loading;

  Future<void> loadGoals() async {
    _loading = true;
    notifyListeners();
    _goals = await _db.getGoals();
    _loading = false;
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    await _db.insertGoal(goal);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _db.updateGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _db.deleteGoal(id);
    await loadGoals();
  }

  Future<void> addEntry(LogEntry entry) async {
    await _db.insertEntry(entry);
    await loadGoals();
  }

  Future<void> deleteEntry(String id) async {
    await _db.deleteEntry(id);
    await loadGoals();
  }
}
