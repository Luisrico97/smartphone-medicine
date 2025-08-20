import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blood_pressure.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'blood_pressure.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blood_pressure(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        pulse INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        notes TEXT,
        source TEXT NOT NULL DEFAULT 'manual'
      )
    ''');
  }

  Future<int> insertBloodPressure(BloodPressure bloodPressure) async {
    final db = await database;
    return await db.insert('blood_pressure', bloodPressure.toMap());
  }

  Future<List<BloodPressure>> getAllBloodPressures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return BloodPressure.fromMap(maps[i]);
    });
  }

  Future<List<BloodPressure>> getBloodPressuresInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return BloodPressure.fromMap(maps[i]);
    });
  }

  Future<int> updateBloodPressure(BloodPressure bloodPressure) async {
    final db = await database;
    return await db.update(
      'blood_pressure',
      bloodPressure.toMap(),
      where: 'id = ?',
      whereArgs: [bloodPressure.id],
    );
  }

  Future<int> deleteBloodPressure(int id) async {
    final db = await database;
    return await db.delete(
      'blood_pressure',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
