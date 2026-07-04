import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_sync/core/theme/app_theme.dart';
import 'package:nutri_sync/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:nutri_sync/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:nutri_sync/features/hydration/presentation/controllers/hydration_controller.dart';
import 'package:nutri_sync/features/hydration/presentation/screens/hydration_screen.dart';
import 'package:nutri_sync/features/meal_plan/presentation/controllers/meal_plan_controller.dart';
import 'package:nutri_sync/features/meal_plan/presentation/screens/weekly_meal_plan_screen.dart';
import 'package:nutri_sync/features/medication/presentation/controllers/medication_controller.dart';
import 'package:nutri_sync/features/medication/presentation/screens/medication_screen.dart';
import 'package:nutri_sync/features/mood/presentation/controllers/mood_controller.dart';
import 'package:nutri_sync/features/mood/presentation/screen/mood_screen.dart';

/// Scaffold principal con bottom navigation bar de 5 tabs:
/// Inicio, Comidas, Medicación, Ánimo, Hidratación.
/// Cada vez que se cambia de tab, se recarga automáticamente la data del mismo
/// para mantener la información siempre actualizada sin requerir pull-to-refresh.
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WeeklyMealPlanScreen(),
    MedicationScreen(),
    MoodScreen(),
    HydrationScreen(),
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.restaurant_menu,
    Icons.medication,
    Icons.sentiment_satisfied_alt_outlined,
    Icons.local_drink,
  ];

  static const _activeIcons = [
    Icons.home_rounded,
    Icons.restaurant_menu,
    Icons.medication,
    Icons.sentiment_satisfied_alt,
    Icons.local_drink,
  ];

  static const _labels = [
    'Inicio',
    'Comidas',
    'Medicación',
    'Ánimo',
    'Hidratación',
  ];

  void _reloadTab(int index) {
    switch (index) {
      case 0:
        ref.read(dashboardControllerProvider.notifier).load();
      case 1:
        ref.read(mealPlanControllerProvider.notifier).load();
      case 2:
        ref.read(medicationControllerProvider.notifier).load();
      case 3:
        ref.read(moodControllerProvider.notifier).load();
      case 4:
        ref.read(hydrationControllerProvider.notifier).loadToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _reloadTab(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFDCEFE6),
        selectedItemColor: NutriColors.primary,
        unselectedItemColor: NutriColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: List.generate(5, (i) {
          final isActive = i == _currentIndex;
          return BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            activeIcon: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: NutriColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? _activeIcons[i] : _icons[i],
                color: Colors.white,
                size: 20,
              ),
            ),
            label: _labels[i],
          );
        }),
      ),
    );
  }
}