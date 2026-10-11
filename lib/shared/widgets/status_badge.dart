import 'package:flutter/material.dart';

import '../../features/interventions/domain/entities/intervention.dart';
import '../../features/interventions/presentation/widgets/intervention_labels.dart';

class StatusBadge extends StatelessWidget {
  final InterventionStatus status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) =>
      _Pill(statusLabel(status), statusColor(status));
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}
