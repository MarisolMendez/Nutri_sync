import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../domain/entities/mood_entity.dart';
import '../../domain/usecases/get_mood_history_usecase.dart';
import '../../domain/usecases/log_mood_usecase.dart';
import 'mood_state.dart';

final moodControllerProvider =
    NotifierProvider<MoodController, MoodState>(
  () => MoodController(
    logMood: sl(),
    getMoodHistory: sl(),
  ),
);

class MoodController extends Notifier<MoodState> {
  final LogMoodUseCase _logMood;
  final GetMoodHistoryUseCase _getMoodHistory;

  String get _userId {
    final authState = ref.read(authControllerProvider);
    return authState is AuthAuthenticated ? authState.user.id : 'anon';
  }

  MoodController({
    required LogMoodUseCase logMood,
    required GetMoodHistoryUseCase getMoodHistory,
  })  : _logMood = logMood,
        _getMoodHistory = getMoodHistory;

  @override
  MoodState build() {
    return const MoodInitial();
  }

  Future<void> load() async {
    state = const MoodLoading();

    final weekResult = await _getMoodHistory(
      MoodParams(userId: _userId),
    );

    weekResult.fold(
      (failure) => state = MoodError(failure.message),
      (weekSummary) {
        // Si hoy ya tiene registro lo muestra seleccionado
        final today = weekSummary.days[DateTime.now().weekday - 1];
        state = MoodLoaded(
          todayMood: today,
          weekSummary: weekSummary,
          selectedMood: today?.mood,
        );
      },
    );
  }

  void selectMood(MoodValue mood) {
    if (state is MoodLoaded) {
      state = (state as MoodLoaded).copyWith(selectedMood: mood, saved: false);
    }
  }

  void updateNote(String note) {
    if (state is MoodLoaded) {
      state = (state as MoodLoaded).copyWith(note: note);
    }
  }

  Future<void> saveToday() async {
    if (state is! MoodLoaded) return;
    final current = state as MoodLoaded;
    if (current.selectedMood == null) return;

    final result = await _logMood(
      LogMoodParams(
        userId: _userId,
        mood: current.selectedMood!,
        note: current.note.isEmpty ? null : current.note,
      ),
    );

    result.fold(
      (failure) => state = MoodError(failure.message),
      (_) {
        state = current.copyWith(saved: true);
        load(); // recarga para actualizar el historial
      },
    );
  }
}