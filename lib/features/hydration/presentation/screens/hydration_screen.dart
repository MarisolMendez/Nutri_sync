import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/hydration_controller.dart';
import '../controllers/hydration_state.dart';

class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hydrationControllerProvider.notifier).loadToday(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hydrationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidratación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        HydrationLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        HydrationError(:final message) => Center(child: Text(message)),
        HydrationLoaded(:final summary, :final customAmountMl) =>
          _HydrationContent(
            summary: summary,
            customAmountMl: customAmountMl,
            onQuickAdd: (ml) =>
                ref.read(hydrationControllerProvider.notifier).addWater(ml),
            onCustomAmountChanged: (ml) => ref
                .read(hydrationControllerProvider.notifier)
                .updateCustomAmount(ml),
            onRegister: () => ref
                .read(hydrationControllerProvider.notifier)
                .addWater(customAmountMl),
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _HydrationContent extends StatelessWidget {
  final dynamic summary;
  final int customAmountMl;
  final void Function(int) onQuickAdd;
  final void Function(int) onCustomAmountChanged;
  final VoidCallback onRegister;

  const _HydrationContent({
    required this.summary,
    required this.customAmountMl,
    required this.onQuickAdd,
    required this.onCustomAmountChanged,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Racha ──────────────────────────────────────────────────
          if (summary.streakDays > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: NutriColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NutriColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Racha de ${summary.streakDays} días!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Mantén el ritmo, estás hidratado.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // ── Círculo de progreso ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NutriColors.border),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo de progreso
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: _CircleProgressPainter(
                          progress: summary.progressPercent,
                        ),
                      ),
                      // Contenido central
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_drink_outlined,
                            color: NutriColors.hydration,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${summary.totalMl}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: NutriColors.textPrimary,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' ml',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: NutriColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Meta: ${summary.goalMl}ml',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: NutriColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Vasos completados
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: NutriColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary.totalGlasses} de ${summary.goalGlasses} vasos completados',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Añadir rápido ──────────────────────────────────────────
          Text(
            'Añadir rápido',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAddButton(
                icon: Icons.local_drink_outlined,
                amount: '+250',
                label: 'VASO',
                isSelected: customAmountMl == 250,
                onTap: () => onQuickAdd(250),
              ),
              const SizedBox(width: 10),
              _QuickAddButton(
                icon: Icons.water_drop_outlined,
                amount: '+500',
                label: 'BOTELLA P',
                isSelected: customAmountMl == 500,
                onTap: () => onQuickAdd(500),
              ),
              const SizedBox(width: 10),
              _QuickAddButton(
                icon: Icons.wine_bar_outlined,
                amount: '+1000',
                label: 'BOTELLA G',
                isSelected: customAmountMl == 1000,
                onTap: () => onQuickAdd(1000),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Cantidad personalizada ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cantidad personalizada',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '$customAmountMl ml',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: NutriColors.primary,
              inactiveTrackColor: NutriColors.border,
              thumbColor: NutriColors.primary,
              overlayColor: NutriColors.primary.withOpacity(0.1),
              trackHeight: 4,
            ),
            child: Slider(
              min: 50,
              max: 1500,
              divisions: 29,
              value: customAmountMl.toDouble(),
              onChanged: (v) => onCustomAmountChanged(v.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50 ml',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: NutriColors.textSecondary)),
              Text('1500 ml',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: NutriColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 24),

          // ── Botón Registrar ────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: onRegister,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Registrar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Widget botón de añadir rápido ─────────────────────────────────────────────

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String amount;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.amount,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? NutriColors.primary.withOpacity(0.1)
                : const Color(0xFFEAF0F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? NutriColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? NutriColors.primary
                    : NutriColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? NutriColors.primary
                      : NutriColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? NutriColors.primary
                      : NutriColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painter del círculo de progreso azul ──────────────────────────────────────

class _CircleProgressPainter extends CustomPainter {
  final double progress;

  const _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 14.0;

    // Track (fondo gris)
    final trackPaint = Paint()
      ..color = const Color(0xFFE8EDF0)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progreso azul
    final progressPaint = Paint()
      ..color = NutriColors.hydration
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) =>
      old.progress != progress;
}