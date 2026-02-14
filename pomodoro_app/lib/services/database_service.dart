import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../models/daily_statistics.dart';
import '../models/pomodoro_session.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<void> initialize() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pomodoro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, 'Pomodoro', filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        estimatedPomodoros INTEGER DEFAULT 1,
        completedPomodoros INTEGER DEFAULT 0,
        isCompleted INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL,
        completedAt INTEGER,
        priority INTEGER DEFAULT 2,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        durationMinutes INTEGER NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        completed INTEGER DEFAULT 0,
        taskId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE statistics (
        date TEXT PRIMARY KEY,
        completedPomodoros INTEGER DEFAULT 0,
        totalFocusMinutes INTEGER DEFAULT 0,
        completedTasks INTEGER DEFAULT 0
      )
    ''');
  }

  // Task operations
  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'createdAt DESC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Session operations
  Future<void> insertSession(PomodoroSession session) async {
    final db = await database;
    await db.insert('sessions', session.toMap());
  }

  Future<void> updateSession(PomodoroSession session) async {
    final db = await database;
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<PomodoroSession>> getSessions({DateTime? from, DateTime? to}) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (from != null && to != null) {
      where = 'startTime >= ? AND startTime <= ?';
      whereArgs = [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch];
    }

    final result = await db.query(
      'sessions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'startTime DESC',
    );

    return result.map((map) => PomodoroSession.fromMap(map)).toList();
  }

  // Statistics operations
  Future<List<DailyStatistics>> getStatistics() async {
    final db = await database;
    final result = await db.query('statistics', orderBy: 'date DESC');
    return result.map((map) => DailyStatistics.fromMap(map)).toList();
  }

  Future<void> saveStatistics(DailyStatistics stats) async {
    final db = await database;
    await db.insert(
      'statistics',
      stats.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
