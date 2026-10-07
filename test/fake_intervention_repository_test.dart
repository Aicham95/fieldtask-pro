import 'package:fieldtask_pro/features/interventions/data/repositories/fake_intervention_repository.dart';
import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/intervention_fixture.dart';

void main() {
  test('chaque technicien ne voit que ses interventions', () async {
    final repo = FakeInterventionRepository(initial: [
      makeIntervention(id: 'a', technicianId: '1'),
      makeIntervention(id: 'b', technicianId: '2'),
    ]);

    await repo.refreshFromServer('1');
    expect((await repo.watchAll().first).map((i) => i.id), ['a']);

    await repo.refreshFromServer('2');
    expect((await repo.watchAll().first).map((i) => i.id), ['b']);
  });

  test('updateStatus change le statut et marque non synchronisé', () async {
    final repo = FakeInterventionRepository(
        initial: [makeIntervention(id: 'a', technicianId: '1')]);
    await repo.refreshFromServer('1');

    await repo.updateStatus('a', InterventionStatus.inProgress);

    final updated = await repo.getById('a');
    expect(updated!.status, InterventionStatus.inProgress);
    expect(updated.synced, false);
  });

  test('saveFieldWork enregistre notes et photos', () async {
    final repo = FakeInterventionRepository(
        initial: [makeIntervention(id: 'a', technicianId: '1')]);

    await repo.saveFieldWork('a', notes: 'Câble remplacé', photoPaths: ['p.jpg']);

    final updated = await repo.getById('a');
    expect(updated!.notes, 'Câble remplacé');
    expect(updated.photoPaths, ['p.jpg']);
  });

  test('create ajoute une intervention visible', () async {
    final repo = FakeInterventionRepository(initial: []);
    await repo.refreshFromServer('t1');

    await repo.create(makeIntervention(id: 'n', technicianId: 't1'));

    expect((await repo.watchAll().first).length, 1);
  });
}
