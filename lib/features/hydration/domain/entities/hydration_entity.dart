import 'package:equatable/equatable.dart';

class HydrationEntity extends Equatable {
  final int id;
  final String userId;
  final int amountMl;
  final DateTime loggedAt;

  const HydrationEntity({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [id, userId, amountMl, loggedAt];
}

/// Resumen del día — lo que muestra la pantalla
class HydrationSummary extends Equatable {
  final int totalMl;
  final int goalMl;
  final int totalGlasses;
  final int goalGlasses;
  final int streakDays;
  final List<HydrationEntity> logs;

  const HydrationSummary({
    required this.totalMl,
    required this.goalMl,
    required this.totalGlasses,
    required this.goalGlasses,
    required this.streakDays,
    required this.logs,
  });

  double get progressPercent =>
      goalMl == 0 ? 0 : (totalMl / goalMl).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        totalMl,
        goalMl,
        totalGlasses,
        goalGlasses,
        streakDays,
        logs,
      ];
}