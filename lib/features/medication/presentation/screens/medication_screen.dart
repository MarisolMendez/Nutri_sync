import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicamento guardado'),
        backgroundColor: NutriColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(medicationFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ícono y descripción ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: NutriColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      color: NutriColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Configura tu suplemento o medicamento\npara recibir recordatorios precisos.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NutriColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Nombre ───────────────────────────────────────────────
            Text('Nombre de la medicación',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
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
              controller: _dosageController,
              onChanged: (v) =>
                  ref.read(medicationFormProvider.notifier).updateDosage(v),
              decoration: const InputDecoration(
                hintText: 'Ej: 1 Cápsula',
              ),
            ),
            const SizedBox(height: 20),

            // ── Card recordatorios ───────────────────────────────────
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
                  // Toggle recordatorios
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: NutriColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Recordatorios',
                        style:
                            Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Switch(
                        value: form.reminderEnabled,
                        onChanged: (v) => ref
                            .read(medicationFormProvider.notifier)
                            .toggleReminder(v),
                      ),
                    ],
                  ),

                  if (form.reminderEnabled) ...[
                    const SizedBox(height: 16),

                    // Horas
                    Text('Horas',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showTimePicker(context),
                      child: Row(
                        children: [
                          const Icon(Icons.add,
                              size: 18, color: NutriColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Añadir hora',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: NutriColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Intervalo
                    Row(
                      children: [
                        Text('Cada:',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: NutriColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: NutriColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: form.intervalHours,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: [4, 6, 8, 12, 24]
                                    .map((h) => DropdownMenuItem(
                                          value: h,
                                          child: Text('$h horas'),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    ref
                                        .read(medicationFormProvider
                                            .notifier)
                                        .updateIntervalHours(v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Días de la semana
                    Text('Días:',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10),
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
            const SizedBox(height: 24),

            // ── Botón guardar ────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Guardar Medicación'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
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
}

// ── Widget chip de hora ───────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final String time;
  final VoidCallback onRemove;

  const _TimeChip({required this.time, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NutriColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NutriColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_outlined,
              size: 14, color: NutriColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 14, color: NutriColors.textSecondary),
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
            color:
                isSelected ? NutriColors.primary : NutriColors.border,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : NutriColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}