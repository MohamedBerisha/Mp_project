import 'package:sqflite/sqflite.dart';
import '../../models/friend.dart';
import '../../services/database_helper.dart';

class FriendDao {
  final dbProvider = DatabaseHelper.instance;

  /// Insert a new friend associated with a specific userId
  Future<int> insertFriend(Friend friend, String userId) async {
    final db = await dbProvider.database;
    return db.insert(
      'Friends',
      {...friend.toMap(), 'userId': userId}, // Include userId in the map
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all friends associated with a specific userId
  Future<List<Friend>> getFriends(String userId) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Friends',
      where: 'userId = ?', // Filter friends by userId
      whereArgs: [userId],
    );

    return maps.map((map) => Friend.fromMap(map)).toList();
  }

  /// Update an existing friend associated with a specific userId
  Future<int> updateFriend(Friend friend, String userId) async {
    final db = await dbProvider.database;
    return db.update(
      'Friends',
      {...friend.toMap(), 'userId': userId}, // Include userId in the map
      where: 'id = ? AND userId = ?',
      whereArgs: [friend.id, userId], // Ensure only the current user's friend is updated
    );
  }

  /// Delete a friend associated with a specific userId
  Future<int> deleteFriend(String id, String userId) async {
    final db = await dbProvider.database;
    return db.delete(
      'Friends',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId], // Ensure only the current user's friend is deleted
    );
  }
}
