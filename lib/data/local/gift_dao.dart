import 'package:sqflite/sqflite.dart';
import '../../models/gift.dart';
import '../../services/database_helper.dart';

class GiftDao {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insertGift(Gift gift) async {
    final db = await dbProvider.database;

    print("Inserting gift: ${gift.toMap()}"); // Debugging
    return db.insert(
      'gifts',
      gift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }




  Future<List<Gift>> getPledgedGifts(String userId) async {
    final db = await dbProvider.database;

    final results = await db.query(
      'gifts',
      where: 'userId = ? AND status = ? AND pledgerId != ?', // Exclude gifts pledged by the user
      whereArgs: [userId, 'Pledged', userId],
    );

    print("Gifts pledged to userId $userId: $results");
    return results.map((map) => Gift.fromMap(map)).toList();
  }





  Future<List<Gift>> getMyPledgedGifts(String pledgerId) async {
    final db = await dbProvider.database;
    final results = await db.query(
      'gifts',
      where: 'pledgerId = ? AND status = ?',
      whereArgs: [pledgerId, 'Pledged'],
    );

    print("Pledged gifts for pledgerId $pledgerId: $results");

    return results.map((map) => Gift.fromMap(map)).toList();
  }



  Future<List<Gift>> getGiftsForEvent(String eventId, String userId) async {
    final db = await dbProvider.database;

    final results = await db.query(
      'gifts',
      where: 'eventID = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );

    print("Gifts retrieved: $results"); // Debug the raw results

    return results.map((map) => Gift.fromMap(map)).toList();
  }


  Future<int> updateGift(Gift gift, String? userId) async {
    final db = await dbProvider.database;
    print("Updating gift: ${gift.toMap()}"); // Debugging line
    return db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [gift.id, userId],
    );
  }




  Future<int> deleteGift(String id, String userId) async {
    final db = await dbProvider.database;
    return await db.delete(
      'gifts',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId], // Ensure only the current user's gift is deleted
    );
  }

  // DAO: Fetch all gifts for a specific eventId
  Future<List<Gift>> getGiftsForEventWithoutUserId(String eventId) async {
    final db = await dbProvider.database;

    final results = await db.query(
      'gifts',
      where: 'eventID = ?',
      whereArgs: [eventId],
    );

    print("Gifts retrieved for eventId $eventId: $results");
    return results.map((map) => Gift.fromMap(map)).toList();
  }



  Future<void> debugGifts(String eventId) async {
    final db = await dbProvider.database;
    final results = await db.rawQuery('SELECT * FROM gifts WHERE eventID = ?', [eventId]);
    print("Debug Gifts for Event ID $eventId: $results");
    for (final row in results) {
      print("Gift: ${row['name']}, Status: ${row['status']}, Pledger: ${row['pledgerId']}, Owner: ${row['userId']}");
    }
  }

  Future<List<Gift>> getAvailableGiftsForEvent(String eventId) async {
    final db = await dbProvider.database;
    final results = await db.query(
      'gifts',
      where: 'eventID = ? AND status = ?',
      whereArgs: [eventId, 'Available'],
    );
    return results.map((map) => Gift.fromMap(map)).toList();
  }




}

