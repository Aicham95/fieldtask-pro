import 'package:flutter/material.dart';

import '../../../interventions/domain/entities/intervention.dart';
import '../../../interventions/presentation/widgets/intervention_labels.dart';

/// Fiche rapide ouverte au clic sur un pin.
class InterventionQuickSheet extends StatelessWidget {
  final Intervention intervention;
  final VoidCallback onOpenDetail;

  const InterventionQuickSheet({
    super.key,
    required this.intervention,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final i = intervention;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(i.reference, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(i.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${i.clientName} · ${i.address}'),
            const SizedBox(height: 8),
            Text('${statusLabel(i.status)} · Priorité ${priorityLabel(i.priority).toLowerCase()}',
                style: TextStyle(color: statusColor(i.status))),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onOpenDetail,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Voir la fiche complète'),
            ),
          ],
        ),
      ),
    );
  }
}
