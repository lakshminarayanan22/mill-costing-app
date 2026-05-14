import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/results_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/mill_profile_screen.dart';
import 'models/calculation_result.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/calculator',
      builder: (ctx, state) => const CalculatorScreen(),
    ),
    GoRoute(
      path: '/results',
      builder: (ctx, state) {
        final result = state.extra as CalculationResult;
        return ResultsScreen(result: result);
      },
    ),
    GoRoute(
      path: '/analytics',
      builder: (ctx, state) {
        final result = state.extra as CalculationResult;
        return AnalyticsScreen(result: result);
      },
    ),
    GoRoute(
      path: '/profiles',
      builder: (ctx, state) => const MillProfileScreen(),
    ),
    GoRoute(
      path: '/profiles/edit/:id',
      builder: (ctx, state) {
        final id = state.pathParameters['id']!;
        return MillProfileEditScreen(profileId: id);
      },
    ),
  ],
);
