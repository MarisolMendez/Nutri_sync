import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDatasource localDatasource;
  const ProfileRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile({
    required String userId,
  }) async {
    try {
      final profile = await localDatasource.getProfile(userId);
      return Right(profile);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? name,
    double? weightKg,
    double? heightCm,
    int? dailyWaterGoalMl,
  }) async {
    try {
      await localDatasource.updateProfile(
        userId: userId,
        name: name,
        weightKg: weightKg,
        heightCm: heightCm,
        dailyWaterGoalMl: dailyWaterGoalMl,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}