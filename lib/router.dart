import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/results_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/mill_profile_screen.dart';
import 'screens/quality/qd_home_screen.dart';
import 'screens/quality/app1_ipi_screen.dart';
import 'screens/quality/app2_fqi_screen.dart';
import 'screens/quality/app3_yarn_quality_screen.dart';
import 'screens/quality/app4_standards_screen.dart';
import 'screens/quality/app5_variety_screen.dart';
import 'screens/quality/app6_benchmark_screen.dart';
import 'screens/quality/mix_selection_screen.dart';
import 'screens/quality/tracker_screen.dart';
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
    // Quality Diagnosis routes
    GoRoute(
      path: '/quality',
      builder: (ctx, state) => const QdHomeScreen(),
    ),
    GoRoute(
      path: '/quality/app1',
      builder: (ctx, state) => const App1IpiScreen(),
    ),
    GoRoute(
      path: '/quality/app2',
      builder: (ctx, state) => const App2FqiScreen(),
    ),
    GoRoute(
      path: '/quality/app3',
      builder: (ctx, state) => const App3YarnQualityScreen(),
    ),
    GoRoute(
      path: '/quality/app4',
      builder: (ctx, state) => const App4StandardsScreen(),
    ),
    GoRoute(
      path: '/quality/app5',
      builder: (ctx, state) => const App5VarietyScreen(),
    ),
    GoRoute(
      path: '/quality/app6',
      builder: (ctx, state) => const App6BenchmarkScreen(),
    ),
    GoRoute(
      path: '/quality/mix',
      builder: (ctx, state) => const MixSelectionScreen(),
    ),
    GoRoute(
      path: '/quality/tracker',
      builder: (ctx, state) => const TrackerScreen(),
    ),
  ],
);
