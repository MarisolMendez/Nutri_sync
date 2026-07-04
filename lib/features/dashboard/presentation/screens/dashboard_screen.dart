import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../hydration/domain/entities/hydration_entity.dart';
import '../../../meal_plan/domain/entities/meal_plan_entities.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../../mood/domain/entities/mood_entity.dart';
import '../../../meal_plan/presentation/screens/weekly_meal_plan_screen.dart';
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
              MealCard(
                meal: MealEntity(
                  id: 0,
                  weeklyPlanId: 1,
                  dayOfWeek: DateTime.now().weekday,
                  mealType: 'lunch',
                  name: 'Ensalada de Pollo',
                  calories: 450,
                  proteinG: 35,
                  carbsG: 25,
                  fatG: 18,
                  isConsumed: false,
                ),
                showDetailsButton: false,
              )
            else
              ...state.todayMeals.map(
                (meal) => MealCard(
                  meal: meal,
                  showDetailsButton: false,
                  onToggleConsumed: (m) => ref
                      .read(dashboardControllerProvider.notifier)
                      .toggleMealConsumed(m),
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
              onToggleTaken: (medicationId) => ref
                  .read(dashboardControllerProvider.notifier)
                  .toggleMedicationTaken(medicationId),
              onAddTap: () => context.push('/medication'),
              onDeleteMedication: (medicationId) => ref
                  .read(dashboardControllerProvider.notifier)
                  .deleteMedication(medicationId),
            ),
            const SizedBox(height: 20),

            // ── Sección Mood ────────────────────────────────────────
            _MoodSection(
              currentMood: state.todayMood?.mood,
              isSaved: state.todayMood != null,
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


// ── Sección Medicación ────────────────────────────────────────────────────────

class _MedicationSection extends StatelessWidget {
  final List<MedicationEntity> medications;
  final Set<int> takenMedicationIds;
  final VoidCallback? onAddTap;
  final void Function(int medicationId)? onToggleTaken;
  final void Function(int medicationId)? onDeleteMedication;

  const _MedicationSection({
    required this.medications,
    this.takenMedicationIds = const {},
    this.onAddTap,
    this.onToggleTaken,
    this.onDeleteMedication,
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
              (med) => Dismissible(
                key: ValueKey(med.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar medicación'),
                      content: Text('¿Seguro que quieres eliminar "${med.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Eliminar',
                              style: TextStyle(color: NutriColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    onDeleteMedication?.call(med.id);
                  }
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: NutriColors.error,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 28),
                ),
                child: Padding(
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
  final bool isSaved;
  final void Function(MoodValue) onSave;

  const _MoodSection({
    this.currentMood,
    this.isSaved = false,
    required this.onSave,
  });

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
  void didUpdateWidget(_MoodSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMood != oldWidget.currentMood) {
      _selected = widget.currentMood;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alreadySaved = widget.isSaved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alreadySaved ? NutriColors.primary : NutriColors.border,
          width: alreadySaved ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (alreadySaved)
                const Icon(Icons.check_circle,
                    color: NutriColors.primary, size: 20),
              if (alreadySaved) const SizedBox(width: 8),
              Text(
                alreadySaved
                    ? '¡Estado de ánimo registrado!'
                    : '¿Cómo te sientes hoy?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: alreadySaved
                          ? NutriColors.primary
                          : NutriColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodValue.values.map((mood) {
              final isSelected = _selected == mood;
              return GestureDetector(
                onTap: alreadySaved
                    ? null
                    : () => setState(() => _selected = mood),
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
          ElevatedButton.icon(
            onPressed: alreadySaved
                ? () {}
                : (_selected != null ? () => widget.onSave(_selected!) : null),
            icon: Icon(
              alreadySaved ? Icons.check_circle : Icons.save_outlined,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              alreadySaved ? 'Hoy ya registrado' : 'Guardar registro de hoy',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: NutriColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 42),
            ),
          ),
        ],
      ),
    );
  }
}