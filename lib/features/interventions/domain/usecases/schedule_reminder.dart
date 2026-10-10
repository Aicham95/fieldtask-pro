import '../entities/intervention.dart';
import '../services/reminder_scheduler.dart';

/// Programme un rappel avant l'heure prévue d'une intervention.
class ScheduleReminder {
  final ReminderScheduler _scheduler;

  ScheduleReminder(this._scheduler);

  /// Retourne true si un rappel a été programmé, false si l'heure du rappel
  /// est déjà passée ou si l'intervention est terminée.
  Future<bool> call(
    Intervention intervention, {
    Duration before = const Duration(minutes: 30),
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final when = intervention.scheduledAt.subtract(before);
    if (intervention.status == InterventionStatus.done ||
        !when.isAfter(current)) {
      return false;
    }
    await _scheduler.schedule(
      id: intervention.id.hashCode & 0x7fffffff,
      title: 'Intervention dans ${before.inMinutes} min',
      body: '${intervention.clientName} · ${intervention.title}',
      when: when,
    );
    return true;
  }
}
