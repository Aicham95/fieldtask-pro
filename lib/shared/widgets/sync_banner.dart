import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_provider.dart';
import '../../core/sync/sync_provider.dart';
import '../../core/sync/sync_service.dart';

/// Bandeau « Vous êtes hors connexion » ou « n éléments en attente »,
/// avec le bouton Synchroniser.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final syncing = ref.watch(syncStateProvider).value == SyncState.syncing;

    if (online && pending == 0) return const SizedBox.shrink();

    final text = online
        ? '$pending élément(s) en attente d\'envoi'
        : 'Vous êtes hors connexion. Vos modifications seront envoyées au retour du réseau.';

    return Material(
      color: online ? Colors.blue.shade50 : Colors.orange.shade100,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Icon(online ? Icons.sync : Icons.wifi_off, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
            if (online)
              TextButton(
                onPressed: syncing
                    ? null
                    : () => ref.read(syncServiceProvider).processQueue(),
                child: Text(syncing ? 'Envoi...' : 'Synchroniser'),
              ),
          ]),
        ),
      ),
    );
  }
}
