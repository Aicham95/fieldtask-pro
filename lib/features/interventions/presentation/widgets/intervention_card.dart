import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/priority_badge.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/intervention.dart';

/// Une carte de la liste : client, titre, adresse, heure, durée, badges.
class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final VoidCallback onTap;

  const InterventionCard({
    super.key,
    required this.intervention,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final i = intervention;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(i.reference,
                        style: Theme.of(context).textTheme.labelMedium)),
                if (!i.synced)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.cloud_off_outlined,
                        size: 16, color: Colors.orange),
                  ),
                PriorityBadge(i.priority),
              ]),
              const SizedBox(height: 6),
              Text(i.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(i.clientName),
              Text('${i.address}, ${i.city}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(
                    '${DateFormat('dd/MM HH:mm').format(i.scheduledAt.toLocal())} · ${i.estimatedMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                StatusBadge(i.status),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
