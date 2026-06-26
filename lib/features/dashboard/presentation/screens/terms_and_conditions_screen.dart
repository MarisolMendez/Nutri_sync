import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                  Icons.description_outlined,
                  color: NutriColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Términos y Condiciones\nde Uso',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Al usar NutriSync aceptas los siguientes términos.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: NutriColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),

              // ── Contenido ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Términos y Condiciones de NutriSync',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),

              const _TermsSection(
                number: '1',
                title: 'Aceptación de los términos',
                body:
                    'Al acceder y utilizar esta aplicación, usted acepta estar sujeto a estos Términos y Condiciones. Si no está de acuerdo con alguno de ellos, no debe usar la aplicación.',
              ),
              const _TermsSection(
                number: '2',
                title: 'Uso de la aplicación',
                body:
                    'NutriSync es una herramienta de apoyo nutricional. La información proporcionada no sustituye la consulta con un profesional de la salud. Usted es responsable de su propia salud y decisiones.',
              ),
              const _TermsSection(
                number: '3',
                title: 'Registro de cuenta',
                body:
                    'Para usar ciertas funciones debe registrar una cuenta. Usted es responsable de mantener la confidencialidad de sus credenciales y de todas las actividades realizadas con su cuenta.',
              ),
              const _TermsSection(
                number: '4',
                title: 'Precisión de los datos',
                body:
                    'Los datos de composición nutricional de alimentos se proporcionan como referencia general. No garantizamos la exactitud absoluta de toda la información.',
              ),
              const _TermsSection(
                number: '5',
                title: 'Propiedad intelectual',
                body:
                    'Todo el contenido de la app (texto, gráficos, logotipos, código) es propiedad de NutriSync. No está permitida su reproducción sin autorización.',
              ),
              const _TermsSection(
                number: '6',
                title: 'Limitación de responsabilidad',
                body:
                    'NutriSync no se hace responsable por daños directos o indirectos derivados del uso de la aplicación, incluyendo pero no limitado a problemas de salud.',
              ),
              const _TermsSection(
                number: '7',
                title: 'Modificaciones',
                body:
                    'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios serán notificados dentro de la aplicación.',
              ),
              const _TermsSection(
                number: '8',
                title: 'Contacto',
                body:
                    'Para preguntas sobre estos términos, contáctenos en: soporte@nutrisync.com',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _TermsSection({
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