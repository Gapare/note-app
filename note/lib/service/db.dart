import 'package:note/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static Database? _database; // Mark as nullable with ?
  final String table = 'notes';

  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async { // Added return type
    var dir = await getDatabasesPath();
    String path = join(dir, 'noteapp.db');
    var database = await openDatabase( // Changed variable name from 'Database' to 'database'
      path,
      version: 1, // Added version parameter
      onCreate: (Database db, int version) async { // Changed parameter name from _db to db
        await db.execute(
          'CREATE TABLE $table(id INTEGER PRIMARY KEY AUTOINCREMENT, date INTEGER, title TEXT, content TEXT)'
        );
      },
    );
    return database;
  }

  Future<void> add(Note note) async {
    var database = await db;
    note.setDate();
    await database.insert(table, note.toMap());
  }

  Future<void> update(Note note) async {
    var database = await db;
    note.setDate();
    await database.update(
      table, 
      note.toMap(), 
      where: 'id = ?', 
      whereArgs: [note.id]
    );
  }

  Future<void> delete(Note note) async {
    var database = await db;
    await database.delete(
      table, 
      where: 'id = ?', // Removed note.toMap() from delete parameters
      whereArgs: [note.id]
    );
  }

  Future<List<Note>> getNotes() async {
    var database = await db;
    List<Map<String, dynamic>> maps = await database.query(
      table,
      orderBy: 'date DESC' // Simplified query using query() instead of rawQuery
    );

    List<Note> notes = []; // Modern list initialization

    for (var map in maps) { // Fixed syntax and added missing parenthesis
      notes.add(Note.fromMap(map));
    }
    return notes;
  }
}