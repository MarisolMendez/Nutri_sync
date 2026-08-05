import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../domain/usecases/get_daily_hydration_usecase.dart';
import '../../domain/usecases/log_water_usecase.dart';
import 'hydration_state.dart';

final hydrationControllerProvider =
    NotifierProvider<HydrationController, HydrationState>(
  HydrationController.new,
);

class HydrationController extends Notifier<HydrationState> {
  late final GetDailyHydrationUseCase _getDailyHydration;
  late final LogWaterUseCase _logWater;
  late final NotificationService _notificationService;

  String get _userId {
    final authState = ref.read(authControllerProvider);
    return authState is AuthAuthenticated ? authState.user.id : 'anon';
  }

  @override
  HydrationState build() {
    _getDailyHydration = sl();
    _logWater = sl();
    _notificationService = sl();
    return const HydrationInitial();
  }

  Future<void> loadToday() async {
    state = const HydrationLoading();

    final result = await _getDailyHydration(
      HydrationParams(userId: _userId, date: DateTime.now()),
    );

    result.fold(
      (failure) => state = HydrationError(failure.message),
      (summary) => state = HydrationLoaded(summary: summary),
    );
  }

  Future<void> addWater(int amountMl) async {
    // Si ya alcanzó la meta, no permitir más registros
    if (state is HydrationLoaded) {
      final current = state as HydrationLoaded;
      if (current.summary.totalMl >= current.summary.goalMl) {
        return;
      }
    }

    final result = await _logWater(
      LogWaterParams(userId: _userId, amountMl: amountMl),
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

  /// Activa recordatorios cada [intervalHours] horas entre las 8am y 10pm.
  /// Se llama desde un toggle de configuración o tras completar el registro.
  Future<void> enableReminders({int intervalHours = 2}) =>
      _notificationService.scheduleHydrationReminders(
        intervalHours: intervalHours,
      );

  Future<void> disableReminders() =>
      _notificationService.cancelHydrationReminders();
}