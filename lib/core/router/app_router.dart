import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

// TODO: importar cuando se creen los features
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/mood/presentation/screen/mood_screen.dart';

// import '../../features/meal_plan/presentation/screens/weekly_meal_plan_screen.dart';
import '../../features/medication/presentation/screens/medication_screen.dart';

abstract class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

     GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardScreen(),
),

     GoRoute(
  path: '/hydration',
  builder: (context, state) => const HydrationScreen(),
),

     GoRoute(
  path: '/mood',
  builder: (context, state) => const MoodScreen(),
),

      // GoRoute(
      //   path: '/meal-plan',
      //   builder: (context, state) => const WeeklyMealPlanScreen(),
      // ),
      GoRoute(
        path: '/medication',
        builder: (context, state) => const MedicationScreen(),
      ),
    ],
  );
}