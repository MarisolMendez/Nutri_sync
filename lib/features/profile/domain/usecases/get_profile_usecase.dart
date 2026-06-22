import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase
    implements UseCase<ProfileEntity?, ProfileParams> {
  final ProfileRepository repository;
  const GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity?>> call(ProfileParams params) {
    return repository.getProfile(userId: params.userId);
  }
}

class ProfileParams extends Equatable {
  final String userId;
  const ProfileParams({required this.userId});
  @override
  List<Object> get props => [userId];
}