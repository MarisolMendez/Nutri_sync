import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hydration_entity.dart';
import '../repositories/hydration_repository.dart';

class GetDailyHydrationUseCase
    implements UseCase<HydrationSummary, HydrationParams> {
  final HydrationRepository repository;
  const GetDailyHydrationUseCase(this.repository);

  @override
  Future<Either<Failure, HydrationSummary>> call(HydrationParams params) {
    return repository.getDailySummary(
      userId: params.userId,
      date: params.date,
    );
  }
}

class HydrationParams extends Equatable {
  final String userId;
  final DateTime date;

  const HydrationParams({required this.userId, required this.date});

  @override
  List<Object> get props => [userId, date];
}