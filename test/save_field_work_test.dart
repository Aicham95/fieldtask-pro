import 'package:fieldtask_pro/features/interventions/data/repositories/fake_intervention_repository.dart';
import 'package:fieldtask_pro/features/interventions/domain/usecases/save_field_work.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/intervention_fixture.dart';

void main() {
  test('enregistre notes, photos et signature', () async {
    final repo = FakeInterventionRepository(
        initial: [makeIntervention(id: 'a', technicianId: '1')]);

    await SaveFieldWork(repo)('a',
        notes: 'Câble remplacé',
        photoPaths: ['p1.jpg'],
        signaturePath: 'sig.png');

    final i = await repo.getById('a');
    expect(i!.notes, 'Câble remplacé');
    expect(i.photoPaths, ['p1.jpg']);
    expect(i.signaturePath, 'sig.png');
    expect(i.synced, false);
  });

  test('refuse une intervention inconnue', () async {
    final repo = FakeInterventionRepository(initial: []);

    expect(() => SaveFieldWork(repo)('zzz', notes: 'x'),
        throwsA(isA<ArgumentError>()));
  });
}
