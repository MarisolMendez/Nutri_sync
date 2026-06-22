import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/progress_entity.dart';
import '../controllers/progress_controller.dart';
import '../controllers/progress_state.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(progressControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        ProgressLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        ProgressError(:final message) => Center(child: Text(message)),
        ProgressLoaded(:final progress) => _ProgressContent(progress: progress),
        _ => const SizedBox(),
      },
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final WeeklyProgressEntity progress;
  const _ProgressContent({required this.progress});

  static const _dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM', 'es');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semana del ${dateFormat.format(progress.weekStart)} al ${dateFormat.format(progress.weekEnd)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: NutriColors.textSecondary,
                ),
          ),
          Text(
            'Resumen semanal',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // ── Stats cards ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Adherencia al plan',
                  value: '${(progress.adherencePercent * 100).round()}%',
                  subtitle:
                      '${progress.mealsConsumed} de ${progress.mealsTotal} comidas',
                  color: NutriColors.primary,
                  bgColor: const Color(0xFFE1F5EE),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Hidratación',
                  value:
                      '${(progress.avgHydrationPercent * 100).round()}%',
                  subtitle: 'Meta diaria de 2L',
                  color: NutriColors.hydration,
                  bgColor: const Color(0xFFE6F1FB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Gráfica de comidas por día ──────────────────────────
          Text('Comidas registradas por día',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NutriColors.border),
            ),
            child: SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final consumed = progress.mealsConsumedByDay[i];
                  final total = progress.mealsTotalByDay[i];
                  final ratio = total == 0 ? 0.0 : consumed / total;
                  final heightPx = total == 0 ? 4.0 : 14.0 + (ratio * 50);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: heightPx,
                            decoration: BoxDecoration(
                              color: total == 0
                                  ? NutriColors.border
                                  : ratio >= 1
                                      ? NutriColors.primary
                                      : NutriColors.primary
                                          .withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _dayLabels[i],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: NutriColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Estado de ánimo semanal ──────────────────────────────
          Text('Estado de ánimo de la semana',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NutriColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final mood = progress.moodByDay[i];
                return Column(
                  children: [
                    Text(
                      mood == null ? '—' : _emojiFor(mood),
                      style: TextStyle(
                        fontSize: mood == null ? 16 : 22,
                        color: mood == null
                            ? NutriColors.border
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dayLabels[i],
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: NutriColors.textSecondary),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // ── Medicación ───────────────────────────────────────────
          if (progress.mainMedicationName != null) ...[
            Text('Medicación de la semana',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: NutriColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NutriColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progress.mainMedicationName!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${progress.medicationDaysTaken}/${progress.medicationDaysScheduled} días',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: NutriColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Mensaje motivacional ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NutriColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.trending_up,
                    color: NutriColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.adherencePercent >= 0.8
                            ? 'Vas muy bien esta semana'
                            : 'Sigue así, puedes mejorar',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        progress.adherenceChangePercent != null
                            ? 'Tu adherencia cambió ${progress.adherenceChangePercent!.round()}% vs la semana pasada'
                            : 'Sigue registrando tus comidas para ver tu evolución',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: NutriColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _emojiFor(String mood) {
    switch (mood) {
      case 'excellent':
        return '😊';
      case 'good':
        return '😊';
      case 'neutral':
        return '🙂';
      case 'bad':
        return '😟';
      default:
        return '—';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                  )),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}