import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/usecases/get_weekly_progress_usecase.dart';
import 'progress_state.dart';

final progressControllerProvider =
    NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);

class ProgressController extends Notifier<ProgressState> {
  late final GetWeeklyProgressUseCase _getWeeklyProgress;

  static const _tempUserId = 'user_1';

  @override
  ProgressState build() {
    _getWeeklyProgress = sl();
    return const ProgressInitial();
  }

  Future<void> load() async {
    state = const ProgressLoading();

    final result = await _getWeeklyProgress(
      WeeklyProgressParams(
        userId: _tempUserId,
        referenceDate: DateTime.now(),
      ),
    );

    result.fold(
      (failure) => state = ProgressError(failure.message),
      (progress) => state = ProgressLoaded(progress),
    );
  }
}