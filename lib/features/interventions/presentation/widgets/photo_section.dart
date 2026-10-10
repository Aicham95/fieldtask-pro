import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Bouton "ajouter une photo" (appareil photo ou galerie) et miniatures.
/// Les fichiers sont copiés dans le dossier de l'app : le cache de la caméra
/// peut être vidé par Android.
class PhotoSection extends StatelessWidget {
  final List<String> photoPaths;
  final bool enabled;
  final Future<void> Function(List<String> newPaths) onChanged;

  const PhotoSection({
    super.key,
    required this.photoPaths,
    required this.onChanged,
    this.enabled = true,
  });

  Future<void> _add(BuildContext context, ImageSource source) async {
    final picked =
    await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final name = 'photo_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy(p.join(dir.path, name));
    await onChanged([...photoPaths, saved.path]);
  }

  void _chooseSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Prendre une photo'),
            onTap: () {
              Navigator.pop(sheet);
              _add(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choisir dans la galerie'),
            onTap: () {
              Navigator.pop(sheet);
              _add(context, ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photoPaths.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Aucune photo pour le moment.'),
          )
        else
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoPaths.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(photoPaths[i]),
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 88,
                    height: 88,
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: enabled ? () => _chooseSource(context) : null,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Ajouter une photo'),
        ),
      ],
    );
  }
}