import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medication_repository.dart';

class LogMedicationUseCase implements UseCase<void, LogMedicationParams> {
  final MedicationRepository repository;
  const LogMedicationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LogMedicationParams params) {
    return repository.saveMedication(
      userId: params.userId,
      name: params.name,
      dosage: params.dosage,
      reminderEnabled: params.reminderEnabled,
      times: params.times,
      days: params.days,
      intervalHours: params.intervalHours,
    );
  }
}

class LogMedicationParams extends Equatable {
  final String userId;
  final String name;
  final String dosage;
  final bool reminderEnabled;
  final List<String> times;
  final List<String> days;
  final int? intervalHours;

  const LogMedicationParams({
    required this.userId,
    required this.name,
    required this.dosage,
    required this.reminderEnabled,
    required this.times,
    required this.days,
    this.intervalHours,
  });

  @override
  List<Object?> get props => [
        userId, name, dosage,
        reminderEnabled, times, days, intervalHours,
      ];
}