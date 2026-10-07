import 'package:fieldtask_pro/features/interventions/data/repositories/fake_intervention_repository.dart';
import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';
import 'package:fieldtask_pro/features/interventions/domain/usecases/get_interventions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/intervention_fixture.dart';

void main() {
  late FakeInterventionRepository repo;

  setUp(() {
    repo = FakeInterventionRepository(initial: [
      makeIntervention(
          id: 'a',
          status: InterventionStatus.pending,
          priority: InterventionPriority.normal,
          title: 'Routeur fibre'),
      makeIntervention(
          id: 'b',
          status: InterventionStatus.pending,
          priority: InterventionPriority.urgent,
          title: 'Antenne 4G'),
      makeIntervention(
          id: 'c',
          status: InterventionStatus.done,
          priority: InterventionPriority.high,
          title: 'Onduleur'),
    ]);
    repo.refreshFromServer('t1');
  });

  test('filtre par statut', () async {
    final list = await GetInterventions(repo)(status: InterventionStatus.done).first;
    expect(list.map((i) => i.id), ['c']);
  });

  test('trie les urgentes en premier', () async {
    final list = await GetInterventions(repo)().first;
    expect(list.first.id, 'b');
    expect(list.last.id, 'a');
  });

  test('recherche texte sur le titre', () async {
    final list = await GetInterventions(repo)(query: 'routeur').first;
    expect(list.map((i) => i.id), ['a']);
  });
}
