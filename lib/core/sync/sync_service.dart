import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';

/// État affiché par le badge réseau et le bouton "Synchroniser".
enum SyncState { idle, syncing, error }

/// Moteur de synchronisation : rejoue la file d'attente locale
/// dès que la connexion revient.
class SyncService {
  final AppDatabase _appDb;
  final Dio _dio;
  final Connectivity _connectivity;
  final StreamController<SyncState> _stateController =
      StreamController<SyncState>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _running = false;

  SyncService(this._appDb, this._dio, this._connectivity);

  Stream<SyncState> get stateStream => _stateController.stream;

  void start() {
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      if (_isOnline(results)) processQueue();
    });
    processQueue();
  }

  void dispose() {
    _sub?.cancel();
    _stateController.close();
  }

  bool _isOnline(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);

  /// Nombre d'éléments en attente ("3 éléments en attente" sur la maquette).
  Future<int> pendingCount() async {
    final db = await _appDb.database;
    final rows = await db
        .rawQuery('SELECT COUNT(*) FROM ${AppDatabase.tableSyncQueue}');
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// Envoie les opérations dans l'ordre. S'arrête à la première erreur
  /// réseau pour conserver l'ordre et réessayer plus tard.
  /// Appelée automatiquement au retour du réseau et par le bouton
  /// "Synchroniser".
  Future<void> processQueue() async {
    if (_running) return;
    _running = true;
    _stateController.add(SyncState.syncing);
    var failed = false;
    try {
      final db = await _appDb.database;
      final rows = await db.query(AppDatabase.tableSyncQueue, orderBy: 'id ASC');
      for (final row in rows) {
        final id = row['id'] as int;
        final entityId = row['entity_id'] as String;
        final payload = jsonDecode(row['payload'] as String);
        try {
          // 'create' -> POST, 'update' -> PATCH (statuts, notes, photos...).
          if (row['operation'] == 'create') {
            await _dio.post('/interventions', data: payload);
          } else {
            await _dio.patch('/interventions/$entityId', data: payload);
          }
          await db.delete(AppDatabase.tableSyncQueue,
              where: 'id = ?', whereArgs: [id]);

          // L'intervention n'est marquée "envoyée" que si plus aucune
          // opération ne l'attend dans la file.
          final remaining = Sqflite.firstIntValue(await db.rawQuery(
                  'SELECT COUNT(*) FROM ${AppDatabase.tableSyncQueue} WHERE entity_id = ?',
                  [entityId])) ??
              0;
          if (remaining == 0) {
            await db.update(AppDatabase.tableInterventions, {'synced': 1},
                where: 'id = ?', whereArgs: [entityId]);
          }
          _appDb.notifyChanged();
        } on DioException {
          await db.rawUpdate(
              'UPDATE ${AppDatabase.tableSyncQueue} SET retry_count = retry_count + 1 WHERE id = ?',
              [id]);
          failed = true;
          break;
        }
      }
    } finally {
      _running = false;
      if (!_stateController.isClosed) {
        _stateController.add(failed ? SyncState.error : SyncState.idle);
      }
    }
  }
}
