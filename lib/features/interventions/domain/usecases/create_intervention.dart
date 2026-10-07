import '../entities/intervention.dart';
import '../repositories/intervention_repository.dart';

/// Crée une intervention depuis le formulaire (fonctionne hors ligne).
class CreateIntervention {
  final InterventionRepository _repository;

  CreateIntervention(this._repository);

  Future<void> call(Intervention intervention) {
    if (intervention.title.trim().isEmpty ||
        intervention.clientName.trim().isEmpty) {
      throw ArgumentError('Le titre et le client sont obligatoires.');
    }
    return _repository.create(intervention);
  }
}
