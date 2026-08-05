import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medication_repository.dart';

class DeleteMedicationUseCase
    implements UseCase<void, DeleteMedicationParams> {
  final MedicationRepository repository;
  const DeleteMedicationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMedicationParams params) {
    return repository.deleteMedication(id: params.id, remoteId: params.remoteId);
  }
}

class DeleteMedicationParams extends Equatable {
  final int id;
  final String? remoteId;
  const DeleteMedicationParams({required this.id, this.remoteId});

  @override
  List<Object?> get props => [id, remoteId];
}
