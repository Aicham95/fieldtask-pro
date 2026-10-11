import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_circle_outlined, size: 56, color: color),
                  const SizedBox(height: 8),
                  Text('FieldTask Pro',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Text('Espace technicien'),
                  const SizedBox(height: 32),
                  LoginForm(
                    busy: auth.busy,
                    error: auth.error,
                    onSubmit: (e, p) =>
                        ref.read(authProvider.notifier).login(e, p),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Le token JWT est gardé en sécurité sur le téléphone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Compte de test : tech@techfix.com / 1234',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
