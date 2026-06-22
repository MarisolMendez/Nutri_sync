import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDatasource localDatasource;
  const MedicationRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<MedicationEntity>>> getMedications({
    required String userId,
  }) async {
    try {
      final meds = await localDatasource.getMedications(userId);
      return Right(meds);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMedication({
    required String userId,
    required String name,
    required String dosage,
    required bool reminderEnabled,
    required List<String> times,
    required List<String> days,
    int? intervalHours,
  }) async {
    try {
      await localDatasource.saveMedication(
        userId: userId,
        name: name,
        dosage: dosage,
        reminderEnabled: reminderEnabled,
        times: times,
        days: days,
        intervalHours: intervalHours,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication({required int id}) async {
    try {
      await localDatasource.deleteMedication(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logMedicationTaken({
    required int medicationId,
  }) async {
    try {
      await localDatasource.logTaken(medicationId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<int>>> getTodayTakenIds() async {
    try {
      final ids = await localDatasource.getTodayTakenIds();
      return Right(ids);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}