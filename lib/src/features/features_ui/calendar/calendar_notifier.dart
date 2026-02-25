class DailySummary {
  final DateTime date;
  final List<String> completedHabits;
  final List<String> mealsLogged;

  const DailySummary({
    required this.date,
    required this.completedHabits,
    required this.mealsLogged,
  });
}

class CompletedHabit {
  final String id;
  final String name;
  final DateTime completedAt;

  const CompletedHabit({
    required this.id,
    required this.name,
    required this.completedAt,
  });
}

class CompletedByMonth {
  final String habitId;
  final String habitName;
  final int completionsThisMonth;
  final int completedThisMonth;

  const CompletedByMonth({
    required this.habitId,
    required this.habitName,
    required this.completionsThisMonth,
    required this.completedThisMonth,
  });
}

class CompletedThisMonth {
  final String habitId;
  final String habitName;
  final int completedThisMonth;

  int get habitsCompletedThisMonth => completedThisMonth;

  const CompletedThisMonth({
    required this.habitId,
    required this.habitName,
    required this.completedThisMonth,
  });
}
