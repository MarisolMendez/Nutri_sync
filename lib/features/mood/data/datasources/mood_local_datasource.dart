import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/mood_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/mood_entity.dart';
import '../models/mood_model.dart';

abstract class MoodLocalDatasource {
  Future<MoodModel?> getTodayMood(String userId);
  Future<List<MoodModel>> getWeekMoods(String userId);
  Future<void> saveMood(String userId, MoodValue mood, String? note);
}

class MoodLocalDatasourceImpl implements MoodLocalDatasource {
  final MoodDao moodDao;
  const MoodLocalDatasourceImpl({required this.moodDao});

  @override
  Future<MoodModel?> getTodayMood(String userId) async {
    try {
      final data = await moodDao.getTodayMood(userId);
      if (data == null) return null;
      return MoodModel.fromLocal(data);
    } catch (e) {
      throw DatabaseException('Error al leer mood de hoy: $e');
    }
  }

  @override
  Future<List<MoodModel>> getWeekMoods(String userId) async {
    try {
      final data = await moodDao.getWeekMoods(userId);
      return data.map((d) => MoodModel.fromLocal(d)).toList();
    } catch (e) {
      throw DatabaseException('Error al leer historial de mood: $e');
    }
  }

  @override
  Future<void> saveMood(String userId, MoodValue mood, String? note) async {
    try {
      await moodDao.upsertMood(
        MoodTableCompanion(
          userId: Value(userId),
          moodValue: Value(mood.dbValue),
          note: Value(note),
          loggedAt: Value(DateTime.now()),
          isSynced: const Value(false),
        ),
      );
    } catch (e) {
      throw DatabaseException('Error al guardar mood: $e');
    }
  }
}