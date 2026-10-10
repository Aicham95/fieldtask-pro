import 'package:fieldtask_pro/features/interventions/domain/entities/intervention.dart';
import 'package:fieldtask_pro/features/interventions/domain/services/reminder_scheduler.dart';
import 'package:fieldtask_pro/features/interventions/domain/usecases/schedule_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/intervention_fixture.dart';

class _FakeScheduler implements ReminderScheduler {
  final List<DateTime> scheduled = [];

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async =>
      scheduled.add(when);

  @override
  Future<void> showNow(
      {required int id, required String title, required String body}) async {}

  @override
  Future<void> cancel(int id) async {}
}

void main() {
  final start = DateTime(2026, 10, 12, 9, 30);

  test('programme un rappel 30 minutes avant', () async {
    final scheduler = _FakeScheduler();
    final ok = await ScheduleReminder(scheduler)(
      makeIntervention(scheduledAt: start),
      now: DateTime(2026, 10, 12, 8),
    );

    expect(ok, true);
    expect(scheduler.scheduled.single, DateTime(2026, 10, 12, 9));
  });

  test('ne programme rien si l\'heure du rappel est passée', () async {
    final scheduler = _FakeScheduler();
    final ok = await ScheduleReminder(scheduler)(
      makeIntervention(scheduledAt: start),
      now: DateTime(2026, 10, 12, 9, 15),
    );

    expect(ok, false);
    expect(scheduler.scheduled, isEmpty);
  });

  test('ne programme rien pour une intervention terminée', () async {
    final scheduler = _FakeScheduler();
    final ok = await ScheduleReminder(scheduler)(
      makeIntervention(scheduledAt: start, status: InterventionStatus.done),
      now: DateTime(2026, 10, 12, 8),
    );

    expect(ok, false);
  });
}
