import 'package:equatable/equatable.dart';

enum MoodValue {
  excellent('Excelente', '😊', 'excellent'),
  good('Bien', '😊', 'good'),
  neutral('Neutral', '🙂', 'neutral'),
  bad('Mal', '😟', 'bad');

  const MoodValue(this.label, this.emoji, this.dbValue);

  final String label;
  final String emoji;
  final String dbValue;

  static MoodValue fromString(String value) {
    return MoodValue.values.firstWhere(
      (v) => v.dbValue == value,
      orElse: () => MoodValue.neutral,
    );
  }
}

class MoodEntity extends Equatable {
  final int id;
  final String userId;
  final MoodValue mood;
  final String? note;
  final DateTime loggedAt;

  const MoodEntity({
    required this.id,
    required this.userId,
    required this.mood,
    this.note,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [id, userId, mood, note, loggedAt];
}

/// Resumen semanal — lo que muestra la sección "Esta semana"
class WeekMoodSummary extends Equatable {
  final List<MoodEntity?> days; // 7 elementos, null si no hay registro ese día

  const WeekMoodSummary({required this.days});

  @override
  List<Object?> get props => [days];
}