import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../features/dashboard/presentation/main_scaffold.dart';
import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/mood/presentation/screen/mood_screen.dart';

import '../../features/meal_plan/presentation/screens/weekly_meal_plan_screen.dart';
import '../../features/medication/presentation/screens/medication_screen.dart';
import '../../features/dashboard/presentation/screens/terms_and_conditions_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';

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
   builder: (context, state) => const MainScaffold(),
 ),

     GoRoute(
  path: '/hydration',
  builder: (context, state) => const HydrationScreen(),
),

     GoRoute(
  path: '/mood',
  builder: (context, state) => const MoodScreen(),
),

      GoRoute(
        path: '/meal-plan',
        builder: (context, state) => const WeeklyMealPlanScreen(),
      ),
      GoRoute(
        path: '/medication',
        builder: (context, state) => const MedicationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
    ],
  );
}