import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
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

  static const _tempUserId = 'user_1';

  @override
  MedicationState build() {
    _getSchedule = sl();
    _logMedication = sl();
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
      (_) => load(),
    );
  }
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
