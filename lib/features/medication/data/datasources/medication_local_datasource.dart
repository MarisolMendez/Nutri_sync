import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/medication_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../models/medication_model.dart';

abstract class MedicationLocalDatasource {
  Future<List<MedicationModel>> getMedications(String userId);
  Future<void> saveMedication({
    required String userId,
    required String name,
    required String dosage,
    required bool reminderEnabled,
    required List<String> times,
    required List<String> days,
    int? intervalHours,
  });
  Future<void> deleteMedication(int id);
  Future<void> logTaken(int medicationId);
}

class MedicationLocalDatasourceImpl implements MedicationLocalDatasource {
  final MedicationDao medicationDao;
  const MedicationLocalDatasourceImpl({required this.medicationDao});

  @override
  Future<List<MedicationModel>> getMedications(String userId) async {
    try {
      final data = await medicationDao.getMedications(userId);
      return data.map((d) => MedicationModel.fromLocal(d)).toList();
    } catch (e) {
      throw DatabaseException('Error al leer medicamentos: $e');
    }
  }

  @override
  Future<void> saveMedication({
    required String userId,
    required String name,
    required String dosage,
    required bool reminderEnabled,
    required List<String> times,
    required List<String> days,
    int? intervalHours,
  }) async {
    try {
      await medicationDao.upsertMedication(
        MedicationsTableCompanion(
          userId: Value(userId),
          name: Value(name),
          dosage: Value(dosage),
          reminderEnabled: Value(reminderEnabled),
          timesJson: Value(jsonEncode(times)),
          daysJson: Value(jsonEncode(days)),
          intervalHours: Value(intervalHours),
        ),
      );
    } catch (e) {
      throw DatabaseException('Error al guardar medicamento: $e');
    }
  }

  @override
  Future<void> deleteMedication(int id) async {
    try {
      await medicationDao.deleteMedication(id);
    } catch (e) {
      throw DatabaseException('Error al eliminar medicamento: $e');
    }
  }

  @override
  Future<void> logTaken(int medicationId) async {
    try {
      await medicationDao.insertLog(
        MedicationLogsTableCompanion(
          medicationId: Value(medicationId),
        ),
      );
    } catch (e) {
      throw DatabaseException('Error al registrar toma: $e');
    }
  }
}