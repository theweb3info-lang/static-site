import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const _dbName = 'fairshare.db';
  static const _dbVersion = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Household group
    await db.execute('''
      CREATE TABLE household (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        invite_code TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');

    // Members
    await db.execute('''
      CREATE TABLE member (
        id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL,
        name TEXT NOT NULL,
        avatar_color INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (household_id) REFERENCES household(id)
      )
    ''');

    // Chore definitions
    await db.execute('''
      CREATE TABLE chore (
        id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL DEFAULT '✨',
        points INTEGER NOT NULL DEFAULT 3,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (household_id) REFERENCES household(id)
      )
    ''');

    // Chore completion records
    await db.execute('''
      CREATE TABLE chore_log (
        id TEXT PRIMARY KEY,
        chore_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        household_id TEXT NOT NULL,
        points INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (chore_id) REFERENCES chore(id),
        FOREIGN KEY (member_id) REFERENCES member(id),
        FOREIGN KEY (household_id) REFERENCES household(id)
      )
    ''');

    // Reminders
    await db.execute('''
      CREATE TABLE reminder (
        id TEXT PRIMARY KEY,
        chore_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        household_id TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (chore_id) REFERENCES chore(id),
        FOREIGN KEY (member_id) REFERENCES member(id)
      )
    ''');
  }
}
