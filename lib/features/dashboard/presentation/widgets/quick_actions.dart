import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/sync/sync_provider.dart';

/// Voir mes interventions, Voir la carte, Synchroniser, Nouvelle intervention.
class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      ActionChip(
        avatar: const Icon(Icons.list_alt, size: 18),
        label: const Text('Mes interventions'),
        onPressed: () => context.go('/interventions'),
      ),
      ActionChip(
        avatar: const Icon(Icons.map_outlined, size: 18),
        label: const Text('Voir la carte'),
        onPressed: () => context.go('/map'),
      ),
      ActionChip(
        avatar: const Icon(Icons.sync, size: 18),
        label: const Text('Synchroniser'),
        onPressed: () => ref.read(syncServiceProvider).processQueue(),
      ),
      ActionChip(
        avatar: const Icon(Icons.add, size: 18),
        label: const Text('Nouvelle intervention'),
        onPressed: () => context.push('/interventions/new'),
      ),
    ]);
  }
}
