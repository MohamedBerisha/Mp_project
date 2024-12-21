import 'package:sqflite/sqflite.dart';
import '../../models/user.dart';
import '../../services/database_helper.dart';

class UserDao {
  Future<void> insertUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'Users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Users',
      where: 'id = ?',
      whereArgs: [id], // Fetch user by Firebase uid
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}


/// Authenticates a user by username and password
Future<User?> authenticateUser(String username, String password) async {
  final db = await DatabaseHelper.instance.database;

  // Query the database for matching username and password
  final List<Map<String, dynamic>> result = await db.query(
    'Users',
    where: 'username = ? AND password = ?', // Adjust column names as per your table schema
    whereArgs: [username, password],
  );

  // If a match is found, return the user
  if (result.isNotEmpty) {
    return User.fromMap(result.first);
  } else {
    return null;
  }
}


