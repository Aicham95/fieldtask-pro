import 'dart:async';

import '../../domain/entities/intervention.dart';
import '../../domain/repositories/intervention_repository.dart';
import 'seed_interventions.dart';

/// Dépôt factice, en mémoire, sans SQLite ni réseau.
/// Sert aux Lots 1 et 3 tant que le vrai dépôt n'est pas branché
/// (voir `useFakeRepository` dans core/di/interventions_providers.dart).
class FakeInterventionRepository implements InterventionRepository {
  final List<Intervention> _all;
  final StreamController<void> _changed = StreamController<void>.broadcast();
  String _technicianId = '1';

  FakeInterventionRepository({List<Intervention>? initial})
      : _all = List.of(initial ?? seedInterventions());

  List<Intervention> get _visible =>
      _all.where((i) => i.technicianId == _technicianId).toList();

  @override
  Stream<List<Intervention>> watchAll() async* {
    yield _visible;
    await for (final _ in _changed.stream) {
      yield _visible;
    }
  }

  @override
  Future<Intervention?> getById(String id) async {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  @override
  Future<void> refreshFromServer(String technicianId) async {
    _technicianId = technicianId;
    _changed.add(null);
  }

  @override
  Future<void> create(Intervention intervention) async {
    _all.add(intervention.copyWith(synced: false));
    _changed.add(null);
  }

  @override
  Future<void> updateStatus(String id, InterventionStatus status) async {
    _replace(id, (i) => i.copyWith(
        status: status, updatedAt: DateTime.now(), synced: false));
  }

  @override
  Future<void> saveFieldWork(
    String id, {
    String? notes,
    List<String>? photoPaths,
    String? signaturePath,
  }) async {
    _replace(id, (i) => i.copyWith(
        notes: notes,
        photoPaths: photoPaths,
        signaturePath: signaturePath,
        updatedAt: DateTime.now(),
        synced: false));
  }

  void _replace(String id, Intervention Function(Intervention) f) {
    final index = _all.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _all[index] = f(_all[index]);
    _changed.add(null);
  }
}
