import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/field_providers.dart';
import '../../../../core/di/interventions_providers.dart';
import '../../domain/entities/intervention.dart';
import '../widgets/intervention_labels.dart';
import '../widgets/notes_field.dart';
import '../widgets/photo_section.dart';
import '../widgets/signature_pad.dart';

/// Fiche complète d'une intervention : détails, changement de statut,
/// photos, notes, signature du client.
class InterventionDetailPage extends ConsumerWidget {
  final String interventionId;

  const InterventionDetailPage({super.key, required this.interventionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(interventionProvider(interventionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche d\'intervention'),
        actions: [
          if (async.value != null)
            IconButton(
              tooltip: 'Me rappeler 30 min avant',
              icon: const Icon(Icons.notifications_active_outlined),
              onPressed: () => _remind(context, ref, async.value!),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (i) => i == null
            ? const Center(child: Text('Intervention introuvable'))
            : _Content(intervention: i),
      ),
    );
  }

  Future<void> _remind(
      BuildContext context, WidgetRef ref, Intervention i) async {
    final ok = await ref.read(scheduleReminderProvider)(i);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Rappel programmé 30 minutes avant l\'intervention.'
          : 'Impossible : l\'heure du rappel est passée.'),
    ));
  }
}

class _Content extends ConsumerWidget {
  final Intervention intervention;

  const _Content({required this.intervention});

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final i = intervention;
    final next = InterventionStatus.values[i.status.index + 1];
    final messenger = ScaffoldMessenger.of(context);

    if (next == InterventionStatus.done && i.signaturePath == null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('La signature du client est nécessaire pour terminer.')));
      return;
    }
    try {
      await ref.read(updateInterventionStatusProvider)(i.id, next);
      if (next == InterventionStatus.done) {
        await ref.read(reminderSchedulerProvider).showNow(
          id: i.id.hashCode & 0x7fffffff,
          title: 'Intervention terminée',
          body: '${i.reference} · ${i.clientName}',
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = intervention;
    final done = i.status == InterventionStatus.done;
    final save = ref.read(saveFieldWorkProvider);
    final button = nextStatusLabel(i.status);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(
            child: Text(i.reference,
                style: Theme.of(context).textTheme.labelLarge),
          ),
          _Chip(statusLabel(i.status), statusColor(i.status)),
          const SizedBox(width: 8),
          _Chip(priorityLabel(i.priority), priorityColor(i.priority)),
        ]),
        const SizedBox(height: 8),
        Text(i.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Row(children: [
          Icon(i.synced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 16, color: i.synced ? Colors.green : Colors.orange),
          const SizedBox(width: 4),
          Text(i.synced ? 'Synchronisée' : 'En attente de synchronisation'),
        ]),
        const SizedBox(height: 16),
        _Section('Client', [
          _Line(Icons.business_outlined, i.clientName),
          _Line(Icons.place_outlined, '${i.address}, ${i.city}'),
          _Line(Icons.schedule,
              '${DateFormat('dd/MM/yyyy HH:mm').format(i.scheduledAt.toLocal())} · ${i.estimatedMinutes} min'),
        ]),
        _Section('Problème signalé', [Text(i.description)]),
        _Section('Équipement', [_Line(Icons.build_outlined, i.equipment)]),
        if (i.instructions.isNotEmpty)
          _Section('Consignes d\'intervention', [Text(i.instructions)]),
        _Section('Photos', [
          PhotoSection(
            photoPaths: i.photoPaths,
            enabled: !done,
            onChanged: (paths) => save(i.id, photoPaths: paths),
          ),
        ]),
        _Section('Notes', [
          NotesField(
            key: ValueKey('notes-${i.id}'),
            initialValue: i.notes,
            enabled: !done,
            onSave: (n) => save(i.id, notes: n),
          ),
        ]),
        _Section('Signature du client', [
          SignaturePad(
            existingPath: i.signaturePath,
            enabled: !done,
            onSaved: (path) => save(i.id, signaturePath: path),
          ),
        ]),
        const SizedBox(height: 8),
        if (button != null)
          FilledButton(
            onPressed: () => _changeStatus(context, ref),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: Text(button),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Line(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(text)),
    ]),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600)),
  );
}