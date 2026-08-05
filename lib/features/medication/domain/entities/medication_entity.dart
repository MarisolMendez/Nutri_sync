import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final int id;
  final String? remoteId;
  final String userId;
  final String name;
  final String dosage;
  final bool reminderEnabled;
  final List<String> times; // ["08:00 AM", "04:00 PM", "10:00 PM"]
  final List<String> days;  // ["L", "M", "M", "J", "V", "S", "D"]
  final int? intervalHours;
  final DateTime createdAt;

  const MedicationEntity({
    required this.id,
    this.remoteId,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.reminderEnabled,
    required this.times,
    required this.days,
    this.intervalHours,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, remoteId, userId, name, dosage,
        reminderEnabled, times, days,
        intervalHours, createdAt,
      ];
}
