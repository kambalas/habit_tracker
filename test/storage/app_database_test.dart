import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/habit_completion.dart';
import 'package:habit_tracker/storage/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
  });

  test('inserts and reads habits', () async {
    final db = AppDatabase.forTesting(databaseFactoryFfi);

    final habit = Habit(
      id: 'habit-1',
      name: 'Read',
      scheduleType: ScheduleType.daily,
      createdAt: DateTime.utc(2026, 1, 1),
      archived: false,
    );

    await db.insertHabit(habit);
    final habits = await db.listActiveHabits();

    expect(habits.length, 1);
    expect(habits.first.name, 'Read');
  });

  test('enforces unique completion per day', () async {
    final db = AppDatabase.forTesting(databaseFactoryFfi);

    final completion = HabitCompletion(
      id: 'completion-1',
      habitId: 'habit-1',
      date: '2026-01-01',
      completedAt: DateTime.utc(2026, 1, 1, 8),
    );

    await db.insertCompletion(completion);

    expect(
      () async => db.insertCompletion(completion),
      throwsA(isA<DatabaseException>()),
    );
  });
}
