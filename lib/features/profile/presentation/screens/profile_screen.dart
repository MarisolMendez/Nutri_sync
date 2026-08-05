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
  DateTime? _dateOfBirth;
  String? _gender;

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
    _dateOfBirth = profile.dateOfBirth;
    _gender = profile.gender;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
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
            dateOfBirth: _dateOfBirth,
            gender: _gender,
            onPickDate: _pickDate,
            onGenderChanged: (g) => setState(() => _gender = g),
            onEditToggle: () =>
                ref.read(profileControllerProvider.notifier).toggleEditing(),
            onSave: () {
              ref.read(profileControllerProvider.notifier).save(
                    name: _nameController.text,
                    weightKg: double.tryParse(_weightController.text),
                    heightCm: double.tryParse(_heightController.text),
                    dateOfBirth: _dateOfBirth,
                    gender: _gender,
                  );
            },
            onViewProgress: () => Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 260),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProgressScreen(),
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
  final DateTime? dateOfBirth;
  final String? gender;
  final VoidCallback onPickDate;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onEditToggle;
  final VoidCallback onSave;
  final VoidCallback onViewProgress;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.state,
    required this.nameController,
    required this.weightController,
    required this.heightController,
    required this.dateOfBirth,
    required this.gender,
    required this.onPickDate,
    required this.onGenderChanged,
    required this.onEditToggle,
    required this.onSave,
    required this.onViewProgress,
    required this.onLogout,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _fieldRow(context, 'Nombre', nameController, profile.name, state.isEditing),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _fieldRow(context, 'Peso (kg)', weightController, profile.weightKg?.toString() ?? '—', state.isEditing, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _fieldRow(context, 'Altura (cm)', heightController, profile.heightCm?.toString() ?? '—', state.isEditing, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Fecha de nacimiento',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NutriColors.textSecondary)),
                const SizedBox(height: 6),
                if (state.isEditing)
                  GestureDetector(
                    onTap: onPickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: NutriColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: NutriColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(_formatDate(dateOfBirth), style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  )
                else
                  Text(_formatDate(dateOfBirth), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text('Género',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NutriColors.textSecondary)),
                const SizedBox(height: 6),
                if (state.isEditing)
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Masculino')),
                      DropdownMenuItem(value: 'female', child: Text('Femenino')),
                    ],
                    onChanged: onGenderChanged,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  )
                else
                  Text(gender == 'male' ? 'Masculino' : gender == 'female' ? 'Femenino' : '—',
                      style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 24),

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

  Widget _fieldRow(BuildContext context, String label, TextEditingController controller, String displayValue, bool isEditing, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NutriColors.textSecondary)),
        const SizedBox(height: 6),
        isEditing
            ? TextFormField(controller: controller, keyboardType: isNumber ? TextInputType.number : null)
            : Text(displayValue, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}