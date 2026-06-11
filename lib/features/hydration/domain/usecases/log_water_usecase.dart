import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/hydration_repository.dart';

class LogWaterUseCase implements UseCase<void, LogWaterParams> {
  final HydrationRepository repository;
  const LogWaterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LogWaterParams params) {
    return repository.logWater(
      userId: params.userId,
      amountMl: params.amountMl,
    );
  }
}

class LogWaterParams extends Equatable {
  final String userId;
  final int amountMl;

  const LogWaterParams({required this.userId, required this.amountMl});

  @override
  List<Object> get props => [userId, amountMl];
}