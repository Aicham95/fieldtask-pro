import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';
import 'package:fieldtask_pro/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:fieldtask_pro/features/interventions/domain/usecases/update_intervention_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/intervention_fixture.dart';

class MockRepo extends Mock implements InterventionRepository {}

void main() {
  late MockRepo repo;
  late UpdateInterventionStatus usecase;

  setUpAll(() {
    // mocktail a besoin d'une valeur de repli pour any() sur un enum.
    registerFallbackValue(InterventionStatus.pending);
  });

  setUp(() {
    repo = MockRepo();
    usecase = UpdateInterventionStatus(repo);
  });

  test('autorise pending -> inProgress', () async {
    when(() => repo.getById('i1')).thenAnswer(
        (_) async => makeIntervention(status: InterventionStatus.pending));
    when(() => repo.updateStatus('i1', InterventionStatus.inProgress))
        .thenAnswer((_) async {});

    await usecase('i1', InterventionStatus.inProgress);

    verify(() => repo.updateStatus('i1', InterventionStatus.inProgress))
        .called(1);
  });

  test('refuse pending -> done (saut de statut)', () async {
    when(() => repo.getById('i1')).thenAnswer(
        (_) async => makeIntervention(status: InterventionStatus.pending));

    expect(() => usecase('i1', InterventionStatus.done), throwsStateError);
    verifyNever(() => repo.updateStatus(any(), any()));
  });
}
