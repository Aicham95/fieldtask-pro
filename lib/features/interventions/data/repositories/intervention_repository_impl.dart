import 'dart:convert';

import '../../domain/entities/intervention.dart';
import '../../domain/repositories/intervention_repository.dart';
import '../datasources/intervention_local_datasource.dart';
import '../datasources/intervention_remote_datasource.dart';
import '../mappers/intervention_mapper.dart';

/// Implémentation réelle : SQLite d'abord, serveur ensuite (via la file).
class InterventionRepositoryImpl implements InterventionRepository {
  final InterventionLocalDataSource _local;
  final InterventionRemoteDataSource _remote;

  /// Appelé après chaque écriture pour tenter un envoi immédiat.
  final void Function() _requestSync;

  InterventionRepositoryImpl(this._local, this._remote, this._requestSync);

  @override
  Stream<List<Intervention>> watchAll() => _local
      .watchAll()
      .map((list) => list.map((m) => m.toEntity()).toList());

  @override
  Future<Intervention?> getById(String id) async =>
      (await _local.getById(id))?.toEntity();

  @override
  Future<void> refreshFromServer(String technicianId) async {
    final remote = await _remote.fetchForTechnician(technicianId);
    await _local.applyServerList(technicianId, remote);
  }

  @override
  Future<void> create(Intervention intervention) async {
    await _local.insertWithQueue(intervention.toModel());
    _requestSync();
  }

  @override
  Future<void> updateStatus(String id, InterventionStatus status) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _local.updateWithQueue(
      id,
      changes: {'status': status.index, 'updated_at': now},
      patch: {'status': status.index, 'updatedAt': now},
    );
    _requestSync();
  }

  @override
  Future<void> saveFieldWork(
    String id, {
    String? notes,
    List<String>? photoPaths,
    String? signaturePath,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final changes = <String, Object?>{'updated_at': now};
    final patch = <String, dynamic>{'updatedAt': now};
    if (notes != null) {
      changes['notes'] = notes;
      patch['notes'] = notes;
    }
    if (photoPaths != null) {
      // Les chemins de photos restent sur le téléphone ; le serveur reçoit
      // la liste telle quelle (l'envoi des fichiers est hors périmètre).
      changes['photo_paths'] = jsonEncode(photoPaths);
      patch['photoPaths'] = photoPaths;
    }
    if (signaturePath != null) {
      changes['signature_path'] = signaturePath;
      patch['signaturePath'] = signaturePath;
    }
    await _local.updateWithQueue(id, changes: changes, patch: patch);
    _requestSync();
  }
}
