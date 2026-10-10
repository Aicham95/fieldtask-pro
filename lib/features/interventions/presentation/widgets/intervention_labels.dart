import 'package:flutter/material.dart';

import '../../domain/entities/intervention.dart';

/// Libellés et couleurs communs aux écrans du Lot 3 (fiche et carte).
String statusLabel(InterventionStatus s) => switch (s) {
      InterventionStatus.pending => 'En attente',
      InterventionStatus.inProgress => 'En cours',
      InterventionStatus.done => 'Terminée',
    };

Color statusColor(InterventionStatus s) => switch (s) {
      InterventionStatus.pending => Colors.orange,
      InterventionStatus.inProgress => Colors.blue,
      InterventionStatus.done => Colors.green,
    };

String priorityLabel(InterventionPriority p) => switch (p) {
      InterventionPriority.normal => 'Normale',
      InterventionPriority.high => 'Élevée',
      InterventionPriority.urgent => 'Urgente',
    };

Color priorityColor(InterventionPriority p) => switch (p) {
      InterventionPriority.normal => Colors.grey,
      InterventionPriority.high => Colors.deepOrange,
      InterventionPriority.urgent => Colors.red,
    };

/// Libellé du bouton qui fait passer au statut suivant (null si terminée).
String? nextStatusLabel(InterventionStatus s) => switch (s) {
      InterventionStatus.pending => 'Démarrer l\'intervention',
      InterventionStatus.inProgress => 'Terminer l\'intervention',
      InterventionStatus.done => null,
    };
