import 'package:equatable/equatable.dart';

import '../entities/intervention.dart';
import '../repositories/intervention_repository.dart';

/// Chiffres affichés sur le tableau de bord, calculés depuis la base locale.
class DashboardStats extends Equatable {
  /// Interventions en attente ("à faire").
  final int toDo;
  final int inProgress;
  final int done;

  /// Interventions non terminées de priorité élevée ou urgente.
  final int priority;

  /// Parmi elles, celles qui sont urgentes.
  final int urgent;

  /// Interventions prévues aujourd'hui et leur durée cumulée ("Votre journée").
  final int plannedToday;
  final int plannedMinutesToday;

  const DashboardStats({
    required this.toDo,
    required this.inProgress,
    required this.done,
    required this.priority,
    required this.urgent,
    required this.plannedToday,
    required this.plannedMinutesToday,
  });

  @override
  List<Object?> get props => [
        toDo,
        inProgress,
        done,
        priority,
        urgent,
        plannedToday,
        plannedMinutesToday,
      ];
}

class GetDashboardStats {
  final InterventionRepository _repository;

  GetDashboardStats(this._repository);

  /// [now] sert uniquement à rendre le calcul testable.
  Stream<DashboardStats> call({DateTime? now}) {
    final today = now ?? DateTime.now();
    bool isToday(DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day;

    return _repository.watchAll().map((list) {
      final open = list.where((i) => i.status != InterventionStatus.done);
      final planned = list.where((i) => isToday(i.scheduledAt)).toList();

      return DashboardStats(
        toDo: list.where((i) => i.status == InterventionStatus.pending).length,
        inProgress:
            list.where((i) => i.status == InterventionStatus.inProgress).length,
        done: list.where((i) => i.status == InterventionStatus.done).length,
        priority: open
            .where((i) => i.priority != InterventionPriority.normal)
            .length,
        urgent:
            open.where((i) => i.priority == InterventionPriority.urgent).length,
        plannedToday: planned.length,
        plannedMinutesToday:
            planned.fold<int>(0, (sum, i) => sum + i.estimatedMinutes),
      );
    });
  }
}
