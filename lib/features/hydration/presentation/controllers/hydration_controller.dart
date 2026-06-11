import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/usecases/get_daily_hydration_usecase.dart';
import '../../domain/usecases/log_water_usecase.dart';
import 'hydration_state.dart';

final hydrationControllerProvider =
    NotifierProvider<HydrationController, HydrationState>(
  HydrationController.new,
);

class HydrationController extends Notifier<HydrationState> {
  final GetDailyHydrationUseCase _getDailyHydration;
  final LogWaterUseCase _logWater;

  // Usuario temporal hasta conectar auth
  static const _tempUserId = 'user_1';

  HydrationController()
      : _getDailyHydration = sl(),
        _logWater = sl();

  @override
  HydrationState build() {
    return const HydrationInitial();
  }

  Future<void> loadToday() async {
    state = const HydrationLoading();

    final result = await _getDailyHydration(
      HydrationParams(userId: _tempUserId, date: DateTime.now()),
    );

    result.fold(
      (failure) => state = HydrationError(failure.message),
      (summary) => state = HydrationLoaded(summary: summary),
    );
  }

  Future<void> addWater(int amountMl) async {
    final result = await _logWater(
      LogWaterParams(userId: _tempUserId, amountMl: amountMl),
    );

    result.fold(
      (failure) => state = HydrationError(failure.message),
      (_) => loadToday(),
    );
  }

  void updateCustomAmount(int amountMl) {
    if (state is HydrationLoaded) {
      state = (state as HydrationLoaded).copyWith(customAmountMl: amountMl);
    }
  }
}