import 'package:equatable/equatable.dart';

/// Cycle de vie d'une intervention : en attente -> en cours -> terminée.
enum InterventionStatus { pending, inProgress, done }

/// Trois niveaux, comme sur la maquette : Normale, Élevée, Urgente.
enum InterventionPriority { normal, high, urgent }

class Intervention extends Equatable {
  /// Identifiant unique. Pour une création faite dans l'app, il est généré
  /// sur le téléphone, ce qui permet de créer sans attendre le serveur.
  final String id;

  /// Technicien à qui l'intervention est assignée. L'app n'affiche que les
  /// interventions du technicien connecté.
  final String technicianId;

  /// Référence lisible affichée à l'écran, ex : INT-2026-084.
  final String reference;
  final String title;
  final String clientName;
  final String city;
  final String address;

  /// Description du problème (exigée par le sujet).
  final String description;

  /// Équipement concerné (exigé par le sujet).
  final String equipment;

  /// "Consignes d'intervention" affichées dans la fiche.
  final String instructions;
  final InterventionPriority priority;
  final InterventionStatus status;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final int estimatedMinutes;
  final String notes;
  final List<String> photoPaths;
  final String? signaturePath;
  final DateTime updatedAt;

  /// false = modification locale pas encore envoyée au serveur.
  final bool synced;

  const Intervention({
    required this.id,
    required this.technicianId,
    required this.reference,
    required this.title,
    required this.clientName,
    required this.city,
    required this.address,
    required this.description,
    required this.equipment,
    required this.instructions,
    required this.priority,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.estimatedMinutes,
    required this.updatedAt,
    this.notes = '',
    this.photoPaths = const [],
    this.signaturePath,
    this.synced = true,
  });

  Intervention copyWith({
    InterventionStatus? status,
    String? notes,
    List<String>? photoPaths,
    String? signaturePath,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Intervention(
      id: id,
      technicianId: technicianId,
      reference: reference,
      title: title,
      clientName: clientName,
      city: city,
      address: address,
      description: description,
      equipment: equipment,
      instructions: instructions,
      priority: priority,
      status: status ?? this.status,
      latitude: latitude,
      longitude: longitude,
      scheduledAt: scheduledAt,
      estimatedMinutes: estimatedMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
      signaturePath: signaturePath ?? this.signaturePath,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        technicianId,
        reference,
        title,
        clientName,
        city,
        address,
        description,
        equipment,
        instructions,
        priority,
        status,
        latitude,
        longitude,
        scheduledAt,
        estimatedMinutes,
        notes,
        photoPaths,
        signaturePath,
        updatedAt,
        synced,
      ];
}
