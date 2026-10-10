import 'package:flutter/material.dart';

import '../../../interventions/domain/entities/intervention.dart';
import '../../../interventions/presentation/widgets/intervention_labels.dart';

/// Pin de la carte, coloré selon le statut.
class InterventionMarker extends StatelessWidget {
  final InterventionStatus status;
  final VoidCallback onTap;

  const InterventionMarker({super.key, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Icon(Icons.location_on, size: 44, color: statusColor(status)),
      );
}
