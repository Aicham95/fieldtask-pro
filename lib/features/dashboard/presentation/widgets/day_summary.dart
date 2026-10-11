import 'package:flutter/material.dart';

/// « Votre journée » : nombre d'interventions du jour et durée sur le terrain.
class DaySummary extends StatelessWidget {
  final int planned;
  final int minutes;

  const DaySummary({super.key, required this.planned, required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60, m = minutes % 60;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.today),
        title: const Text('Votre journée'),
        subtitle: Text(
            '$planned intervention(s) prévue(s) · ${h}h${m.toString().padLeft(2, '0')} sur le terrain'),
      ),
    );
  }
}
