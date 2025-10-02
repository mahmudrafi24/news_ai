import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('newsai.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Users table
    await db.execute('''
    CREATE TABLE users (
      id $idType,
      email $textType,
      name TEXT,
      joinDate TEXT,
      token TEXT
    )
    ''');

    // Chat sessions table
    await db.execute('''
    CREATE TABLE chat_sessions (
      id $idType,
      title $textType,
      createdAt $textType,
      lastMessageAt $textType
    )
    ''');

    // Messages table
    await db.execute('''
    CREATE TABLE messages (
      id $idType,
      content $textType,
      isUser $intType,
      timestamp $textType,
      sessionId TEXT
    )
    ''');
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update('users', user.toJson(),
        where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('users');
  }

  // Chat session operations
  Future<void> insertChatSession(ChatSession session) async {
    final db = await database;
    await db.insert('chat_sessions', session.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatSession>> getAllChatSessions() async {
    final db = await database;
    final maps = await db.query('chat_sessions',
        orderBy: 'lastMessageAt DESC');
    return maps.map((map) => ChatSession.fromJson(map)).toList();
  }

  Future<ChatSession?> getChatSession(String id) async {
    final db = await database;
    final maps = await db.query('chat_sessions',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return ChatSession.fromJson(maps.first);
  }

  Future<void> deleteChatSession(String id) async {
    final db = await database;
    await db.delete('chat_sessions', where: 'id = ?', whereArgs: [id]);
    await db.delete('messages', where: 'sessionId = ?', whereArgs: [id]);
  }

  Future<void> deleteAllChatSessions() async {
    final db = await database;
    await db.delete('chat_sessions');
    await db.delete('messages');
  }

  // Message operations
  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Message>> getMessagesForSession(String sessionId) async {
    final db = await database;
    final maps = await db.query('messages',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp ASC');
    return maps.map((map) => Message.fromJson(map)).toList();
  }

  Future<Message?> getLastMessage(String sessionId) async {
    final db = await database;
    final maps = await db.query('messages',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp DESC',
        limit: 1);
    if (maps.isEmpty) return null;
    return Message.fromJson(maps.first);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}