import 'package:uuid/uuid.dart';
import '../../../shared/utils/database_helper.dart';
import '../../../shared/constants/chore_templates.dart';
import '../model/chore.dart';
import '../../members/model/member.dart';

const _uuid = Uuid();

class ChoreService {
  // === Household ===
  static Future<Household> createHousehold(String name) async {
    final db = await DatabaseHelper.database;
    final household = Household(
      id: _uuid.v4(),
      name: name,
      inviteCode: _uuid.v4().substring(0, 6).toUpperCase(),
      createdAt: DateTime.now(),
    );
    await db.insert('household', household.toMap());

    // Add default chores
    for (final template in defaultChoreTemplates) {
      await db.insert('chore', Chore(
        id: _uuid.v4(),
        householdId: household.id,
        name: template.name,
        emoji: template.emoji,
        points: template.points,
        createdAt: DateTime.now(),
      ).toMap());
    }

    return household;
  }

  static Future<Household?> getHousehold(String id) async {
    final db = await DatabaseHelper.database;
    final results = await db.query('household', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Household.fromMap(results.first);
  }

  static Future<Household?> joinHousehold(String inviteCode) async {
    final db = await DatabaseHelper.database;
    final results = await db.query('household', where: 'invite_code = ?', whereArgs: [inviteCode.toUpperCase()]);
    if (results.isEmpty) return null;
    return Household.fromMap(results.first);
  }

  static Future<List<Household>> getAllHouseholds() async {
    final db = await DatabaseHelper.database;
    final results = await db.query('household', orderBy: 'created_at DESC');
    return results.map((m) => Household.fromMap(m)).toList();
  }

  // === Members ===
  static Future<Member> addMember(String householdId, String name, int colorIndex) async {
    final db = await DatabaseHelper.database;
    final member = Member(
      id: _uuid.v4(),
      householdId: householdId,
      name: name,
      avatarColor: colorIndex,
      createdAt: DateTime.now(),
    );
    await db.insert('member', member.toMap());
    return member;
  }

  static Future<List<Member>> getMembers(String householdId) async {
    final db = await DatabaseHelper.database;
    final results = await db.query('member', where: 'household_id = ?', whereArgs: [householdId], orderBy: 'created_at ASC');
    return results.map((m) => Member.fromMap(m)).toList();
  }

  // === Chores ===
  static Future<List<Chore>> getChores(String householdId) async {
    final db = await DatabaseHelper.database;
    final results = await db.query('chore', where: 'household_id = ? AND is_active = 1', whereArgs: [householdId], orderBy: 'name ASC');
    return results.map((m) => Chore.fromMap(m)).toList();
  }

  static Future<Chore> addChore(String householdId, String name, String emoji, int points) async {
    final db = await DatabaseHelper.database;
    final chore = Chore(
      id: _uuid.v4(),
      householdId: householdId,
      name: name,
      emoji: emoji,
      points: points,
      createdAt: DateTime.now(),
    );
    await db.insert('chore', chore.toMap());
    return chore;
  }

  // === Chore Logs ===
  static Future<ChoreLog> completeChore(String choreId, String memberId, String householdId, int points, {String? note}) async {
    final db = await DatabaseHelper.database;
    final log = ChoreLog(
      id: _uuid.v4(),
      choreId: choreId,
      memberId: memberId,
      householdId: householdId,
      points: points,
      completedAt: DateTime.now(),
      note: note,
    );
    await db.insert('chore_log', log.toMap());
    return log;
  }

  static Future<List<ChoreLog>> getLogs(String householdId, {DateTime? from, DateTime? to}) async {
    final db = await DatabaseHelper.database;
    String where = 'cl.household_id = ?';
    List<dynamic> args = [householdId];
    if (from != null) {
      where += ' AND cl.completed_at >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND cl.completed_at <= ?';
      args.add(to.toIso8601String());
    }
    final results = await db.rawQuery('''
      SELECT cl.*, c.name as chore_name, c.emoji as chore_emoji, 
             m.name as member_name, m.avatar_color as member_avatar_color
      FROM chore_log cl
      JOIN chore c ON cl.chore_id = c.id
      JOIN member m ON cl.member_id = m.id
      WHERE $where
      ORDER BY cl.completed_at DESC
    ''', args);
    return results.map((m) => ChoreLog.fromMap(m)).toList();
  }

  // === Stats ===
  static Future<Map<String, int>> getMemberPoints(String householdId, {DateTime? from, DateTime? to}) async {
    final db = await DatabaseHelper.database;
    String where = 'cl.household_id = ?';
    List<dynamic> args = [householdId];
    if (from != null) {
      where += ' AND cl.completed_at >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND cl.completed_at <= ?';
      args.add(to.toIso8601String());
    }
    final results = await db.rawQuery('''
      SELECT cl.member_id, SUM(cl.points) as total_points
      FROM chore_log cl
      WHERE $where
      GROUP BY cl.member_id
    ''', args);
    return {for (final r in results) r['member_id'] as String: (r['total_points'] as int?) ?? 0};
  }

  // === Reminders ===
  static Future<void> createReminder(String choreId, String memberId, String householdId, String message) async {
    final db = await DatabaseHelper.database;
    await db.insert('reminder', {
      'id': _uuid.v4(),
      'chore_id': choreId,
      'member_id': memberId,
      'household_id': householdId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getUnreadReminders(String memberId) async {
    final db = await DatabaseHelper.database;
    return await db.rawQuery('''
      SELECT r.*, c.name as chore_name, c.emoji as chore_emoji
      FROM reminder r
      JOIN chore c ON r.chore_id = c.id
      WHERE r.member_id = ? AND r.is_read = 0
      ORDER BY r.created_at DESC
    ''', [memberId]);
  }

  static Future<void> markReminderRead(String id) async {
    final db = await DatabaseHelper.database;
    await db.update('reminder', {'is_read': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
