import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          // Card central blanca
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
                    Image.asset(
                      'assets/images/nutrisync_logo.png',
                      height: 90,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: NutriColors.primaryDark,
                      ),
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