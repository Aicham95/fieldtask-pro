import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Base SQLite locale : source de vérité de l'UI (offline-first).
class AppDatabase {
  static const _name = 'fieldtask.db';
  static const _version = 1;

  static const tableInterventions = 'interventions';
  static const tableSyncQueue = 'sync_queue';

  Database? _db;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Émet à chaque écriture. Les flux de lecture (liste, compteur
  /// "n éléments en attente") se relancent à chaque émission.
  Stream<void> get changes => _changes.stream;

  void notifyChanged() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<Database> get database async {
    return _db ??= await openDatabase(
      join(await getDatabasesPath(), _name),
      version: _version,
      onCreate: _onCreate,
    );
  }

  /// Vide les données du technicien (interventions et file d'attente).
  /// À appeler à la déconnexion, seulement quand la file d'attente est vide,
  /// sinon des modifications pas encore envoyées seraient perdues.
  Future<void> clearUserData() async {
    final db = await database;
    await db.delete(tableInterventions);
    await db.delete(tableSyncQueue);
    notifyChanged();
  }

  Future<void> _onCreate(Database db, int version) async {
    // priority : 0 normale, 1 élevée, 2 urgente
    // status   : 0 en attente, 1 en cours, 2 terminée
    await db.execute('''
      CREATE TABLE $tableInterventions (
        id TEXT PRIMARY KEY,
        technician_id TEXT NOT NULL,
        reference TEXT NOT NULL,
        title TEXT NOT NULL,
        client_name TEXT NOT NULL,
        city TEXT NOT NULL,
        address TEXT NOT NULL,
        description TEXT NOT NULL,
        equipment TEXT NOT NULL,
        instructions TEXT NOT NULL,
        priority INTEGER NOT NULL,
        status INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        scheduled_at TEXT NOT NULL,
        estimated_minutes INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        photo_paths TEXT NOT NULL DEFAULT '[]',
        signature_path TEXT,
        updated_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // File d'attente : une ligne = une opération à rejouer sur le serveur.
    // operation : 'create' (POST) ou 'update' (PATCH)
    await db.execute('''
      CREATE TABLE $tableSyncQueue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
