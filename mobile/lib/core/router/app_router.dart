import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_setup_screen.dart';
import '../../features/onboarding/presentation/screens/permissions_setup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/main_shell_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/vehicle-setup', builder: (_, __) => const VehicleSetupScreen()),
      GoRoute(path: '/permissions-setup', builder: (_, __) => const PermissionsSetupScreen()),
      GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),

      // Main app shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/statistics', builder: (_, __) => const StatisticsScreen()),
          GoRoute(path: '/goals', builder: (_, __) => const GoalsScreen()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
