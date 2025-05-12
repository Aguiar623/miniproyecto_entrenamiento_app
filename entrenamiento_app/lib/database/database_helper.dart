import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('entrenamiento.db');
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
    // tabla para la creacion de usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    // tabla para historial de pasos
    await db.execute(''' 
      CREATE TABLE step_history (
        user_id INTEGER,
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steps INTEGER NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla para historial de ubicaciones
    await db.execute(''' 
      CREATE TABLE location_history (
        user_id INTEGER,
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> saveLocation(double latitude, double longitude, int userId) async {
    final db = await database;
    await db.insert(
      'location_history',
      {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Función para guardar los pasos
  Future<void> saveSteps(int steps, int userId) async {
    final db = await database;
    await db.insert(
      'step_history',
      {
        'user_id': userId,
        'steps': steps,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener historial de ubicaciones
  Future<List<Map<String, dynamic>>> getLocationHistory(int userId) async {
    final db = await database;
    return await db.query(
      'location_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Obtener historial de pasos
  Future<List<Map<String, dynamic>>> getStepHistory(int userId) async {
    final db = await database;
    return await db.query(
      'step_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> verUsuarios() async {
    final db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query("users");

      if (result.isEmpty) {
        print("No hay usuarios en la base de datos.");
      } else {
        print("Lista de usuarios:");
        for (var row in result) {
          print(row);
        }
      }
    } catch (e) {
      print("Error al obtener los usuarios: $e");
    }
  }
}

