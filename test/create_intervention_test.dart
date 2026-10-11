import 'package:fieldtask_pro/features/interventions/data/repositories/fake_intervention_repository.dart';
import 'package:fieldtask_pro/features/interventions/domain/usecases/create_intervention.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/intervention_fixture.dart';

void main() {
  test('crée une intervention visible pour son technicien', () async {
    final repo = FakeInterventionRepository(initial: []);
    await repo.refreshFromServer('t1');

    await CreateIntervention(repo)(makeIntervention(id: 'n1', technicianId: 't1'));

    final list = await repo.watchAll().first;
    expect(list.single.id, 'n1');
    expect(list.single.synced, false);
  });

  test('refuse un titre vide', () async {
    final repo = FakeInterventionRepository(initial: []);

    expect(() => CreateIntervention(repo)(makeIntervention(title: '  ')),
        throwsA(isA<ArgumentError>()));
  });
}
