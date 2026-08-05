import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/database/daos/user_dao.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  final UserDao userDao;
  final FirebaseAuth? firebaseAuth;
  final AuthRemoteDatasource remoteDatasource;
  final bool useFirebase;
  static const _cachedUserId = 'user_1';

  const AuthRepositoryImpl({
    required this.localDatasource,
    required this.userDao,
    this.firebaseAuth,
    required this.remoteDatasource,
    required this.useFirebase,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (useFirebase) {
      return _loginWithFirebase(email: email, password: password);
    }
    return _loginWithBackend(email: email, password: password);
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (useFirebase) {
      return _registerWithFirebase(email: email, password: password, name: name);
    }
    return _registerWithBackend(email: email, password: password, name: name);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (useFirebase) {
        await firebaseAuth?.signOut();
      } else {
        await remoteDatasource.logout();
      }
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

  // ── Firebase ──────────────────────────────────────────

  Future<Either<Failure, UserEntity>> _loginWithFirebase({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Left(UnexpectedFailure('Error al iniciar sesión'));
      }
      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: firebaseUser.displayName ?? 'Usuario NutriSync',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
      await _cacheUser(user);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(UnexpectedFailure(_mapFirebaseError(e)));
    }
  }

  Future<Either<Failure, UserEntity>> _registerWithFirebase({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Left(UnexpectedFailure('Error al crear la cuenta'));
      }
      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();
      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: name,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
      await _cacheUser(user);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(UnexpectedFailure(_mapFirebaseError(e)));
    }
  }

  // ── Backend propio ────────────────────────────────────

  Future<Either<Failure, UserEntity>> _loginWithBackend({
    required String email,
    required String password,
  }) async {
    final result = await remoteDatasource.login(
      email: email,
      password: password,
    );
    return result.fold(
      (failure) => Left(failure),
      (user) async {
        await _cacheUser(user);
        return Right(user);
      },
    );
  }

  Future<Either<Failure, UserEntity>> _registerWithBackend({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await remoteDatasource.register(
      name: name,
      email: email,
      password: password,
    );
    return result.fold(
      (failure) => Left(failure),
      (user) async {
        await _cacheUser(user);
        return Right(user);
      },
    );
  }

  // ── Utilidades ───────────────────────────────────────

  Future<void> _cacheUser(UserModel user) async {
    await localDatasource.cacheUser(user);
    await userDao.createOrUpdate(
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}