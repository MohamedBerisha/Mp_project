import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    //await DatabaseHelper.instance.deleteDatabaseFile();
    //await DatabaseHelper.instance.database;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'hedieaty_database.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createFriendsTable(db);
    await _createEventsTable(db);
    await _createGiftsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE Gifts ADD COLUMN imagePath TEXT');
      } catch (e) {
        print("Column 'imagePath' already exists in 'Gifts' table.");
      }

      try {
        await db.execute('ALTER TABLE Events ADD COLUMN description TEXT');
        await db.execute('ALTER TABLE Events ADD COLUMN location TEXT');
        await db.execute('ALTER TABLE Events ADD COLUMN date TEXT');
        await db.execute('ALTER TABLE Events ADD COLUMN imageUrl TEXT');
      } catch (e) {
        print("Columns in 'Events' table already exist.");
      }
      // Add the friendId column if it's not already present
      if (oldVersion < 5) {
        try {
          await db.execute('ALTER TABLE Events ADD COLUMN friendId TEXT');
        } catch (e) {
          print("Column 'friendId' already exists in 'Events' table.");
        }

      }
    }
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'hedieaty_database.db');
    await deleteDatabase(path);
    print("Database deleted successfully!");
  }

  Future<void> closeDatabase() async {
    final db = await _database;
    await db?.close();
    print("Database connection closed.");
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE Users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT,
        dateOfBirth TEXT,
        gender TEXT,
        address TEXT,
        profileImage TEXT
      )
    ''');
  }

  Future<void> _createFriendsTable(Database db) async {
    await db.execute('''
      CREATE TABLE Friends (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        profileImage TEXT,
        upcomingEvents INTEGER,
        phoneNumber TEXT,
        userId TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES Users (id)
      )
    ''');
  }

  Future<void> _createEventsTable(Database db) async {
    await db.execute('''
      CREATE TABLE Events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        userId TEXT NOT NULL,
        description TEXT,
        location TEXT,
        date TEXT,
        imageUrl TEXT,
        FOREIGN KEY (userId) REFERENCES Users (id)
      )
    ''');
  }

  Future<void> _createGiftsTable(Database db) async {
    await db.execute('''
    CREATE TABLE Gifts (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      price REAL,
      status TEXT,
      imagePath TEXT,
      eventID TEXT,
      friendName TEXT,
      pledgerId TEXT,
      dueDate TEXT,
      isPending INTEGER,
      userId TEXT NOT NULL,
      FOREIGN KEY (eventID) REFERENCES Events (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (userId) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE
    )
  ''');
  }
}
