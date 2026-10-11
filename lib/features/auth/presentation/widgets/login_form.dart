import 'package:flutter/material.dart';

/// Champs email et mot de passe, validation et message d'erreur.
class LoginForm extends StatefulWidget {
  final bool busy;
  final String? error;
  final void Function(String email, String password) onSubmit;

  const LoginForm({
    super.key,
    required this.busy,
    required this.error,
    required this.onSubmit,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email invalide' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Mot de passe', border: OutlineInputBorder()),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Mot de passe obligatoire' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 12),
            Text(widget.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.busy ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: widget.busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}
