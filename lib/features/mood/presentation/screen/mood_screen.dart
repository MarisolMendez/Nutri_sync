import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/mood_entity.dart';
import '../controllers/mood_controller.dart';
import '../controllers/mood_state.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(moodControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodControllerProvider);

    // Muestra snackbar cuando se guarda
    ref.listen<MoodState>(moodControllerProvider, (_, next) {
      if (next is MoodLoaded && next.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro guardado!'),
            backgroundColor: NutriColors.primary,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienestar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        MoodLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        MoodError(:final message) => Center(child: Text(message)),
        MoodLoaded() => _MoodContent(
            state: state,
            noteController: _noteController,
            onMoodSelected: (mood) =>
                ref.read(moodControllerProvider.notifier).selectMood(mood),
            onNoteChanged: (note) =>
                ref.read(moodControllerProvider.notifier).updateNote(note),
            onSave: () =>
                ref.read(moodControllerProvider.notifier).saveToday(),
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _MoodContent extends StatelessWidget {
  final MoodLoaded state;
  final TextEditingController noteController;
  final void Function(MoodValue) onMoodSelected;
  final void Function(String) onNoteChanged;
  final VoidCallback onSave;

  const _MoodContent({
    required this.state,
    required this.noteController,
    required this.onMoodSelected,
    required this.onNoteChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NutriColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado emocional',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu bienestar también importa 💚',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: NutriColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Selector de mood ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NutriColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿CÓMO TE SIENTES EN ESTE MOMENTO?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: NutriColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),

                // Emojis de estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: MoodValue.values.map((mood) {
                    final isSelected = state.selectedMood == mood;
                    return _MoodOption(
                      mood: mood,
                      isSelected: isSelected,
                      isDisabled: state.todayMood != null,
                      onTap: () => onMoodSelected(mood),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Mensaje cuando ya registró hoy
                if (state.todayMood != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 18, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ya has registrado tu estado de ánimo hoy',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Campo de nota y botón guardar (solo si no ha registrado)
                if (state.todayMood == null) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    onChanged: onNoteChanged,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: '¿Algo que quieras compartir?',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: NutriColors.textSecondary,
                          ),
                      filled: true,
                      fillColor: const Color(0xFFEDF7F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: NutriColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: NutriColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: NutriColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón guardar
                  ElevatedButton.icon(
                    onPressed: state.selectedMood != null ? onSave : null,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Guardar'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Historial semanal ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NutriColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta semana',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _WeekMoodRow(summary: state.weekSummary),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Widget opción de mood ─────────────────────────────────────────────────────

class _MoodOption extends StatelessWidget {
  final MoodValue mood;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _MoodOption({
    required this.mood,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: NutriColors.primary, width: 2)
                  : Border.all(color: Colors.transparent),
              color: isSelected
                  ? NutriColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            child: Center(
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mood.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? NutriColors.primary
                      : NutriColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Widget historial semanal ──────────────────────────────────────────────────

class _WeekMoodRow extends StatelessWidget {
  final dynamic summary;

  const _WeekMoodRow({required this.summary});

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Hoy', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0=Lun, 6=Dom

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final moodEntity = summary.days[i];
        final isToday = i == today;
        final isFuture = i > today;

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(color: NutriColors.primary, width: 1.5)
                    : null,
                color: isToday
                    ? NutriColors.primary.withValues(alpha: 0.05)
                    : Colors.transparent,
              ),
              child: Center(
                child: isFuture
                    ? Text(
                        '—',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: NutriColors.border,
                            ),
                      )
                    : moodEntity != null
                        ? Text(
                            moodEntity.mood.emoji,
                            style: const TextStyle(fontSize: 22),
                          )
                        : Text(
                            '—',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: NutriColors.border),
                          ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dayLabels[i],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? NutriColors.primary
                        : NutriColors.textSecondary,
                    fontWeight:
                        isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        );
      }),
    );
  }
}