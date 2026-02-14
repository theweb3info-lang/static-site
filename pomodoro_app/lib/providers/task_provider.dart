import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String? _selectedTaskId;
  String _filterCategory = 'all';
  bool _showCompleted = false;

  List<Task> get tasks => _tasks;
  String? get selectedTaskId => _selectedTaskId;
  Task? get selectedTask => _selectedTaskId != null 
      ? _tasks.firstWhere((t) => t.id == _selectedTaskId, orElse: () => _tasks.first)
      : null;
  String get filterCategory => _filterCategory;
  bool get showCompleted => _showCompleted;

  List<Task> get filteredTasks {
    var filtered = _tasks.where((task) {
      if (!_showCompleted && task.isCompleted) return false;
      if (_filterCategory != 'all' && task.category != _filterCategory) return false;
      return true;
    }).toList();
    
    // Sort by priority (high first), then by creation date
    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return a.priority - b.priority;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filtered;
  }

  List<Task> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Set<String> get categories {
    final cats = _tasks.map((t) => t.category).whereType<String>().toSet();
    return cats;
  }

  Future<void> loadTasks() async {
    _tasks = await DatabaseService.instance.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseService.instance.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseService.instance.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await DatabaseService.instance.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    if (_selectedTaskId == taskId) {
      _selectedTaskId = null;
    }
    notifyListeners();
  }

  Future<void> completeTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    await DatabaseService.instance.updateTask(task);
    notifyListeners();
  }

  Future<void> incrementTaskPomodoro(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.incrementPomodoro();
    await DatabaseService.instance.updateTask(task);
    notifyListeners();
  }

  void selectTask(String? taskId) {
    _selectedTaskId = taskId;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setShowCompleted(bool value) {
    _showCompleted = value;
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    final completedIds = _tasks.where((t) => t.isCompleted).map((t) => t.id).toList();
    for (final id in completedIds) {
      await DatabaseService.instance.deleteTask(id);
    }
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }
}
