import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;
  const UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      userId: params.userId,
      name: params.name,
      weightKg: params.weightKg,
      heightCm: params.heightCm,
      dailyWaterGoalMl: params.dailyWaterGoalMl,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String? name;
  final double? weightKg;
  final double? heightCm;
  final int? dailyWaterGoalMl;

  const UpdateProfileParams({
    required this.userId,
    this.name,
    this.weightKg,
    this.heightCm,
    this.dailyWaterGoalMl,
  });

  @override
  List<Object?> get props =>
      [userId, name, weightKg, heightCm, dailyWaterGoalMl];
}