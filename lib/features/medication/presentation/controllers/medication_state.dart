import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_entity.dart';

abstract class MedicationState extends Equatable {
  const MedicationState();
  @override
  List<Object?> get props => [];
}

class MedicationInitial extends MedicationState {
  const MedicationInitial();
}

class MedicationLoading extends MedicationState {
  const MedicationLoading();
}

class MedicationLoaded extends MedicationState {
  final List<MedicationEntity> medications;
  const MedicationLoaded(this.medications);
  @override
  List<Object?> get props => [medications];
}

class MedicationError extends MedicationState {
  final String message;
  const MedicationError(this.message);
  @override
  List<Object?> get props => [message];
}

// Estado del formulario de agregar medicamento
class MedicationFormState extends Equatable {
  final String name;
  final String dosage;
  final bool reminderEnabled;
  final List<String> times;
  final List<String> days;
  final int intervalHours;

  const MedicationFormState({
    this.name = '',
    this.dosage = '',
    this.reminderEnabled = true,
    this.times = const ['08:00 AM'],
    this.days = const ['L'],
    this.intervalHours = 8,
  });

  MedicationFormState copyWith({
    String? name,
    String? dosage,
    bool? reminderEnabled,
    List<String>? times,
    List<String>? days,
    int? intervalHours,
  }) {
    return MedicationFormState(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      times: times ?? this.times,
      days: days ?? this.days,
      intervalHours: intervalHours ?? this.intervalHours,
    );
  }

  @override
  List<Object?> get props => [
        name, dosage, reminderEnabled,
        times, days, intervalHours,
      ];
}