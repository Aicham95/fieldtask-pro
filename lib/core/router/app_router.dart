import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/interventions/presentation/pages/create_intervention_page.dart';
import '../../features/interventions/presentation/pages/intervention_detail_page.dart';
import '../../features/interventions/presentation/pages/interventions_list_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../shared/widgets/app_scaffold.dart';

/// Routes : /login, /dashboard, /interventions, /interventions/new,
/// /interventions/:id, /map, /profile.
/// Sans session, tout renvoie vers /login.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authProvider).status;
      final where = state.matchedLocation;
      if (status == AuthStatus.unknown) return where == '/splash' ? null : '/splash';
      if (status == AuthStatus.unauthenticated) {
        return where == '/login' ? null : '/login';
      }
      if (where == '/login' || where == '/splash') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/interventions',
                builder: (_, _) => const InterventionsListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/map', builder: (_, _) => const MapPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
          ]),
        ],
      ),
      // Écrans plein écran, au-dessus de la barre de navigation.
      GoRoute(
        path: '/interventions/new',
        builder: (_, _) => Consumer(
          builder: (_, ref, _) => CreateInterventionPage(
              technicianId: ref.read(authProvider).user?.id ?? ''),
        ),
      ),
      GoRoute(
        path: '/interventions/:id',
        builder: (_, state) =>
            InterventionDetailPage(interventionId: state.pathParameters['id']!),
      ),
    ],
  );
});
