enum ScheduleType { daily, weekly }

class Habit {
  final String id;
  final String name;
  final ScheduleType scheduleType;
  final List<int>? scheduleDays;
  final String? reminderTime;
  final DateTime createdAt;
  final bool archived;

  const Habit({
    required this.id,
    required this.name,
    required this.scheduleType,
    this.scheduleDays,
    this.reminderTime,
    required this.createdAt,
    required this.archived,
  });
}
