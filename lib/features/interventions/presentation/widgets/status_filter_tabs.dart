import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/intervention.dart';
import '../providers/interventions_provider.dart';
import 'intervention_labels.dart';

/// Onglets Tout / En attente / En cours / Terminées, avec compteurs.
class StatusFilterTabs extends ConsumerWidget {
  const StatusFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(statusFilterProvider);
    final all = ref.watch(allInterventionsProvider).value ?? const [];

    Widget chip(String label, InterventionStatus? status) {
      final count = status == null
          ? all.length
          : all.where((i) => i.status == status).length;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text('$label ($count)'),
          selected: selected == status,
          onSelected: (_) => ref.read(statusFilterProvider.notifier).set(status),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        chip('Tout', null),
        for (final s in InterventionStatus.values) chip(statusLabel(s), s),
      ]),
    );
  }
}
