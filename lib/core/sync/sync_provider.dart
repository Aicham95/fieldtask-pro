import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../network/connectivity_provider.dart';
import '../network/dio_client.dart';
import 'sync_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Moteur de synchro. Lot 1 : faire `ref.watch(syncServiceProvider)` une fois
/// au démarrage (après la connexion) pour activer la synchro automatique.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(dioProvider),
    ref.watch(connectivityProvider),
  )..start();
  ref.onDispose(service.dispose);
  return service;
});

/// idle / syncing / error, pour le badge et le bouton "Synchroniser".
final syncStateProvider = StreamProvider<SyncState>(
  (ref) => ref.watch(syncServiceProvider).stateStream,
);

/// Nombre d'éléments en attente, mis à jour à chaque écriture en base.
final pendingCountProvider = StreamProvider<int>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final sync = ref.watch(syncServiceProvider);
  yield await sync.pendingCount();
  await for (final _ in db.changes) {
    yield await sync.pendingCount();
  }
});
