import 'package:flutter/material.dart';

/// Zone de notes explicatives. Le bouton enregistre via [onSave].
class NotesField extends StatefulWidget {
  final String initialValue;
  final bool enabled;
  final Future<void> Function(String notes) onSave;

  const NotesField({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.enabled = true,
  });

  @override
  State<NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<NotesField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.onSave(_controller.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Notes enregistrées')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Ce qui a été fait, pièces changées, remarques...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: widget.enabled ? _save : null,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer les notes'),
          ),
        ),
      ],
    );
  }
}
