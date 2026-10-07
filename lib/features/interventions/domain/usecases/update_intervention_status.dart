import '../entities/intervention.dart';
import '../repositories/intervention_repository.dart';

class UpdateInterventionStatus {
  final InterventionRepository _repository;

  UpdateInterventionStatus(this._repository);

  /// Regle metier : pending -> inProgress -> done, sans retour en arriere.
  Future<void> call(String id, InterventionStatus next) async {
    final current = await _repository.getById(id);
    if (current == null) {
      throw ArgumentError('Intervention introuvable : $id');
    }
    if (next.index != current.status.index + 1) {
      throw StateError('Transition de statut non autorisee');
    }
    await _repository.updateStatus(id, next);
  }
}
