import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/habit.dart';
import '../models/habit_completion.dart';

class AppDatabase {
  AppDatabase._({DatabaseFactory? databaseFactory, String? dbPath})
      : _databaseFactory = databaseFactory ?? databaseFactoryFfi,
        _dbPath = dbPath;

  static final AppDatabase instance = AppDatabase._();

  factory AppDatabase.forTesting(DatabaseFactory databaseFactory) {
    return AppDatabase._(
      databaseFactory: databaseFactory,
      dbPath: inMemoryDatabasePath,
    );
  }

  final DatabaseFactory _databaseFactory;
  final String? _dbPath;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    sqfliteFfiInit();
    final dbPath = _dbPath ??
        p.join(
          (await getApplicationDocumentsDirectory()).path,
          'habit_tracker.db',
        );

    return _databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(_createHabitsTable);
          await db.execute(_createCompletionsTable);
          await db.execute(_createCompletionIndex);
        },
      ),
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  // Habits
  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert('habits', _habitToMap(habit));
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      _habitToMap(habit),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> archiveHabit(String habitId) async {
    final db = await database;
    await db.update(
      'habits',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  Future<List<Habit>> listActiveHabits() async {
    final db = await database;
    final rows = await db.query(
      'habits',
      where: 'archived = 0',
      orderBy: 'created_at ASC',
    );
    return rows.map(_habitFromMap).toList();
  }

  // Completions
  Future<void> insertCompletion(HabitCompletion completion) async {
    final db = await database;
    await db.insert('habit_completions', _completionToMap(completion));
  }

  Future<void> deleteCompletion(String habitId, String date) async {
    final db = await database;
    await db.delete(
      'habit_completions',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
    );
  }

  Future<List<HabitCompletion>> getCompletionsForDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'habit_completions',
      where: 'date = ?',
      whereArgs: [date],
    );
    return rows.map(_completionFromMap).toList();
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final db = await database;
    final rows = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    return rows.map(_completionFromMap).toList();
  }

  // Mapping helpers
  Map<String, Object?> _habitToMap(Habit habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'schedule_type': habit.scheduleType.name,
      'schedule_days': habit.scheduleDays == null
          ? null
          : jsonEncode(habit.scheduleDays),
      'reminder_time': habit.reminderTime,
      'created_at': habit.createdAt.toIso8601String(),
      'archived': habit.archived ? 1 : 0,
    };
  }

  Habit _habitFromMap(Map<String, Object?> map) {
    final scheduleType = ScheduleType.values.firstWhere(
      (value) => value.name == map['schedule_type'],
    );
    final scheduleDaysRaw = map['schedule_days'] as String?;
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      scheduleType: scheduleType,
      scheduleDays: scheduleDaysRaw == null
          ? null
          : (jsonDecode(scheduleDaysRaw) as List).cast<int>(),
      reminderTime: map['reminder_time'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      archived: (map['archived'] as int) == 1,
    );
  }

  Map<String, Object?> _completionToMap(HabitCompletion completion) {
    return {
      'id': completion.id,
      'habit_id': completion.habitId,
      'date': completion.date,
      'completed_at': completion.completedAt.toIso8601String(),
    };
  }

  HabitCompletion _completionFromMap(Map<String, Object?> map) {
    return HabitCompletion(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      date: map['date'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }
}

const String _createHabitsTable = '''
CREATE TABLE habits (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  schedule_type TEXT NOT NULL,
  schedule_days TEXT,
  reminder_time TEXT,
  created_at TEXT NOT NULL,
  archived INTEGER NOT NULL DEFAULT 0
)
''';

const String _createCompletionsTable = '''
CREATE TABLE habit_completions (
  id TEXT PRIMARY KEY,
  habit_id TEXT NOT NULL,
  date TEXT NOT NULL,
  completed_at TEXT NOT NULL,
  UNIQUE(habit_id, date)
)
''';

const String _createCompletionIndex =
    'CREATE INDEX idx_habit_completion ON habit_completions(habit_id, date)';
