import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/capsule.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timecapsule.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE capsules(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            unlockAt INTEGER NOT NULL,
            isOpened INTEGER NOT NULL DEFAULT 0,
            mood TEXT
          )
        ''');
      },
    );
  }

  static Future<List<Capsule>> getAllCapsules() async {
    final db = await database;
    final maps = await db.query('capsules', orderBy: 'unlockAt ASC');
    return maps.map((m) => Capsule.fromMap(m)).toList();
  }

  static Future<void> insertCapsule(Capsule capsule) async {
    final db = await database;
    await db.insert('capsules', capsule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateCapsule(Capsule capsule) async {
    final db = await database;
    await db.update('capsules', capsule.toMap(),
        where: 'id = ?', whereArgs: [capsule.id]);
  }

  static Future<void> deleteCapsule(String id) async {
    final db = await database;
    await db.delete('capsules', where: 'id = ?', whereArgs: [id]);
  }
}
