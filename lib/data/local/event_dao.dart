import 'package:sqflite/sqflite.dart';
import '../../services/database_helper.dart';
import '../../models/event.dart';

class EventDao {
  final dbProvider = DatabaseHelper.instance;

  /// Insert a new event associated with a specific userId
  Future<int> insertEvent(Events event) async {
    final db = await dbProvider.database;
    return db.insert(
      'Events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all events associated with a specific userId
  Future<List<Events>> getEventsForUser(String userId) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Events.fromMap(maps[i]);
    });
  }

  /// Get the count of upcoming events for a specific user
  Future<int> getUpcomingEventCount(String userId) async {
    final db = await dbProvider.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM events WHERE userId = ? AND status = ?',
      [userId, 'Upcoming'],
    );

    return result.first['count'] as int? ?? 0;
  }

  /// Update an existing event associated with a specific userId
  Future<int> updateEvent(Events event) async {
    final db = await dbProvider.database;
    return db.update(
      'Events',
      event.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [event.id, event.userId],
    );
  }

  /// Delete an event associated with a specific userId
  Future<int> deleteEvent(String id, String userId) async {
    final db = await dbProvider.database;
    return db.delete(
      'Events',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }
}
