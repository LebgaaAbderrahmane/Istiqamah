import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../data/models/habit_log_model.dart';
import '../data/models/habit_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'istiqamah.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habit (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            type TEXT NOT NULL,
            targetValue INTEGER NOT NULL,
            unit TEXT,
            isCustom INTEGER NOT NULL DEFAULT 0,
            isArchived INTEGER NOT NULL DEFAULT 0,
            sortOrder INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_log (
            id TEXT PRIMARY KEY,
            habitId TEXT NOT NULL,
            date TEXT NOT NULL,
            value INTEGER NOT NULL,
            loggedAt TEXT NOT NULL,
            FOREIGN KEY (habitId) REFERENCES habit(id),
            UNIQUE(habitId, date)
          )
        ''');
        await db.execute('CREATE INDEX idx_habit_log_habit_date ON habit_log(habitId, date)');
        await _seedDefaultHabits(db);
      },
    );
  }

  Future<void> _seedDefaultHabits(Database db) async {
    final uuid = const Uuid();
    final now = DateTime.now();
    for (var i = 0; i < DefaultHabits.habits.length; i++) {
      final h = DefaultHabits.habits[i];
      await db.insert('habit', {
        'id': uuid.v4(),
        'name': h['name'],
        'icon': h['icon'],
        'type': h['type'],
        'targetValue': h['targetValue'],
        'unit': h['unit'],
        'isCustom': 0,
        'isArchived': 0,
        'sortOrder': i,
        'createdAt': now.toIso8601String(),
      });
    }
  }

  Future<void> insertHabit(HabitModel habit) async {
    final db = await database;
    await db.insert('habit', habit.toMap());
  }

  Future<void> updateHabit(HabitModel habit) async {
    final db = await database;
    await db.update('habit', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> updateHabitOrder(List<Map<String, dynamic>> idOrderPairs) async {
    final db = await database;
    final batch = db.batch();
    for (final pair in idOrderPairs) {
      batch.update(
        'habit',
        {'sortOrder': pair['sortOrder']},
        where: 'id = ?',
        whereArgs: [pair['id']],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habit_log', where: 'habitId = ?', whereArgs: [id]);
    await db.delete('habit', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HabitModel>> getAllHabits({bool includeArchived = false}) async {
    final db = await database;
    final where = includeArchived ? null : 'isArchived = 0';
    final maps = await db.query('habit', where: where, orderBy: 'sortOrder ASC');
    return maps.map((m) => HabitModel.fromMap(m)).toList();
  }

  Future<HabitModel?> getHabitById(String id) async {
    final db = await database;
    final maps = await db.query('habit', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return HabitModel.fromMap(maps.first);
  }

  Future<void> upsertLog(HabitLogModel log) async {
    final db = await database;
    await db.insert(
      'habit_log',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HabitLogModel?> getLog(String habitId, DateTime date) async {
    final db = await database;
    final dateStr = HabitLogModel.normalizeDate(date);
    final maps = await db.query(
      'habit_log',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
    if (maps.isEmpty) return null;
    return HabitLogModel.fromMap(maps.first);
  }

  Future<List<HabitLogModel>> getLogsForDate(DateTime date) async {
    final db = await database;
    final dateStr = HabitLogModel.normalizeDate(date);
    final maps = await db.query(
      'habit_log',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return maps.map((m) => HabitLogModel.fromMap(m)).toList();
  }

  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    final db = await database;
    final maps = await db.query(
      'habit_log',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    return maps.map((m) => HabitLogModel.fromMap(m)).toList();
  }

  Future<List<HabitLogModel>> getLogsForDateRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final startStr = HabitLogModel.normalizeDate(start);
    final endStr = HabitLogModel.normalizeDate(end);
    final maps = await db.query(
      'habit_log',
      where: 'habitId = ? AND date >= ? AND date <= ?',
      whereArgs: [habitId, startStr, endStr],
      orderBy: 'date ASC',
    );
    return maps.map((m) => HabitLogModel.fromMap(m)).toList();
  }

  Future<Map<String, List<HabitLogModel>>> getAllLogsGroupedByDate(
    DateTime monthStart,
    DateTime monthEnd,
  ) async {
    final db = await database;
    final startStr = HabitLogModel.normalizeDate(monthStart);
    final endStr = HabitLogModel.normalizeDate(monthEnd);
    final maps = await db.query(
      'habit_log',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );
    final logs = maps.map((m) => HabitLogModel.fromMap(m)).toList();
    final grouped = <String, List<HabitLogModel>>{};
    for (final log in logs) {
      final dateStr = HabitLogModel.normalizeDate(log.date);
      grouped.putIfAbsent(dateStr, () => []).add(log);
    }
    return grouped;
  }
}
