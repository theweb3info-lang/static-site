import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/activity_model.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'social_battery.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activities (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            energy_cost REAL NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE battery_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            level REAL NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insertActivity(SocialActivity activity) async {
    final db = await database;
    await db.insert('activities', activity.toMap());
  }

  static Future<List<SocialActivity>> getActivities({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (from != null && to != null) {
      where = 'created_at >= ? AND created_at <= ?';
      whereArgs = [from.toIso8601String(), to.toIso8601String()];
    }

    final maps = await db.query(
      'activities',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => SocialActivity.fromMap(m)).toList();
  }

  static Future<void> deleteActivity(String id) async {
    final db = await database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> saveBatteryLevel(double level) async {
    final db = await database;
    await db.insert('battery_log', {
      'level': level,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getBatteryHistory({
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await database;
    return await db.query(
      'battery_log',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'timestamp ASC',
    );
  }

  static Future<double> getTodayTotalCost() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final activities = await getActivities(
      from: startOfDay,
      to: now,
    );
    double total = 0;
    for (final a in activities) {
      total += a.energyCost;
    }
    return total;
  }

  static Future<Map<String, double>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final activities = await getActivities(from: startOfWeek, to: now);

    final Map<String, double> dailyCosts = {};
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final key = '${day.month}/${day.day}';
      dailyCosts[key] = 0;
    }

    for (final a in activities) {
      final key = '${a.createdAt.month}/${a.createdAt.day}';
      dailyCosts[key] = (dailyCosts[key] ?? 0) + a.energyCost;
    }

    return dailyCosts;
  }
}
