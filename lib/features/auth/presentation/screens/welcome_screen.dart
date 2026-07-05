import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).checkSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Si el usuario ya está autenticado, redirigir al dashboard
    ref.listen<AuthState>(authControllerProvider, (_, state) {
      if (state is AuthAuthenticated) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo — imagen de hojas
          Image.asset(
            'assets/images/bg_leaves.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                ),
              ),
            ),
          ),

          // Mientras verifica sesión mostrar un loading
          if (authState is AuthLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Pantalla de bienvenida (solo si no está autenticado)
          if (authState is AuthInitial || authState is AuthUnauthenticated)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: NutriColors.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo nutria
                      SvgPicture.asset(
                        'assets/images/nutrisync_logo.svg',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Bienvenido a\nNutrisync',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Tu camino hacia una nutrición\nconsciente y personalizada.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: NutriColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // Botón Iniciar sesión
                      ElevatedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Iniciar sesión'),
                      ),
                      const SizedBox(height: 14),

                      // Link crear cuenta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No tienes cuenta? ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: NutriColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              'Crear cuenta',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: NutriColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}