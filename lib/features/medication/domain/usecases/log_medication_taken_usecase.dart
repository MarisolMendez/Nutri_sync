import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medication_repository.dart';

class LogMedicationTakenUseCase
    implements UseCase<void, LogMedicationTakenParams> {
  final MedicationRepository repository;
  const LogMedicationTakenUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LogMedicationTakenParams params) {
    return repository.logMedicationTaken(medicationId: params.medicationId);
  }
}

class LogMedicationTakenParams extends Equatable {
  final int medicationId;
  const LogMedicationTakenParams({required this.medicationId});

  @override
  List<Object> get props => [medicationId];
}