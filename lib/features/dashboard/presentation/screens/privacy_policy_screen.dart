import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  /// Si viene de un flujo de registro, muestra el botón de aceptar
  /// y navega al continuar. Si se abre desde el modal o desde
  /// configuración como solo lectura, oculta el botón de acción.
  final VoidCallback? onAccept;

  const PrivacyPolicyScreen({super.key, this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: NutriColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: NutriColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tu privacidad es\nnuestra prioridad',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'En NutriSync, tratamos tus datos con la misma precisión que tu nutrición.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: NutriColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 28),

                    // ── Contenido alineado a la izquierda ───────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Política de Privacidad de NutriSync',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const _PolicySection(
                      number: '1',
                      title: 'Datos que recopilamos',
                      body:
                          'Nombre, correo electrónico, fecha de nacimiento, peso, altura, objetivos de salud, alergias, preferencias dietéticas, registro de comidas, agua, estado de ánimo y datos técnicos del dispositivo.',
                    ),
                    const _PolicySection(
                      number: '2',
                      title: 'Uso de sus datos',
                      body:
                          'Personalizar su plan de alimentación, dar seguimiento a su progreso, mejorar la app y enviar recordatorios o mensajes motivacionales.',
                    ),
                    const _PolicySection(
                      number: '3',
                      title: 'Compartición de datos',
                      body:
                          'No vendemos ni compartimos sus datos con anunciantes. Solo compartimos datos anonimizados con nuestro equipo para mejorar la app. Su nutriólogo podrá ver su progreso solo si usted lo autoriza.',
                    ),
                    const _PolicySection(
                      number: '4',
                      title: 'Almacenamiento',
                      body:
                          'Sus datos se almacenan en servidores seguros con encriptación. Si elimina su cuenta, sus datos se borran en 30 días.',
                    ),
                    const _PolicySection(
                      number: '5',
                      title: 'Sus derechos',
                      body:
                          'Acceso, corrección, eliminación y portabilidad de sus datos.',
                    ),
                    const _PolicySection(
                      number: '6',
                      title: 'Contacto',
                      body: 'privacidad@nutrisync.com',
                    ),
                    const _PolicySection(
                      number: '7',
                      title: 'Cambios a esta política',
                      body:
                          'Le notificaremos cualquier cambio dentro de la app o por correo electrónico.',
                    ),
                  ],
                ),
              ),
            ),

            // ── Botón fijo abajo ───────────────────────────────────
            if (onAccept != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Aceptar y Continuar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _PolicySection({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number. $title',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NutriColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}