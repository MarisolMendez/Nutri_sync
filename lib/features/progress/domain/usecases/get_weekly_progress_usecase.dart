import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class GetWeeklyProgressUseCase
    implements UseCase<WeeklyProgressEntity, WeeklyProgressParams> {
  final ProgressRepository repository;
  const GetWeeklyProgressUseCase(this.repository);

  @override
  Future<Either<Failure, WeeklyProgressEntity>> call(
      WeeklyProgressParams params) {
    return repository.getWeeklyProgress(
      userId: params.userId,
      referenceDate: params.referenceDate,
    );
  }
}

class WeeklyProgressParams extends Equatable {
  final String userId;
  final DateTime referenceDate;

  const WeeklyProgressParams({
    required this.userId,
    required this.referenceDate,
  });

  @override
  List<Object> get props => [userId, referenceDate];
}