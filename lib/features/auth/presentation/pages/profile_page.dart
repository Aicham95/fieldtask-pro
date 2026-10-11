import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/sync_provider.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(authProvider.notifier).logout();
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final pending = ref.watch(pendingCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: CircleAvatar(radius: 36, child: Icon(Icons.person, size: 40))),
          const SizedBox(height: 16),
          Center(
              child: Text(user?.name ?? '',
                  style: Theme.of(context).textTheme.titleLarge)),
          Center(child: Text(user?.email ?? '')),
          const SizedBox(height: 4),
          Center(child: Text(user?.team ?? '')),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Éléments en attente d\'envoi'),
            trailing: Text('$pending'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
