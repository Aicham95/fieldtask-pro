import 'dart:convert';

/// Représentation "à plat" d'une intervention, telle qu'elle est stockée
/// dans SQLite ou échangée avec l'API. Aucune logique métier ici.
/// priority : 0 normale, 1 élevée, 2 urgente
/// status   : 0 en attente, 1 en cours, 2 terminée
class InterventionModel {
  final String id;
  final String technicianId;
  final String reference;
  final String title;
  final String clientName;
  final String city;
  final String address;
  final String description;
  final String equipment;
  final String instructions;
  final int priority;
  final int status;
  final double latitude;
  final double longitude;
  final String scheduledAt;
  final int estimatedMinutes;
  final String notes;
  final List<String> photoPaths;
  final String? signaturePath;
  final String updatedAt;
  final bool synced;

  const InterventionModel({
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

  /// Lecture d'une ligne SQLite.
  factory InterventionModel.fromMap(Map<String, Object?> m) {
    return InterventionModel(
      id: m['id'] as String,
      technicianId: m['technician_id'] as String,
      reference: m['reference'] as String,
      title: m['title'] as String,
      clientName: m['client_name'] as String,
      city: m['city'] as String,
      address: m['address'] as String,
      description: m['description'] as String,
      equipment: m['equipment'] as String,
      instructions: m['instructions'] as String,
      priority: m['priority'] as int,
      status: m['status'] as int,
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      scheduledAt: m['scheduled_at'] as String,
      estimatedMinutes: m['estimated_minutes'] as int,
      notes: (m['notes'] as String?) ?? '',
      photoPaths: List<String>.from(
          jsonDecode((m['photo_paths'] as String?) ?? '[]') as List),
      signaturePath: m['signature_path'] as String?,
      updatedAt: m['updated_at'] as String,
      synced: (m['synced'] as int? ?? 1) == 1,
    );
  }

  /// Écriture dans SQLite.
  Map<String, Object?> toMap() => {
        'id': id,
        'technician_id': technicianId,
        'reference': reference,
        'title': title,
        'client_name': clientName,
        'city': city,
        'address': address,
        'description': description,
        'equipment': equipment,
        'instructions': instructions,
        'priority': priority,
        'status': status,
        'latitude': latitude,
        'longitude': longitude,
        'scheduled_at': scheduledAt,
        'estimated_minutes': estimatedMinutes,
        'notes': notes,
        'photo_paths': jsonEncode(photoPaths),
        'signature_path': signaturePath,
        'updated_at': updatedAt,
        'synced': synced ? 1 : 0,
      };

  /// Lecture d'un JSON de l'API (les chemins de photos/signature sont locaux
  /// au téléphone : le serveur peut ne pas les contenir).
  factory InterventionModel.fromJson(Map<String, dynamic> j) {
    return InterventionModel(
      id: j['id'].toString(),
      technicianId: j['technicianId'].toString(),
      reference: j['reference'] as String,
      title: j['title'] as String,
      clientName: j['clientName'] as String,
      city: j['city'] as String,
      address: j['address'] as String,
      description: j['description'] as String,
      equipment: j['equipment'] as String,
      instructions: (j['instructions'] as String?) ?? '',
      priority: j['priority'] as int,
      status: j['status'] as int,
      latitude: (j['latitude'] as num).toDouble(),
      longitude: (j['longitude'] as num).toDouble(),
      scheduledAt: j['scheduledAt'] as String,
      estimatedMinutes: j['estimatedMinutes'] as int,
      notes: (j['notes'] as String?) ?? '',
      photoPaths: List<String>.from((j['photoPaths'] as List?) ?? const []),
      signaturePath: j['signaturePath'] as String?,
      updatedAt: j['updatedAt'] as String,
    );
  }

  /// Corps envoyé à l'API (POST de création : objet complet).
  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'reference': reference,
        'title': title,
        'clientName': clientName,
        'city': city,
        'address': address,
        'description': description,
        'equipment': equipment,
        'instructions': instructions,
        'priority': priority,
        'status': status,
        'latitude': latitude,
        'longitude': longitude,
        'scheduledAt': scheduledAt,
        'estimatedMinutes': estimatedMinutes,
        'notes': notes,
        'photoPaths': photoPaths,
        'signaturePath': signaturePath,
        'updatedAt': updatedAt,
      };
}
