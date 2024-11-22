import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 2, // Atualize o número da versão ao mudar a estrutura
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        isEvent INTEGER NOT NULL DEFAULT 0,
        categories TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE tasks ADD COLUMN isEvent INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE tasks ADD COLUMN categories TEXT
      ''');
    }
  }

  // Métodos para gerenciar usuários
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
      String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getLoggedUser() async {
    final db = await database;
    final result = await db.query(
      'users',
      limit: 1, // Pegar o primeiro usuário como exemplo
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Métodos para gerenciar tarefas
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'date ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'date LIKE ?',
      whereArgs: ['${date.toIso8601String().split('T')[0]}%'],
      orderBy: 'date ASC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
