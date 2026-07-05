import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../controllers/meal_plan_controller.dart';
import '../controllers/meal_plan_state.dart';
import '../widgets/voice_note_recorder.dart';
import 'recipe_detail_screen.dart';

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        MealPlanLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary)),
        MealPlanEmpty() => _EmptyPlan(),
        MealPlanError(:final message) => Center(child: Text(message)),
        MealPlanLoaded() => _MealPlanContent(state: state),
        _ => const SizedBox(),
      },
    );
  }
}

class _MealPlanContent extends ConsumerWidget {
  final MealPlanLoaded state;
  const _MealPlanContent({required this.state});

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recetario Semanal',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Tu plan de alimentación personalizado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: NutriColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        // Selector de días
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(7, (i) {
              final dayNum = i + 1;
              final date = monday.add(Duration(days: i));
              final isSelected = state.selectedDay == dayNum;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(mealPlanControllerProvider.notifier)
                        .selectDay(dayNum),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NutriColors.primary
                            : NutriColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? null
                            : Border.all(color: NutriColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(_dayLabels[i],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : NutriColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('${date.day}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : NutriColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Lista de comidas
        Expanded(
          child: state.mealsForSelectedDay.isEmpty
              ? const Center(child: Text('Sin comidas para este día'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: state.mealsForSelectedDay.length,
                  itemBuilder: (context, i) => MealCard(
                    meal: state.mealsForSelectedDay[i],
                    showDetailsButton: true,
                  ),
                ),
        ),
      ],
    );
  }
}

class MealCard extends ConsumerStatefulWidget {
  final MealEntity meal;
  final bool showDetailsButton;
  final VoidCallback? onToggleConsumed;

  const MealCard({
    super.key,
    required this.meal,
    this.showDetailsButton = false,
    this.onToggleConsumed,
  });

  @override
  ConsumerState<MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<MealCard> {
  bool _macrosExpanded = false;
  bool _showNote = false;
  final _noteController = TextEditingController();
  String? _voiceNotePath;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _mealTypeLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return 'Desayuno';
      case 'lunch':     return 'Comida';
      case 'snack':     return 'Colación';
      case 'dinner':    return 'Cena';
      default:          return mealType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(8),
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
          // Imagen con chip de tipo
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  meal.imageUrl != null
                      ? Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallback(),
                        )
                      : _fallback(),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _mealTypeLabel(meal.mealType),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NutriColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + flecha macros
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(meal.name,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    GestureDetector(
                      onTap: () => setState(
                          () => _macrosExpanded = !_macrosExpanded),
                      child: Icon(
                        _macrosExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: NutriColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Macros expandibles
                if (_macrosExpanded) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MacroChip(label: 'CAL',
                          value: '${meal.calories ?? 0}'),
                      const SizedBox(width: 8),
                      _MacroChip(label: 'PROT',
                          value: '${meal.proteinG?.toInt() ?? 0}g'),
                      const SizedBox(width: 8),
                      _MacroChip(label: 'CARB',
                          value: '${meal.carbsG?.toInt() ?? 0}g'),
                      const SizedBox(width: 8),
                      _MacroChip(label: 'GRAS',
                          value: '${meal.fatG?.toInt() ?? 0}g'),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Botón consumido — con lógica que persiste igual que mood
                ElevatedButton.icon(
                  onPressed: widget.onToggleConsumed ??
                      () => ref
                          .read(mealPlanControllerProvider.notifier)
                          .toggleMealConsumed(meal),
                  icon: Icon(
                    meal.isConsumed
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                      meal.isConsumed ? 'Consumido' : 'Registrar como comido'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: meal.isConsumed
                        ? NutriColors.primary
                        : NutriColors.border,
                    foregroundColor: meal.isConsumed
                        ? Colors.white
                        : NutriColors.textPrimary,
                    minimumSize: const Size(double.infinity, 52),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                // Botón detalles — SOLO en Mi Dieta
                if (widget.showDetailsButton) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                  onPressed: meal.recipe != null
                        ? () => Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 260),
                                reverseTransitionDuration: const Duration(milliseconds: 200),
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    RecipeDetailScreen(meal: meal),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.04, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: FadeTransition(
                                      opacity: CurveTween(curve: Curves.easeIn).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: const Text('Ver detalles'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: NutriColors.primary,
                      side: const BorderSide(color: NutriColors.primary),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // No lo voy a comer
                GestureDetector(
                  onTap: () =>
                      setState(() => _showNote = !_showNote),
                  child: Center(
                    child: Text(
                      'No lo voy a comer, ¿Qué comiste?',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            color: NutriColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),

                if (_showNote) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: He cambiado el salmón por atún...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  VoiceNoteRecorder(
                    onRecorded: (path) => _voiceNotePath = path,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(mealPlanControllerProvider.notifier)
                          .saveSubstituteNote(
                            mealId: meal.id,
                            note: _noteController.text.isEmpty
                                ? null
                                : _noteController.text,
                            voiceNotePath: _voiceNotePath,
                          );
                      setState(() => _showNote = false);
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text('Confirmar Comida'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      foregroundColor: NutriColors.textSecondary,
                      side: const BorderSide(color: NutriColors.border),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        height: 140,
        color: NutriColors.inputFill,
        child: const Icon(Icons.restaurant,
            color: NutriColors.textSecondary, size: 36),
      );
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDE8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: NutriColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
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
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: NutriColors.textSecondary),
          ),
        ],
      ),
    );
  }
}