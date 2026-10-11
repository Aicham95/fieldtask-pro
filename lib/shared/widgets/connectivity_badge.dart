import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_provider.dart';
import '../../core/sync/sync_provider.dart';

/// Pastille En ligne / Hors ligne avec le nombre d'éléments en attente.
class ConnectivityBadge extends ConsumerWidget {
  const ConnectivityBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final color = online ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(online ? Icons.wifi : Icons.wifi_off, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          pending > 0
              ? '${online ? 'En ligne' : 'Hors ligne'} · $pending'
              : (online ? 'En ligne' : 'Hors ligne'),
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}
