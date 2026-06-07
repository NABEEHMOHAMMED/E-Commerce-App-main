import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CartDatabaseHelper {
  static final CartDatabaseHelper instance = CartDatabaseHelper._init();
  static Database? _database;

  CartDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT,
        quantity INTEGER NOT NULL,
        userId TEXT NOT NULL,
        PRIMARY KEY (id, userId)
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> query(String table, String? userId) async {
    if (kIsWeb) return [];
    final db = await instance.database;
    if (userId != null) {
      return await db.query(table, where: 'userId = ?', whereArgs: [userId]);
    } else {
      return await db.query(table);
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.insert('cart_items', row);
  }

  Future<int> update(Map<String, dynamic> row) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.update(
      'cart_items',
      row,
      where: 'id = ? AND userId = ?',
      whereArgs: [row['id'], row['userId']],
    );
  }

  Future<int> delete(String id, String userId) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.delete(
      'cart_items',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteAll(String userId) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.delete(
      'cart_items',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}