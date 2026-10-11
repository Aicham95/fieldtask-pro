import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/interventions_providers.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/intervention.dart';
import '../widgets/intervention_labels.dart';

/// Formulaire de création d'une intervention. Fonctionne hors ligne :
/// l'intervention est écrite dans SQLite puis envoyée plus tard.
///
/// [technicianId] = identifiant du technicien connecté (fourni par le Lot 1).
class CreateInterventionPage extends ConsumerStatefulWidget {
  final String technicianId;

  const CreateInterventionPage({super.key, required this.technicianId});

  @override
  ConsumerState<CreateInterventionPage> createState() =>
      _CreateInterventionPageState();
}

class _CreateInterventionPageState
    extends ConsumerState<CreateInterventionPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _client = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController(text: 'Saint-Louis');
  final _description = TextEditingController();
  final _equipment = TextEditingController();
  final _minutes = TextEditingController(text: '60');

  InterventionPriority _priority = InterventionPriority.normal;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _title, _client, _address, _city, _description, _equipment, _minutes
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() => _scheduledAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final now = DateTime.now();
      final intervention = Intervention(
        id: generateId(),
        technicianId: widget.technicianId,
        reference:
            'INT-${now.year}-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
        title: _title.text.trim(),
        clientName: _client.text.trim(),
        city: _city.text.trim(),
        address: _address.text.trim(),
        description: _description.text.trim(),
        equipment: _equipment.text.trim(),
        instructions: '',
        priority: _priority,
        status: InterventionStatus.pending,
        // Coordonnées par défaut (centre de Saint-Louis) : le formulaire
        // ne propose pas de géocodage d'adresse.
        latitude: 16.0326,
        longitude: -16.4818,
        scheduledAt: _scheduledAt,
        estimatedMinutes: int.parse(_minutes.text.trim()),
        updatedAt: now,
      );
      await ref.read(createInterventionProvider)(intervention);
      messenger.showSnackBar(const SnackBar(
          content: Text('Intervention enregistrée. Elle sera envoyée dès que le réseau sera disponible.')));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur : $e')));
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle intervention')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_title, 'Titre', validator: _required),
            _field(_client, 'Client', validator: _required),
            _field(_address, 'Adresse', validator: _required),
            _field(_city, 'Ville', validator: _required),
            _field(_equipment, 'Équipement', validator: _required),
            _field(_description, 'Description du problème',
                lines: 3, validator: _required),
            const SizedBox(height: 8),
            Text('Priorité', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<InterventionPriority>(
              segments: [
                for (final p in InterventionPriority.values)
                  ButtonSegment(value: p, label: Text(priorityLabel(p))),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.event),
              label: Text(
                  'Prévue le ${DateFormat('dd/MM/yyyy à HH:mm').format(_scheduledAt)}'),
            ),
            const SizedBox(height: 16),
            _field(_minutes, 'Durée estimée (minutes)',
                keyboard: TextInputType.number, validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              return (n == null || n <= 0) ? 'Nombre de minutes invalide' : null;
            }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    int lines = 1,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          validator: validator,
          minLines: lines,
          maxLines: lines,
          keyboardType: keyboard,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
        ),
      );
}
