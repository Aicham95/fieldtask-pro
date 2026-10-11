import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/connectivity_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/interventions_provider.dart';
import '../widgets/intervention_card.dart';
import '../widgets/sort_menu.dart';
import '../widgets/status_filter_tabs.dart';

/// Écran « Mes interventions » : recherche, onglets de statut, tri, liste.
class InterventionsListPage extends ConsumerWidget {
  const InterventionsListPage({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authProvider.notifier).refreshInterventions();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Hors ligne : liste enregistrée sur le téléphone.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(filteredInterventionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes interventions'),
        actions: const [ConnectivityBadge(), SortMenu()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/interventions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher (client, adresse, équipement...)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
          ),
        ),
        const StatusFilterTabs(),
        const SizedBox(height: 4),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context, ref),
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (items) => items.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Aucune intervention.')),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: items.length,
                      itemBuilder: (_, i) => InterventionCard(
                        intervention: items[i],
                        onTap: () =>
                            context.push('/interventions/${items[i].id}'),
                      ),
                    ),
            ),
          ),
        ),
      ]),
    );
  }
}
