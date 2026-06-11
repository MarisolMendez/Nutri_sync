import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mood_entity.dart';
import '../repositories/mood_repository.dart';

class LogMoodUseCase implements UseCase<void, LogMoodParams> {
  final MoodRepository repository;
  const LogMoodUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LogMoodParams params) {
    return repository.logMood(
      userId: params.userId,
      mood: params.mood,
      note: params.note,
    );
  }
}

class LogMoodParams extends Equatable {
  final String userId;
  final MoodValue mood;
  final String? note;

  const LogMoodParams({
    required this.userId,
    required this.mood,
    this.note,
  });

  @override
  List<Object?> get props => [userId, mood, note];
}