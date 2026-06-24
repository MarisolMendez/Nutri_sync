import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/usecases/get_medication_schedule_usecase.dart';
import '../../domain/usecases/log_medication_usecase.dart';
import 'medication_state.dart';

final medicationControllerProvider =
    NotifierProvider<MedicationController, MedicationState>(
  MedicationController.new,
);

// Provider separado para el formulario
final medicationFormProvider =
    NotifierProvider<MedicationFormController, MedicationFormState>(
  MedicationFormController.new,
);

class MedicationController extends Notifier<MedicationState> {
  late final GetMedicationScheduleUseCase _getSchedule;
  late final LogMedicationUseCase _logMedication;
  late final NotificationService _notificationService;

  static const _tempUserId = 'user_1';

  @override
  MedicationState build() {
    _getSchedule = sl();
    _logMedication = sl();
    _notificationService = sl();
    return const MedicationInitial();
  }

  Future<void> load() async {
    state = const MedicationLoading();
    final result = await _getSchedule(
      const MedicationParams(userId: _tempUserId),
    );
    result.fold(
      (failure) => state = MedicationError(failure.message),
      (meds) => state = MedicationLoaded(meds),
    );
  }

  Future<void> saveMedication(MedicationFormState form) async {
    final result = await _logMedication(
      LogMedicationParams(
        userId: _tempUserId,
        name: form.name,
        dosage: form.dosage,
        reminderEnabled: form.reminderEnabled,
        times: form.times,
        days: form.days,
        intervalHours: form.intervalHours,
      ),
    );
    result.fold(
      (failure) => state = MedicationError(failure.message),
      (_) async {
        // Programa un recordatorio local por cada hora configurada.
        // El id se genera combinando el nombre y la hora para que
        // sea estable y se pueda cancelar/reprogramar después.
        if (form.reminderEnabled) {
          for (final time in form.times) {
            final parsed = _parseTime(time);
            if (parsed == null) continue;
            await _notificationService.scheduleMedicationReminder(
              id: _stableId(form.name, time),
              medicationName: form.name,
              dosage: form.dosage,
              hour: parsed.hour,
              minute: parsed.minute,
            );
          }
        }
        load();
      },
    );
  }

  /// Convierte "08:00 AM" a un DateTime de hoy con esa hora.
  /// Retorna null si el formato no es el esperado.
  DateTime? _parseTime(String time) {
    try {
      final parts = time.split(' ');
      final hm = parts[0].split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Genera un id numérico estable a partir del nombre+hora,
  /// para poder cancelar ese recordatorio específico después.
  int _stableId(String name, String time) =>
      ('$name$time'.hashCode).abs() % 100000 + 1000; // rango 1000-100999
}

class MedicationFormController extends Notifier<MedicationFormState> {
  @override
  MedicationFormState build() => const MedicationFormState();

  void updateName(String v) => state = state.copyWith(name: v);
  void updateDosage(String v) => state = state.copyWith(dosage: v);
  void toggleReminder(bool v) => state = state.copyWith(reminderEnabled: v);
  void updateIntervalHours(int v) => state = state.copyWith(intervalHours: v);

  void addTime(String time) {
    if (!state.times.contains(time)) {
      state = state.copyWith(times: [...state.times, time]);
    }
  }

  void removeTime(String time) {
    state = state.copyWith(
      times: state.times.where((t) => t != time).toList(),
    );
  }

  void toggleDay(String day) {
    final days = List<String>.from(state.days);
    days.contains(day) ? days.remove(day) : days.add(day);
    state = state.copyWith(days: days);
  }

  void reset() => state = const MedicationFormState();
}