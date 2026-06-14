import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NutriSync')),
      backgroundColor: NutriColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Dashboard — en construcción'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/hydration'),
              child: const Text('Ver Hidratación'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/mood'),
              child: const Text('Ver Bienestar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/meal-plan'),
              child: const Text('Ver Plan de Comidas'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/medication'),
              child: const Text('Ver Medicación'),
            ),
          ],
        ),
      ),
    );
  }
}