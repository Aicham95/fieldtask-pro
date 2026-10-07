import '../entities/intervention.dart';
import '../repositories/intervention_repository.dart';

enum InterventionSort { priority, date }

class GetInterventions {
  final InterventionRepository _repository;

  GetInterventions(this._repository);

  /// Filtre par statut, recherche texte, tri par priorité (urgente d'abord)
  /// ou par date prévue.
  Stream<List<Intervention>> call({
    InterventionStatus? status,
    String query = '',
    InterventionSort sort = InterventionSort.priority,
  }) {
    final q = query.trim().toLowerCase();
    return _repository.watchAll().map((list) {
      final result = list.where((i) {
        final okStatus = status == null || i.status == status;
        final okQuery = q.isEmpty ||
            i.reference.toLowerCase().contains(q) ||
            i.title.toLowerCase().contains(q) ||
            i.clientName.toLowerCase().contains(q) ||
            i.address.toLowerCase().contains(q) ||
            i.equipment.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q);
        return okStatus && okQuery;
      }).toList();

      result.sort((a, b) {
        if (sort == InterventionSort.priority) {
          final byPriority = b.priority.index.compareTo(a.priority.index);
          if (byPriority != 0) return byPriority;
        }
        return a.scheduledAt.compareTo(b.scheduledAt);
      });
      return result;
    });
  }
}
