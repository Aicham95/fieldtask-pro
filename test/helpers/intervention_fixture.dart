import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';

/// Fabrique une intervention de test avec des valeurs par défaut.
Intervention makeIntervention({
  String id = 'i1',
  String technicianId = 't1',
  InterventionStatus status = InterventionStatus.pending,
  InterventionPriority priority = InterventionPriority.normal,
  DateTime? scheduledAt,
  int estimatedMinutes = 60,
  String title = 'Maintenance antenne 4G',
}) {
  return Intervention(
    id: id,
    technicianId: technicianId,
    reference: 'INT-2026-$id',
    title: title,
    clientName: 'Orange Sénégal',
    city: 'Saint-Louis',
    address: 'Avenue du Général de Gaulle',
    description: 'Signal faible',
    equipment: 'Antenne 4G',
    instructions: 'Vérifier les équipements',
    priority: priority,
    status: status,
    latitude: 16.0245,
    longitude: -16.4896,
    scheduledAt: scheduledAt ?? DateTime(2026, 10, 6, 9, 30),
    estimatedMinutes: estimatedMinutes,
    updatedAt: DateTime(2026, 10, 5),
  );
}
