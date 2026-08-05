import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medication_entity.dart';
import '../controllers/medication_controller.dart';
import '../controllers/medication_state.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(medicationControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
    if (!_showForm) {
      ref.read(medicationFormProvider.notifier).reset();
      _nameController.clear();
      _dosageController.clear();
    }
  }

  void _onSave() {
    final form = ref.read(medicationFormProvider);
    if (form.name.isEmpty || form.dosage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el nombre y la dosis'),
          backgroundColor: NutriColors.error,
        ),
      );
      return;
    }
    ref.read(medicationControllerProvider.notifier).saveMedication(form);
    ref.read(medicationFormProvider.notifier).reset();
    _nameController.clear();
    _dosageController.clear();
    _toggleForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicamento guardado'),
        backgroundColor: NutriColors.primary,
      ),
    );
  }

  void _onDelete(MedicationEntity med) async {
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
      ref.read(medicationControllerProvider.notifier).deleteMedicationItem(
            med.id,
            med.remoteId,
            med.name,
            med.times,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: _toggleForm,
            tooltip: _showForm ? 'Cancelar' : 'Añadir medicación',
          ),
        ],
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        MedicationLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        MedicationError(:final message) => Center(child: Text(message)),
        MedicationLoaded(:final medications) => _MedicationBody(
            medications: medications,
            showForm: _showForm,
            nameController: _nameController,
            dosageController: _dosageController,
            onSave: _onSave,
            onDelete: _onDelete,
          ),
        _ => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
      },
    );
  }
}

class _MedicationBody extends ConsumerWidget {
  final List<MedicationEntity> medications;
  final bool showForm;
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final VoidCallback onSave;
  final void Function(MedicationEntity med) onDelete;

  const _MedicationBody({
    required this.medications,
    required this.showForm,
    required this.nameController,
    required this.dosageController,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(medicationFormProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Formulario ────────────────────────────────────────────
          if (showForm) ...[
            _FormSection(
              nameController: nameController,
              dosageController: dosageController,
              form: form,
              onSave: onSave,
            ),
            const SizedBox(height: 24),
          ],

          // ── Lista de medicamentos ─────────────────────────────────
          if (medications.isEmpty && !showForm)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: NutriColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      color: NutriColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin medicamentos configurados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: NutriColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca + para añadir tu primer medicamento',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NutriColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

          if (medications.isNotEmpty)
            Text(
              'Tus medicamentos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const SizedBox(height: 12),

          ...medications.map(
            (med) => _MedicationCard(
              medication: med,
              onDelete: () => onDelete(med),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FormSection extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final MedicationFormState form;
  final VoidCallback onSave;

  const _FormSection({
    required this.nameController,
    required this.dosageController,
    required this.form,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NutriColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NutriColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: NutriColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nueva medicación',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Nombre ───────────────────────────────────────────────
          Text('Nombre de la medicación',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            onChanged: (v) =>
                ref.read(medicationFormProvider.notifier).updateName(v),
            decoration: const InputDecoration(
              hintText: 'Ej: Paracetamol 500 mg',
            ),
          ),
          const SizedBox(height: 16),

          // ── Dosis ────────────────────────────────────────────────
          Text('Dosis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
          const SizedBox(height: 8),
          TextFormField(
            controller: dosageController,
            onChanged: (v) =>
                ref.read(medicationFormProvider.notifier).updateDosage(v),
            decoration: const InputDecoration(
              hintText: 'Ej: 1 Cápsula',
            ),
          ),
          const SizedBox(height: 20),

          // ── Card recordatorios ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NutriColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle recordatorios
                Row(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: NutriColors.textPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Recordatorios',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 32,
                      child: Switch(
                        value: form.reminderEnabled,
                        onChanged: (v) => ref
                            .read(medicationFormProvider.notifier)
                            .toggleReminder(v),
                      ),
                    ),
                  ],
                ),

                if (form.reminderEnabled) ...[
                  const SizedBox(height: 14),

                  // Horas
                  Text('Horas',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...form.times.map(
                        (time) => _TimeChip(
                          time: time,
                          onRemove: () => ref
                              .read(medicationFormProvider.notifier)
                              .removeTime(time),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showTimePicker(context, ref),
                    child: Row(
                      children: [
                        const Icon(Icons.add,
                            size: 16, color: NutriColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Añadir hora',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: NutriColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Intervalo
                  Row(
                    children: [
                      Text('Cada:',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: NutriColors.inputFill,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: NutriColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: form.intervalHours,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 18),
                              style: Theme.of(context).textTheme.bodySmall,
                              items: [4, 6, 8, 12, 24]
                                  .map((h) => DropdownMenuItem(
                                        value: h,
                                        child: Text('$h horas'),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  ref
                                      .read(medicationFormProvider.notifier)
                                      .updateIntervalHours(v);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Días de la semana
                  Text('Días:',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                        .map(
                          (day) => _DayChip(
                            day: day,
                            isSelected: form.days.contains(day),
                            onTap: () => ref
                                .read(medicationFormProvider.notifier)
                                .toggleDay(day),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Botón guardar ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Guardar Medicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NutriColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final MedicationEntity medication;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NutriColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: NutriColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.medication,
            color: NutriColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          medication.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              medication.dosage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: NutriColors.textSecondary,
                  ),
            ),
            if (medication.times.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: medication.times
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NutriColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 10,
                              color: NutriColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline,
              color: NutriColors.error, size: 22),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Widget chip de hora ───────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final String time;
  final VoidCallback onRemove;

  const _TimeChip({required this.time, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: NutriColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NutriColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_outlined,
              size: 12, color: NutriColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 12, color: NutriColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Widget chip de día ────────────────────────────────────────────────────────

class _DayChip extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? NutriColors.primary : NutriColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? NutriColors.primary : NutriColors.border,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : NutriColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showTimePicker(BuildContext context, WidgetRef ref) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: NutriColors.primary,
          ),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = picked.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';
    ref.read(medicationFormProvider.notifier).addTime(timeStr);
  }
}