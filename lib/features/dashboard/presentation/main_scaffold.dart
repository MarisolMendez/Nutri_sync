import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../hydration/presentation/screens/hydration_screen.dart';
import '../../meal_plan/presentation/screens/weekly_meal_plan_screen.dart';
import '../../medication/presentation/screens/medication_screen.dart';
import '../../mood/presentation/screen/mood_screen.dart';
import 'screens/dashboard_screen.dart';

/// Scaffold principal con bottom navigation bar de 5 tabs:
/// Inicio, Comidas, Medicación, Ánimo, Hidratación.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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