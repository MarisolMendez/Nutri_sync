import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/meal_plan_repository.dart';

class SaveSubstituteNoteUseCase implements UseCase<void, SaveSubstituteNoteParams> {
  final MealPlanRepository repository;
  const SaveSubstituteNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveSubstituteNoteParams params) {
    return repository.saveSubstituteNote(
      mealId: params.mealId,
      note: params.note,
      voiceNotePath: params.voiceNotePath,
    );
  }
}

class SaveSubstituteNoteParams extends Equatable {
  final String mealId;
  final bool consumed;
  final String? note;
  final String? voiceNotePath;

  const SaveSubstituteNoteParams({
    required this.mealId,
    required this.consumed,
    this.note,
    this.voiceNotePath,
  });

  @override
  List<Object?> get props => [mealId, consumed, note, voiceNotePath];
}