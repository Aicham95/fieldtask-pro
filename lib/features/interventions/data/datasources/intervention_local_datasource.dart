import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/intervention_model.dart';

/// Accès SQLite aux interventions. Chaque écriture "utilisateur" ajoute
/// aussi une ligne dans la file d'attente, dans la même transaction.
class InterventionLocalDataSource {
  final AppDatabase _appDb;

  InterventionLocalDataSource(this._appDb);

  static const _t = AppDatabase.tableInterventions;
  static const _q = AppDatabase.tableSyncQueue;

  Future<List<InterventionModel>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.query(_t);
    return rows.map(InterventionModel.fromMap).toList();
  }

  /// Flux qui ré-émet la liste à chaque changement de la base.
  Stream<List<InterventionModel>> watchAll() {
    late StreamController<List<InterventionModel>> controller;
    StreamSubscription<void>? sub;

    Future<void> emit() async {
      try {
        final list = await getAll();
        if (!controller.isClosed) controller.add(list);
      } catch (e, s) {
        if (!controller.isClosed) controller.addError(e, s);
      }
    }

    controller = StreamController<List<InterventionModel>>(
      onListen: () {
        emit();
        sub = _appDb.changes.listen((_) => emit());
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  Future<InterventionModel?> getById(String id) async {
    final db = await _appDb.database;
    final rows = await db.query(_t, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : InterventionModel.fromMap(rows.first);
  }

  /// Création : insertion locale (synced = 0) + POST en file d'attente.
  Future<void> insertWithQueue(InterventionModel model) async {
    final db = await _appDb.database;
    final local = _withSynced(model, false);
    await db.transaction((txn) async {
      await txn.insert(_t, local.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert(_q, {
        'entity_id': model.id,
        'operation': 'create',
        'payload': jsonEncode(model.toJson()),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'retry_count': 0,
      });
    });
    _appDb.notifyChanged();
  }

  /// Modification : colonnes locales (synced = 0) + PATCH en file d'attente.
  /// [changes] contient les colonnes SQLite ; [patch] le corps JSON envoyé.
  Future<void> updateWithQueue(
    String id, {
    required Map<String, Object?> changes,
    required Map<String, dynamic> patch,
  }) async {
    final db = await _appDb.database;
    await db.transaction((txn) async {
      await txn.update(_t, {...changes, 'synced': 0},
          where: 'id = ?', whereArgs: [id]);
      await txn.insert(_q, {
        'entity_id': id,
        'operation': 'update',
        'payload': jsonEncode(patch),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'retry_count': 0,
      });
    });
    _appDb.notifyChanged();
  }

  /// Applique la liste reçue du serveur pour ce technicien.
  /// - une ligne locale non envoyée (synced = 0) n'est jamais écrasée ;
  /// - une ligne déjà synchronisée est remplacée par la version serveur ;
  /// - une ligne synchronisée qui a disparu du serveur est supprimée.
  Future<void> applyServerList(
      String technicianId, List<InterventionModel> remote) async {
    final db = await _appDb.database;
    await db.transaction((txn) async {
      final unsynced = (await txn.query(_t,
              columns: ['id'], where: 'synced = 0'))
          .map((r) => r['id'] as String)
          .toSet();

      for (final m in remote) {
        if (unsynced.contains(m.id)) continue;
        await txn.insert(_t, _withSynced(m, true).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final remoteIds = remote.map((m) => m.id).toSet();
      final local = await txn.query(_t,
          columns: ['id'],
          where: 'technician_id = ? AND synced = 1',
          whereArgs: [technicianId]);
      for (final r in local) {
        final id = r['id'] as String;
        if (!remoteIds.contains(id)) {
          await txn.delete(_t, where: 'id = ?', whereArgs: [id]);
        }
      }
    });
    _appDb.notifyChanged();
  }

  InterventionModel _withSynced(InterventionModel m, bool synced) =>
      InterventionModel(
        id: m.id,
        technicianId: m.technicianId,
        reference: m.reference,
        title: m.title,
        clientName: m.clientName,
        city: m.city,
        address: m.address,
        description: m.description,
        equipment: m.equipment,
        instructions: m.instructions,
        priority: m.priority,
        status: m.status,
        latitude: m.latitude,
        longitude: m.longitude,
        scheduledAt: m.scheduledAt,
        estimatedMinutes: m.estimatedMinutes,
        notes: m.notes,
        photoPaths: m.photoPaths,
        signaturePath: m.signaturePath,
        updatedAt: m.updatedAt,
        synced: synced,
      );
}
