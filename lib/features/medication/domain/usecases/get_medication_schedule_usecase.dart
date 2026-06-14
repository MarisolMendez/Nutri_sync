import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class GetMedicationScheduleUseCase
    implements UseCase<List<MedicationEntity>, MedicationParams> {
  final MedicationRepository repository;
  const GetMedicationScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, List<MedicationEntity>>> call(
      MedicationParams params) {
    return repository.getMedications(userId: params.userId);
  }
}

class MedicationParams extends Equatable {
  final String userId;
  const MedicationParams({required this.userId});

  @override
  List<Object> get props => [userId];
}