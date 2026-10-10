import '../repositories/intervention_repository.dart';

/// Enregistre le travail fait sur le terrain : notes, photos, signature.
/// Fonctionne hors ligne (écrit en local puis file d'attente).
class SaveFieldWork {
  final InterventionRepository _repository;

  SaveFieldWork(this._repository);

  Future<void> call(
    String id, {
    String? notes,
    List<String>? photoPaths,
    String? signaturePath,
  }) async {
    if (await _repository.getById(id) == null) {
      throw ArgumentError('Intervention introuvable : $id');
    }
    await _repository.saveFieldWork(
      id,
      notes: notes,
      photoPaths: photoPaths,
      signaturePath: signaturePath,
    );
  }
}
