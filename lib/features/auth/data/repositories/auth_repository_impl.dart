import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  static const _cachedUserId = 'user_1';

  const AuthRepositoryImpl({
    required this.localDatasource,
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
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDatasource.clearUser(_cachedUserId);
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
