import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mood_entity.dart';
import '../repositories/mood_repository.dart';

class GetMoodHistoryUseCase implements UseCase<WeekMoodSummary, MoodParams> {
  final MoodRepository repository;
  const GetMoodHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, WeekMoodSummary>> call(MoodParams params) {
    return repository.getWeekSummary(userId: params.userId);
  }
}

class MoodParams extends Equatable {
  final String userId;
  const MoodParams({required this.userId});

  @override
  List<Object> get props => [userId];
}