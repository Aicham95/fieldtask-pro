import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

/// Zone de dessin de la signature du client, exportée en PNG.
/// Si une signature existe déjà, elle est affichée à la place du pad.
class SignaturePad extends StatefulWidget {
  final String? existingPath;
  final bool enabled;
  final Future<void> Function(String path) onSaved;

  const SignaturePad({
    super.key,
    required this.existingPath,
    required this.onSaved,
    this.enabled = true,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le client doit signer d\'abord.')));
      return;
    }
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(
        dir.path, 'signature_${DateTime.now().microsecondsSinceEpoch}.png'));
    await file.writeAsBytes(bytes);
    await widget.onSaved(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingPath;
    if (existing != null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.file(
          File(existing),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
          const Center(child: Text('Signature enregistrée')),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Signature(
              controller: _controller,
              height: 160,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.enabled ? _controller.clear : null,
              child: const Text('Effacer'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: widget.enabled ? _save : null,
              icon: const Icon(Icons.check),
              label: const Text('Valider la signature'),
            ),
          ],
        ),
      ],
    );
  }
}