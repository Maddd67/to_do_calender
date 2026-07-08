import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<Todo> create(Todo todo) async {
    final db = await instance.database;
    final id = await db.insert('todos', todo.toMap());
    return todo..id = id;
  }

  Future<List<Todo>> readByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Todo.fromMap(m)).toList();
  }

  Future<List<String>> readAllDates() async {
    final db = await instance.database;
    final maps = await db.rawQuery('SELECT DISTINCT date FROM todos');
    return maps.map((m) => m['date'] as String).toList();
  }

  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
