import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../models/intervention_model.dart';

/// Appels REST vers le serveur (JSON-Server). Seul le téléchargement passe
/// par ici : les envois sont faits par SyncService, via la file d'attente.
class InterventionRemoteDataSource {
  final Dio _dio;

  InterventionRemoteDataSource(this._dio);

  Future<List<InterventionModel>> fetchForTechnician(String technicianId) async {
    try {
      final res = await _dio.get(
        ApiConstants.interventions,
        queryParameters: {'technicianId': technicianId},
      );
      return (res.data as List)
          .map((e) => InterventionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const NetworkFailure();
    }
  }
}
