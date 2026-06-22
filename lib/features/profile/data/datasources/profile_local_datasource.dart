import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/user_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

/// Reutiliza UserDao porque el perfil del paciente y el usuario
/// de auth son la misma entidad de base de datos — no duplicamos la tabla.
abstract class ProfileLocalDatasource {
  Future<ProfileModel?> getProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    String? name,
    double? weightKg,
    double? heightCm,
    int? dailyWaterGoalMl,
  });
}

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  final UserDao userDao;
  const ProfileLocalDatasourceImpl({required this.userDao});

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await userDao.getUser(userId);
      if (data == null) return null;
      return ProfileModel.fromLocal(data);
    } catch (e) {
      throw DatabaseException('Error al leer perfil: $e');
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    double? weightKg,
    double? heightCm,
    int? dailyWaterGoalMl,
  }) async {
    try {
      final current = await userDao.getUser(userId);
      if (current == null) {
        throw const DatabaseException('Usuario no encontrado');
      }
      await userDao.upsertUser(
        UsersTableCompanion(
          id: Value(userId),
          email: Value(current.email),
          name: Value(name ?? current.name),
          photoUrl: Value(current.photoUrl),
          weightKg: Value(weightKg ?? current.weightKg),
          heightCm: Value(heightCm ?? current.heightCm),
          dailyWaterGoalMl:
              Value(dailyWaterGoalMl ?? current.dailyWaterGoalMl),
          createdAt: Value(current.createdAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      throw DatabaseException('Error al actualizar perfil: $e');
    }
  }
}