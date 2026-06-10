import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  final AuthRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user = await remoteDatasource.login(
        email: email,
        password: password,
      );
      // Guarda en local para uso offline
      await localDatasource.cacheUser(user);
      return Right(user);
    } on InvalidCredentialsException {
      return const Left(InvalidCredentialsFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user = await remoteDatasource.register(
        email: email,
        password: password,
        name: name,
      );
      await localDatasource.cacheUser(user);
      return Right(user);
    } on EmailAlreadyInUseException {
      return const Left(EmailAlreadyInUseFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final currentUser = await remoteDatasource.getCurrentUser();
      if (currentUser != null) {
        await localDatasource.clearUser(currentUser.id);
      }
      await remoteDatasource.logout();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // Intenta desde remoto si hay internet
      if (await networkInfo.isConnected) {
        final user = await remoteDatasource.getCurrentUser();
        if (user != null) {
          await localDatasource.cacheUser(user);
          return Right(user);
        }
      }
      // Sin internet — intenta desde local
      final remoteUser = await remoteDatasource.getCurrentUser();
      if (remoteUser != null) {
        final localUser = await localDatasource.getCachedUser(remoteUser.id);
        return Right(localUser);
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}