class HabitCompletion {
  final String id;
  final String habitId;
  final String date; // YYYY-MM-DD
  final DateTime completedAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
  });
}
