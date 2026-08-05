import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';
import '../datasources/medication_remote_datasource.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDatasource localDatasource;
  final MedicationRemoteDatasource remoteDatasource;
  const MedicationRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, List<MedicationEntity>>> getMedications({
    required String userId,
  }) async {
    try {
      // Intentar obtener del remote como fuente principal
      List<MedicationEntity> remoteMeds = [];
      try {
        remoteMeds = await remoteDatasource.listMedications();
      } catch (_) {
        // Si falla la red, usar datos locales
      }

      // Si hay datos remotos, sincronizar local
      if (remoteMeds.isNotEmpty) {
        // Reemplazar datos locales con los remotos
        final localMeds = await localDatasource.getMedications(userId);
        // Eliminar locales que no están en remotos
        final remoteNames = remoteMeds.map((m) => m.name).toSet();
        for (final l in localMeds) {
          if (!remoteNames.contains(l.name)) {
            try { await localDatasource.deleteMedication(l.id); } catch (_) {}
          }
        }
        return Right(remoteMeds);
      }

      // Fallback: usar datos locales
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
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }

    // Sincronizar con backend
    try {
      await remoteDatasource.saveMedication(
        name: name,
        dosage: dosage,
        reminderEnabled: reminderEnabled,
        times: times,
        days: days,
        intervalHours: intervalHours,
      );
    } catch (_) {
      // Error silencioso: los datos ya están guardados localmente
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteMedication({required int id, String? remoteId}) async {
    try {
      await localDatasource.deleteMedication(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }

    // Sincronizar con backend usando remoteId si existe
    try {
      final idToDelete = remoteId ?? id.toString();
      await remoteDatasource.deleteMedication(idToDelete);
    } catch (_) {
      // Error silencioso
    }

    return const Right(null);
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