import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../progress/presentation/screens/progress_screen.dart';
import '../../domain/entities/profile_entity.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _syncControllers(ProfileEntity profile) {
    _nameController.text = profile.name;
    _weightController.text = profile.weightKg?.toString() ?? '';
    _heightController.text = profile.heightCm?.toString() ?? '';
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: NutriColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    // Sincronizar controladores cuando el perfil se carga por primera vez
    ref.listen<ProfileState>(profileControllerProvider, (previous, next) {
      if (next is ProfileLoaded && previous is! ProfileLoaded) {
        _syncControllers(next.profile);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        ProfileLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        ProfileError(:final message) => Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: NutriColors.textSecondary),
                  SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(profileControllerProvider.notifier).load(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ProfileLoaded() => _ProfileContent(
            state: state,
            nameController: _nameController,
            weightController: _weightController,
            heightController: _heightController,
            onEditToggle: () =>
                ref.read(profileControllerProvider.notifier).toggleEditing(),
            onSave: () {
              ref.read(profileControllerProvider.notifier).save(
                    name: _nameController.text,
                    weightKg: double.tryParse(_weightController.text),
                    heightCm: double.tryParse(_heightController.text),
                  );
            },
            onViewProgress: () => Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 260),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProgressScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity:
                          CurveTween(curve: Curves.easeIn).animate(animation),
                      child: child,
                    ),
                  );
                },
              ),
            ),
            onLogout: _confirmLogout,
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileLoaded state;
  final TextEditingController nameController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final VoidCallback onEditToggle;
  final VoidCallback onSave;
  final VoidCallback onViewProgress;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.state,
    required this.nameController,
    required this.weightController,
    required this.heightController,
    required this.onEditToggle,
    required this.onSave,
    required this.onViewProgress,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar y nombre ──────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: NutriColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: NutriColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(profile.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                Text(profile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NutriColors.textSecondary,
                        )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Acceso a Mi Progreso ─────────────────────────────────
          GestureDetector(
            onTap: onViewProgress,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NutriColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NutriColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: NutriColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bar_chart_rounded,
                        color: NutriColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mi Progreso',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('Ve tu avance semanal',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: NutriColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: NutriColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Términos y Condiciones ────────────────────────────────
          GestureDetector(
            onTap: () => context.push('/terms'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NutriColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NutriColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: NutriColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: NutriColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Términos y Condiciones',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('Lee nuestros términos de uso',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: NutriColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: NutriColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Datos personales ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Datos personales',
                  style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: state.isEditing ? onSave : onEditToggle,
                icon: Icon(
                  state.isEditing ? Icons.check : Icons.edit_outlined,
                  size: 16,
                ),
                label: Text(state.isEditing ? 'Guardar' : 'Editar'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NutriColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NutriColors.textSecondary,
                        )),
                const SizedBox(height: 6),
                state.isEditing
                    ? TextFormField(controller: nameController)
                    : Text(profile.name,
                        style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Peso (kg)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: NutriColors.textSecondary)),
                          const SizedBox(height: 6),
                          state.isEditing
                              ? TextFormField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                )
                              : Text(
                                  profile.weightKg != null
                                      ? '${profile.weightKg}'
                                      : '—',
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Altura (cm)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: NutriColors.textSecondary)),
                          const SizedBox(height: 6),
                          state.isEditing
                              ? TextFormField(
                                  controller: heightController,
                                  keyboardType: TextInputType.number,
                                )
                              : Text(
                                  profile.heightCm != null
                                      ? '${profile.heightCm}'
                                      : '—',
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Cerrar sesión ────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, size: 18, color: NutriColors.error),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: NutriColors.error,
              side: const BorderSide(color: NutriColors.error),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}