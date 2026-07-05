import 'package:flutter/material.dart';
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

/// Transición fade suave — elimina el parpadeo entre vistas
/// sin animaciones pesadas que lentifiquen la app.
CustomTransitionPage<void> _fadePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

/// Transición slide desde la derecha — para navegación hacia adelante
/// (ej. login → dashboard, tap en un item de lista → detalle).
CustomTransitionPage<void> _slidePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: CurveTween(curve: Curves.easeIn).animate(animation),
          child: child,
        ),
      );
    },
  );
}

abstract class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Auth — fade (no hay dirección, son pantallas de entrada)
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),

      // Dashboard principal — fade (es la pantalla raíz de la app)
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const MainScaffold(),
        ),
      ),

      // Slide para navegación secundaria
      GoRoute(
        path: '/hydration',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const HydrationScreen(),
        ),
      ),
      GoRoute(
        path: '/mood',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const MoodScreen(),
        ),
      ),
      GoRoute(
        path: '/meal-plan',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const WeeklyMealPlanScreen(),
        ),
      ),
      GoRoute(
        path: '/medication',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const MedicationScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const TermsAndConditionsScreen(),
        ),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const ProgressScreen(),
        ),
      ),
    ],
  );
}