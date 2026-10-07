import '../../domain/entities/intervention.dart';
import '../models/intervention_model.dart';

/// Convertit entre le modèle de données (data) et l'entité (domain).
extension InterventionModelMapper on InterventionModel {
  Intervention toEntity() => Intervention(
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
        priority: InterventionPriority.values[priority.clamp(0, 2)],
        status: InterventionStatus.values[status.clamp(0, 2)],
        latitude: latitude,
        longitude: longitude,
        scheduledAt: DateTime.parse(scheduledAt),
        estimatedMinutes: estimatedMinutes,
        notes: notes,
        photoPaths: photoPaths,
        signaturePath: signaturePath,
        updatedAt: DateTime.parse(updatedAt),
        synced: synced,
      );
}

extension InterventionEntityMapper on Intervention {
  InterventionModel toModel() => InterventionModel(
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
        priority: priority.index,
        status: status.index,
        latitude: latitude,
        longitude: longitude,
        scheduledAt: scheduledAt.toUtc().toIso8601String(),
        estimatedMinutes: estimatedMinutes,
        notes: notes,
        photoPaths: photoPaths,
        signaturePath: signaturePath,
        updatedAt: updatedAt.toUtc().toIso8601String(),
        synced: synced,
      );
}
