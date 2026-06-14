import 'dart:convert';
import '../../domain/entities/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.dosage,
    required super.reminderEnabled,
    required super.times,
    required super.days,
    super.intervalHours,
    required super.createdAt,
  });

  factory MedicationModel.fromLocal(dynamic data) {
    return MedicationModel(
      id: data.id,
      userId: data.userId,
      name: data.name,
      dosage: data.dosage,
      reminderEnabled: data.reminderEnabled,
      times: List<String>.from(jsonDecode(data.timesJson)),
      days: List<String>.from(jsonDecode(data.daysJson)),
      intervalHours: data.intervalHours,
      createdAt: data.createdAt,
    );
  }
}