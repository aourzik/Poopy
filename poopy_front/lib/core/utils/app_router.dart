import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/medications/screens/medications_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';

// Route names
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const register = '/register';
  static const login = '/login';
  static const home = '/home';
  static const dashboard = '/home/dashboard';
  static const journal = '/home/journal';
  static const medications = '/home/medications';
  static const appointments = '/home/appointments';
  static const profile = '/home/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
            );
          },
        ),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            redirect: (_, __) => AppRoutes.dashboard,
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.journal,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.medications,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MedicationsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.appointments,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
