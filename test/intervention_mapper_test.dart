import 'package:fieldtask_pro/features/interventions/data/mappers/intervention_mapper.dart';
import 'package:fieldtask_pro/features/interventions/data/models/intervention_model.dart';
import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/intervention_fixture.dart';

void main() {
  test('entité -> modèle -> entité conserve toutes les valeurs', () {
    final original = makeIntervention(
      status: InterventionStatus.inProgress,
      priority: InterventionPriority.urgent,
      scheduledAt: DateTime.utc(2026, 10, 6, 9, 30),
    ).copyWith(
      notes: 'RAS',
      photoPaths: const ['a.jpg', 'b.jpg'],
      updatedAt: DateTime.utc(2026, 10, 5),
    );

    final back = original.toModel().toEntity();

    expect(back, original);
  });

  test('le modèle SQLite garde les photos via toMap/fromMap', () {
    final model = makeIntervention()
        .copyWith(photoPaths: const ['x.jpg'], synced: false)
        .toModel();

    final restored = InterventionModel.fromMap(model.toMap());

    expect(restored.photoPaths, ['x.jpg']);
    expect(restored.synced, false);
  });

  test('fromJson lit un JSON du serveur sans photos ni signature', () {
    final model = InterventionModel.fromJson({
      'id': 'i84',
      'technicianId': '1',
      'reference': 'INT-2026-084',
      'title': 'Maintenance antenne 4G',
      'clientName': 'Orange Sénégal',
      'city': 'Saint-Louis',
      'address': 'Avenue',
      'description': 'Signal faible',
      'equipment': 'Antenne 4G',
      'instructions': 'Vérifier',
      'priority': 1,
      'status': 0,
      'latitude': 16.0245,
      'longitude': -16.4896,
      'scheduledAt': '2026-10-06T09:30:00Z',
      'estimatedMinutes': 90,
      'updatedAt': '2026-10-05T08:00:00Z',
    });

    final entity = model.toEntity();

    expect(entity.priority, InterventionPriority.high);
    expect(entity.status, InterventionStatus.pending);
    expect(entity.photoPaths, isEmpty);
    expect(entity.synced, true);
  });
}
