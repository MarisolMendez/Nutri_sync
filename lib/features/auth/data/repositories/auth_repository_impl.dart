import 'package:dartz/dartz.dart';
import '../../../../core/database/daos/user_dao.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  final UserDao userDao;
  static const _cachedUserId = 'user_1';

  const AuthRepositoryImpl({
    required this.localDatasource,
    required this.userDao,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    final user = UserModel(
      id: _cachedUserId,
      email: email,
      name: 'Usuario NutriSync',
      createdAt: DateTime.now(),
    );
    await localDatasource.cacheUser(user);
    await _syncToLocalDb(user);
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = UserModel(
      id: _cachedUserId,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    await localDatasource.cacheUser(user);
    await _syncToLocalDb(user);
    return Right(user);
  }

  /// Guarda o actualiza el usuario también en SQLite (Drift) para que
  /// el perfil pueda leerlo desde [ProfileLocalDatasource].
  Future<void> _syncToLocalDb(UserModel user) async {
    await userDao.createOrUpdate(
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDatasource.clearUser(_cachedUserId);
      await userDao.deleteUser(_cachedUserId);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDatasource.getCachedUser(_cachedUserId);
      return Right(user);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}