import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/connectivity_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../interventions/presentation/widgets/intervention_card.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/day_summary.dart';
import '../widgets/quick_actions.dart';
import '../widgets/stat_card.dart';

/// Écran d'accueil : salutation, chiffres, « Votre journée », prochaines
/// interventions, actions rapides.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final stats = ref.watch(dashboardStatsProvider).value;
    final upcoming = ref.watch(upcomingInterventionsProvider);
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour${firstName.isEmpty ? '' : ', $firstName'}'),
        actions: const [ConnectivityBadge()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              StatCard(
                  label: 'À faire',
                  value: stats?.toDo ?? 0,
                  color: Colors.orange,
                  icon: Icons.pending_actions),
              StatCard(
                  label: 'En cours',
                  value: stats?.inProgress ?? 0,
                  color: Colors.blue,
                  icon: Icons.build),
              StatCard(
                  label: 'Terminées',
                  value: stats?.done ?? 0,
                  color: Colors.green,
                  icon: Icons.check_circle_outline),
              StatCard(
                  label: 'Prioritaires',
                  value: stats?.priority ?? 0,
                  color: Colors.red,
                  icon: Icons.priority_high),
            ],
          ),
          const SizedBox(height: 8),
          DaySummary(
              planned: stats?.plannedToday ?? 0,
              minutes: stats?.plannedMinutesToday ?? 0),
          const SizedBox(height: 16),
          Text('Prochaines interventions',
              style: Theme.of(context).textTheme.titleMedium),
          if (upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Aucune intervention à venir.'),
            ),
          for (final i in upcoming)
            InterventionCard(
              intervention: i,
              onTap: () => context.push('/interventions/${i.id}'),
            ),
          const SizedBox(height: 16),
          const QuickActions(),
        ],
      ),
    );
  }
}
