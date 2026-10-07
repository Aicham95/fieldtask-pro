import '../entities/intervention.dart';

/// Contrat du domaine. L'implementation (couche data) lit et ecrit toujours
/// en base locale d'abord, puis delegue la synchro a la file d'attente.
abstract class InterventionRepository {
  /// Flux des interventions locales (l'UI ne depend jamais du reseau).
  Stream<List<Intervention>> watchAll();

  Future<Intervention?> getById(String id);

  /// Telecharge depuis le serveur les interventions assignees a ce technicien
  /// (GET /interventions?technicianId=...) et met a jour la base locale.
  Future<void> refreshFromServer(String technicianId);

  /// Creation hors-ligne : ecrite en local puis ajoutee a la file (POST).
  Future<void> create(Intervention intervention);

  Future<void> updateStatus(String id, InterventionStatus status);

  Future<void> saveFieldWork(
    String id, {
    String? notes,
    List<String>? photoPaths,
    String? signaturePath,
  });
}
