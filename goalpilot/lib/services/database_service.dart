import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'goalpilot.db');
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE goals(
          id TEXT PRIMARY KEY,
          name TEXT,
          type INTEGER,
          targetValue REAL,
          unit TEXT,
          startDate INTEGER,
          deadline INTEGER,
          color INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE entries(
          id TEXT PRIMARY KEY,
          date INTEGER,
          value REAL,
          note TEXT,
          goalId TEXT,
          FOREIGN KEY(goalId) REFERENCES goals(id) ON DELETE CASCADE
        )
      ''');
    });
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final goalMaps = await db.query('goals');
    final goals = <Goal>[];
    for (final m in goalMaps) {
      final entries = await db.query('entries',
          where: 'goalId = ?', whereArgs: [m['id']], orderBy: 'date ASC');
      goals.add(Goal.fromMap(m, entries.map((e) => LogEntry.fromMap(e)).toList()));
    }
    return goals;
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('entries', where: 'goalId = ?', whereArgs: [id]);
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertEntry(LogEntry entry) async {
    final db = await database;
    await db.insert('entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
