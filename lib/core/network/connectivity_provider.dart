import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

/// true = en ligne, false = hors ligne. Alimente l'indicateur de l'UI.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final c = ref.watch(connectivityProvider);
  bool online(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);
  yield online(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(online);
});
