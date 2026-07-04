import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'privacy_policy_screen.dart';

/// Modal de consentimiento que se muestra una sola vez,
/// justo después del registro y antes de entrar al dashboard.
class PrivacyConsentOverlay extends StatelessWidget {
  final VoidCallback onAccept;

  const PrivacyConsentOverlay({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NutriColors.primary.withValues(alpha: 0.25),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: NutriColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: NutriColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu Privacidad es Nuestra\nPrioridad',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Utilizamos tus datos para personalizar y mejorar tu experiencia de nutrición y el seguimiento de tu salud. Al continuar, nos permites ofrecerte recomendaciones precisas basadas en tus objetivos personales.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: NutriColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Aceptar y Continuar'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 260),
                      reverseTransitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const PrivacyPolicyScreen(),
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
                  child: Text(
                    'Leer Política de Privacidad',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NutriColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}