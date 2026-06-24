import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../hydration/domain/entities/hydration_entity.dart';
import '../../../meal_plan/domain/entities/meal_plan_entities.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../../mood/domain/entities/mood_entity.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/dashboard_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: NutriColors.background,
      appBar: AppBar(
        backgroundColor: NutriColors.primaryDark,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/nutrisync_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.eco, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('NutriSync',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: switch (state) {
        DashboardLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        DashboardError(:final message) => Center(child: Text(message)),
        DashboardLoaded() => _DashboardContent(state: state),
        _ => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
      },
    );
  }
}

// ── Contenido principal ───────────────────────────────────────────────────────

class _DashboardContent extends ConsumerWidget {
  final DashboardLoaded state;
  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: NutriColors.primary,
      onRefresh: () =>
          ref.read(dashboardControllerProvider.notifier).load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fecha y título ──────────────────────────────────────
            Text(
              'Hoy, ${DateFormat('d MMM', 'es').format(state.date)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NutriColors.textSecondary,
                  ),
            ),
            Text(
              'Mi Dieta',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // ── Card Hidratación ────────────────────────────────────
            _HydrationCard(
              hydration: state.hydration,
              onAddTap: () => context.push('/hydration'),
            ),
            const SizedBox(height: 20),

            // ── Sección Comidas ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comidas',
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => context.push('/meal-plan'),
                  icon: const Text('Ver plan completo'),
                  label: const Icon(Icons.arrow_forward, size: 14),
                  style: TextButton.styleFrom(
                    foregroundColor: NutriColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Selector días compacto
            _DaySelector(selectedDay: state.date.weekday),
            const SizedBox(height: 12),

            // Cards de comidas
            if (state.todayMeals.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NutriColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: NutriColors.border),
                ),
                child: Center(
                  child: Text(
                    'Sin comidas asignadas para hoy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NutriColors.textSecondary,
                        ),
                  ),
                ),
              )
            else
              ...state.todayMeals.map(
                (meal) => _DashboardMealCard(
                  meal: meal,
                  onToggleConsumed: () => ref
                      .read(dashboardControllerProvider.notifier)
                      .toggleMealConsumed(meal),
                ),
              ),
            const SizedBox(height: 20),

            // ── Sección Medicación ──────────────────────────────────
            Text('Medicación',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _MedicationSection(
              medications: state.medications,
              takenMedicationIds: state.takenMedicationIds,
              onAddTap: () => context.push('/medication'),
              onToggleTaken: (medicationId) => ref
                  .read(dashboardControllerProvider.notifier)
                  .toggleMedicationTaken(medicationId),
            ),
            const SizedBox(height: 20),

            // ── Sección Mood ────────────────────────────────────────
            _MoodSection(
              currentMood: state.todayMood?.mood,
              onSave: (mood) => ref
                  .read(dashboardControllerProvider.notifier)
                  .saveMood(mood),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Card Hidratación ──────────────────────────────────────────────────────────

class _HydrationCard extends StatelessWidget {
  final HydrationSummary hydration;
  final VoidCallback? onAddTap;
  const _HydrationCard({required this.hydration, this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NutriColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop,
                      color: NutriColors.hydration, size: 18),
                  const SizedBox(width: 6),
                  Text('Hidratación',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              TextButton(
                onPressed: onAddTap,
                style: TextButton.styleFrom(
                    foregroundColor: NutriColors.primary,
                    padding: EdgeInsets.zero),
                child: const Text('+ Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${hydration.totalGlasses}/${hydration.goalGlasses} Vasos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: NutriColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hydration.progressPercent,
              backgroundColor: NutriColors.border,
              color: NutriColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          // Iconos de vasos
          Row(
            children: List.generate(hydration.goalGlasses, (i) {
              final filled = i < hydration.totalGlasses;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.local_drink,
                  size: 20,
                  color: filled
                      ? NutriColors.primary
                      : NutriColors.border,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Faltan ${hydration.goalGlasses - hydration.totalGlasses} Vasos para tu meta de ${hydration.goalMl ~/ 1000}L.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: NutriColors.textSecondary,
                ),
          ),
          if (hydration.streakDays > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  'Racha ${hydration.streakDays} días seguidos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NutriColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Selector de días compacto ─────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  final int selectedDay;
  const _DaySelector({required this.selectedDay});

  static const _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final date = monday.add(Duration(days: i));
        final isSelected = selectedDay == i + 1;

        return Column(
          children: [
            Text(
              _days[i],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? NutriColors.primary
                        : NutriColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? NutriColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : NutriColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Card de comida en dashboard ───────────────────────────────────────────────

class _DashboardMealCard extends StatefulWidget {
  final MealEntity meal;
  final VoidCallback onToggleConsumed;

  const _DashboardMealCard({
    required this.meal,
    required this.onToggleConsumed,
  });

  @override
  State<_DashboardMealCard> createState() => _DashboardMealCardState();
}

class _DashboardMealCardState extends State<_DashboardMealCard> {
  bool _showNote = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 150,
              width: double.infinity,
              color: NutriColors.inputFill,
              child: const Icon(Icons.restaurant,
                  color: NutriColors.textSecondary, size: 40),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(meal.name,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: NutriColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 8),

                // Macros
                Row(
                  children: [
                    _Macro(label: 'CAL', value: '${meal.calories ?? 0}'),
                    const SizedBox(width: 12),
                    _Macro(
                        label: 'PROT',
                        value: '${meal.proteinG?.toInt() ?? 0}g'),
                    const SizedBox(width: 12),
                    _Macro(
                        label: 'CARB',
                        value: '${meal.carbsG?.toInt() ?? 0}g'),
                    const SizedBox(width: 12),
                    _Macro(
                        label: 'GRAS',
                        value: '${meal.fatG?.toInt() ?? 0}g'),
                  ],
                ),
                const SizedBox(height: 10),

                // Botón consumido
                ElevatedButton.icon(
                  onPressed: widget.onToggleConsumed,
                  icon: Icon(
                    meal.isConsumed
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 16,
                  ),
                  label: Text(
                      meal.isConsumed ? 'Consumido' : 'Registrar como comido'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: meal.isConsumed
                        ? NutriColors.primary
                        : NutriColors.border,
                    foregroundColor:
                        meal.isConsumed ? Colors.white : NutriColors.textPrimary,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                ),
                const SizedBox(height: 8),

                // No lo voy a comer
                GestureDetector(
                  onTap: () => setState(() => _showNote = !_showNote),
                  child: Text(
                    'No lo voy a comer, ¿Qué comiste?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NutriColors.textSecondary,
                        ),
                  ),
                ),

                if (_showNote) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: He cambiado el salmón por atún...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text('Confirmar Comida'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                      foregroundColor: NutriColors.textSecondary,
                      side: const BorderSide(color: NutriColors.border),
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

class _Macro extends StatelessWidget {
  final String label;
  final String value;
  const _Macro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: NutriColors.textSecondary,
                )),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
      ],
    );
  }
}

// ── Sección Medicación ────────────────────────────────────────────────────────

class _MedicationSection extends StatelessWidget {
  final List<MedicationEntity> medications;
  final Set<int> takenMedicationIds;
  final VoidCallback? onAddTap;
  final void Function(int medicationId)? onToggleTaken;

  const _MedicationSection({
    required this.medications,
    this.takenMedicationIds = const {},
    this.onAddTap,
    this.onToggleTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NutriColors.border),
      ),
      child: Column(
        children: [
          if (medications.isEmpty)
            Text(
              'Sin medicamentos configurados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NutriColors.textSecondary,
                  ),
            )
          else
            ...medications.map(
              (med) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: takenMedicationIds.contains(med.id),
                      onChanged: (_) => onToggleTaken?.call(med.id),
                      activeColor: NutriColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(med.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(med.dosage,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (med.times.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: NutriColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_outlined,
                                size: 12, color: NutriColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(med.times.first,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Añadir Medicación'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              foregroundColor: NutriColors.primary,
              side: const BorderSide(color: NutriColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección Mood ──────────────────────────────────────────────────────────────

class _MoodSection extends StatefulWidget {
  final MoodValue? currentMood;
  final void Function(MoodValue) onSave;

  const _MoodSection({this.currentMood, required this.onSave});

  @override
  State<_MoodSection> createState() => _MoodSectionState();
}

class _MoodSectionState extends State<_MoodSection> {
  MoodValue? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentMood;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NutriColors.border),
      ),
      child: Column(
        children: [
          Text(
            '¿Cómo te sientes hoy?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodValue.values.map((mood) {
              final isSelected = _selected == mood;
              return GestureDetector(
                onTap: () => setState(() => _selected = mood),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: NutriColors.primary, width: 2)
                            : null,
                        color: isSelected
                            ? NutriColors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(mood.emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? NutriColors.primary
                                : NutriColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                _selected != null ? () => widget.onSave(_selected!) : null,
            child: const Text('Guardar registro de hoy'),
          ),
        ],
      ),
    );
  }
}