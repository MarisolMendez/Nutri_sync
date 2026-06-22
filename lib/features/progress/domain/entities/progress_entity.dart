import 'package:equatable/equatable.dart';

class WeeklyProgressEntity extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;

  final int mealsConsumed;
  final int mealsTotal;

  final double avgHydrationPercent;

  final List<int> mealsConsumedByDay;
  final List<int> mealsTotalByDay;

  final List<String?> moodByDay;

  final String? mainMedicationName;
  final int medicationDaysTaken;
  final int medicationDaysScheduled;

  final double? adherenceChangePercent;

  const WeeklyProgressEntity({
    required this.weekStart,
    required this.weekEnd,
    required this.mealsConsumed,
    required this.mealsTotal,
    required this.avgHydrationPercent,
    required this.mealsConsumedByDay,
    required this.mealsTotalByDay,
    required this.moodByDay,
    this.mainMedicationName,
    this.medicationDaysTaken = 0,
    this.medicationDaysScheduled = 0,
    this.adherenceChangePercent,
  });

  double get adherencePercent =>
      mealsTotal == 0 ? 0 : (mealsConsumed / mealsTotal).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        mealsConsumed,
        mealsTotal,
        avgHydrationPercent,
        mealsConsumedByDay,
        moodByDay,
        mainMedicationName,
        medicationDaysTaken,
        medicationDaysScheduled,
        adherenceChangePercent,
      ];
}