import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../controllers/meal_plan_controller.dart';
import '../controllers/meal_plan_state.dart';
import 'recipe_detail_screen.dart';
import '../widgets/voice_note_recorder.dart';

class WeeklyMealPlanScreen extends ConsumerStatefulWidget {
  const WeeklyMealPlanScreen({super.key});

  @override
  ConsumerState<WeeklyMealPlanScreen> createState() =>
      _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends ConsumerState<WeeklyMealPlanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(mealPlanControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Dieta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        MealPlanLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        MealPlanEmpty() => _EmptyPlan(),
        MealPlanError(:final message) => Center(child: Text(message)),
        MealPlanLoaded() => _MealPlanContent(state: state),
        _ => const SizedBox(),
      },
    );
  }
}

// ── Contenido principal ───────────────────────────────────────────────────────

class _MealPlanContent extends ConsumerWidget {
  final MealPlanLoaded state;
  const _MealPlanContent({required this.state});

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Column(
      children: [
        // ── Selector de días ───────────────────────────────────────
        Container(
          color: NutriColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(6, (i) {
              final dayNum = i + 1; // 1=Lun ... 6=Sáb
              final date = monday.add(Duration(days: i));
              final isSelected = state.selectedDay == dayNum;

              return GestureDetector(
                onTap: () => ref
                    .read(mealPlanControllerProvider.notifier)
                    .selectDay(dayNum),
                child: Column(
                  children: [
                    Text(
                      _dayLabels[i],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? NutriColors.primary
                                : NutriColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NutriColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : NutriColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // ── Lista de comidas del día ───────────────────────────────
        Expanded(
          child: state.mealsForSelectedDay.isEmpty
              ? const Center(
                  child: Text('Sin comidas para este día'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.mealsForSelectedDay.length,
                  itemBuilder: (context, i) {
                    final meal = state.mealsForSelectedDay[i];
                    return _MealCard(meal: meal);
                  },
                ),
        ),
      ],
    );
  }
}

// ── Card de comida ────────────────────────────────────────────────────────────

class _MealCard extends ConsumerStatefulWidget {
  final MealEntity meal;
  const _MealCard({required this.meal});

  @override
  ConsumerState<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<_MealCard> {
  bool _expanded = false;
  final _noteController = TextEditingController();
  String? _voiceNotePath;

  static const _colorGray = Color(0xFF747571);
  static const _colorTextGreenDark = Color(0xFF052016);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: meal.isConsumed ? NutriColors.primary : NutriColors.border,
          width: meal.isConsumed ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          if (meal.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: meal.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: NutriColors.inputFill,
                  child: const Icon(Icons.restaurant,
                      color: NutriColors.textSecondary, size: 40),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Macros
                Row(
                  children: [
                    _MacroChip(label: 'CAL', value: '${meal.calories ?? 0}'),
                    const SizedBox(width: 8),
                    _MacroChip(
                        label: 'PROT',
                        value: '${meal.proteinG?.toInt() ?? 0}g'),
                    const SizedBox(width: 8),
                    _MacroChip(
                        label: 'CARB',
                        value: '${meal.carbsG?.toInt() ?? 0}g'),
                    const SizedBox(width: 8),
                    _MacroChip(
                        label: 'GRAS',
                        value: '${meal.fatG?.toInt() ?? 0}g'),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón Registar / Consumido
                if (meal.isConsumed)
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(mealPlanControllerProvider.notifier)
                        .toggleMealConsumed(meal),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Consumido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NutriColors.success,
                      foregroundColor: NutriColors.textOnPrimary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(mealPlanControllerProvider.notifier)
                        .toggleMealConsumed(meal),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Registrar como comido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorGray.withValues(alpha: 0.66),
                      foregroundColor: NutriColors.textOnPrimary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                // Botón Detalles — siempre verde, nunca cambia
                if (meal.recipe != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(meal: meal),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restaurant_menu, size: 16),
                    label: const Text('Detalles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NutriColors.success,
                      foregroundColor: NutriColors.textOnPrimary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],

                // No lo voy a comer
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    'No lo voy a comer, ¿Qué comiste?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _colorTextGreenDark,
                        ),
                  ),
                ),

                if (_expanded) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: He cambiado el salmón por atún...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  VoiceNoteRecorder(
                    onRecorded: (path) {
                      _voiceNotePath = path;
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Confirmar Comida'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorGray.withValues(alpha: 0.66),
                      foregroundColor: NutriColors.textOnPrimary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;

  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: NutriColors.textSecondary, fontSize: 10)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EmptyPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu_outlined,
              size: 64, color: NutriColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Tu nutrióloga aún no ha\nasignado un plan esta semana',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: NutriColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}