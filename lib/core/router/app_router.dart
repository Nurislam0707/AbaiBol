import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_welcome_screen.dart';
import '../../features/feedback/domain/models/review_reference.dart';
import '../../features/feedback/domain/models/review_target_kind.dart';
import '../../features/feedback/presentation/screens/add_review_screen.dart';
import '../../features/feedback/presentation/screens/building_categories_screen.dart';
import '../../features/feedback/presentation/screens/clubs_screen.dart';
import '../../features/feedback/presentation/screens/faculty_screen.dart';
import '../../features/feedback/presentation/screens/leaderboard_screen.dart';
import '../../features/feedback/presentation/screens/rating_screen.dart';
import '../../features/feedback/presentation/screens/reviews_screen.dart';
import '../../features/feedback/presentation/screens/search_screen.dart';
import '../../features/feedback/presentation/screens/student_life_categories_screen.dart';
import '../../features/feedback/presentation/screens/subjects_screen.dart';
import '../../features/feedback/presentation/screens/teachers_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/my_reviews_screen.dart';
import '../../features/feedback/presentation/screens/qr_scanner_screen.dart';
import '../../shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const AuthWelcomeScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const SearchScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const LeaderboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/qr',
        pageBuilder: (context, state) =>
            _slideUpPage(state: state, child: const QrScannerScreen()),
      ),
      GoRoute(
        path: '/profile/reviews',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const MyReviewsScreen()),
      ),
      GoRoute(
        path: '/faculties/:kind',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: FacultyScreen(kind: state.pathParameters['kind']!),
        ),
      ),
      GoRoute(
        path: '/teachers',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const TeachersScreen()),
      ),
      GoRoute(
        path: '/teachers/:facultyId',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: TeachersScreen(facultyId: state.pathParameters['facultyId']),
        ),
      ),
      GoRoute(
        path: '/subjects',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const SubjectsScreen()),
      ),
      GoRoute(
        path: '/reviews/:kind/:targetId',
        pageBuilder: (context, state) {
          final reference = _buildReviewReference(state);
          if (reference == null) {
            return _fadePage(
              state: state,
              child: const _RouteFallbackScreen(
                title: 'Review not available',
                message:
                    'The review page could not be opened because the target information is invalid.',
              ),
            );
          }

          return _slidePage(
            state: state,
            child: ReviewsScreen(reference: reference),
          );
        },
      ),
      GoRoute(
        path: '/reviews/:kind/:targetId/add',
        pageBuilder: (context, state) {
          final reference = _buildReviewReference(state);
          if (reference == null) {
            return _fadePage(
              state: state,
              child: const _RouteFallbackScreen(
                title: 'Review form not available',
                message:
                    'The app could not identify what you are trying to review.',
              ),
            );
          }

          return _slideUpPage(
            state: state,
            child: AddReviewScreen(reference: reference),
          );
        },
      ),
      GoRoute(
        path: '/buildings/:facultyId',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BuildingCategoriesScreen(
            facultyId: state.pathParameters['facultyId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/student-life',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const StudentLifeCategoriesScreen(),
        ),
      ),
      GoRoute(
        path: '/clubs',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const ClubsScreen()),
      ),
      GoRoute(
        path: '/rate',
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is! RatingScreenArgs) {
            return _fadePage(
              state: state,
              child: const _RouteFallbackScreen(
                title: 'Page unavailable',
                message:
                    'The page could not be opened because required navigation data is missing.',
              ),
            );
          }

          return _slideUpPage(
            state: state,
            child: RatingScreen(args: extra),
          );
        },
      ),
    ],
  );
});

ReviewReference? _buildReviewReference(GoRouterState state) {
  final kindValue = state.pathParameters['kind'];
  final targetId = state.pathParameters['targetId'];
  if (kindValue == null || targetId == null) {
    return null;
  }

  try {
    return ReviewReference(
      targetKind: ReviewTargetKindX.fromValue(kindValue),
      targetId: targetId,
    );
  } catch (_) {
    return null;
  }
}

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: offset,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

CustomTransitionPage<void> _slideUpPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class _RouteFallbackScreen extends StatelessWidget {
  const _RouteFallbackScreen({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 52,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
