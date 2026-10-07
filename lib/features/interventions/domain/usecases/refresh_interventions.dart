import '../repositories/intervention_repository.dart';

/// Télécharge les interventions du technicien (tirer pour rafraîchir,
/// et juste après la connexion).
class RefreshInterventions {
  final InterventionRepository _repository;

  RefreshInterventions(this._repository);

  Future<void> call(String technicianId) =>
      _repository.refreshFromServer(technicianId);
}
