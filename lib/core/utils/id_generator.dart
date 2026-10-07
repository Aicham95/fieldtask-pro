import 'dart:math';

final Random _random = Random();

/// Identifiant généré sur le téléphone pour une intervention créée hors ligne.
/// Le serveur n'a pas à attribuer d'identifiant : la création peut donc être
/// enregistrée tout de suite, puis envoyée plus tard.
String generateId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final noise = _random.nextInt(1 << 32).toRadixString(36);
  return 'i$time$noise';
}
