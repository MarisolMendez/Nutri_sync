import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication_entity.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<MedicationEntity>>> getMedications({
    required String userId,
  });

  Future<Either<Failure, void>> saveMedication({
    required String userId,
    required String name,
    required String dosage,
    required bool reminderEnabled,
    required List<String> times,
    required List<String> days,
    int? intervalHours,
  });

  Future<Either<Failure, void>> deleteMedication({
    required int id,
    String? remoteId,
  });

  Future<Either<Failure, void>> logMedicationTaken({
    required int medicationId,
  });

  Future<Either<Failure, Set<int>>> getTodayTakenIds();
}
