import 'package:flutter/material.dart';

import '../../features/interventions/domain/entities/intervention.dart';
import '../../features/interventions/presentation/widgets/intervention_labels.dart';

class PriorityBadge extends StatelessWidget {
  final InterventionPriority priority;

  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(priorityLabel(priority),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
