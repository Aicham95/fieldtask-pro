import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';
import 'package:fieldtask_pro/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:fieldtask_pro/features/interventions/domain/usecases/get_dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/intervention_fixture.dart';

class MockRepo extends Mock implements InterventionRepository {}

void main() {
  test('compte les statuts, les prioritaires et la durée du jour', () async {
    final repo = MockRepo();
    final today = DateTime(2026, 10, 6, 8);

    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([
          makeIntervention(
            id: 'a',
            status: InterventionStatus.pending,
            priority: InterventionPriority.high,
            scheduledAt: DateTime(2026, 10, 6, 9, 30),
            estimatedMinutes: 90,
          ),
          makeIntervention(
            id: 'b',
            status: InterventionStatus.pending,
            priority: InterventionPriority.urgent,
            scheduledAt: DateTime(2026, 10, 6, 11, 30),
            estimatedMinutes: 60,
          ),
          makeIntervention(
            id: 'c',
            status: InterventionStatus.inProgress,
            scheduledAt: DateTime(2026, 10, 7, 14),
          ),
          makeIntervention(
            id: 'd',
            status: InterventionStatus.done,
            priority: InterventionPriority.urgent,
            scheduledAt: DateTime(2026, 10, 5, 8),
          ),
        ]));

    final stats = await GetDashboardStats(repo)(now: today).first;

    expect(stats.toDo, 2);
    expect(stats.inProgress, 1);
    expect(stats.done, 1);
    // 'd' est urgente mais terminée : elle n'est pas comptée.
    expect(stats.priority, 2);
    expect(stats.urgent, 1);
    expect(stats.plannedToday, 2);
    expect(stats.plannedMinutesToday, 150);
  });
}
