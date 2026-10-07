import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

/// Client HTTP partagé par les sources distantes et par SyncService.
///
/// Version de départ. Lot 1 : ajouter ici un intercepteur qui lit le token
/// JWT (flutter_secure_storage) et envoie `Authorization: Bearer <token>`.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      // Délais courts : hors ligne, on veut échouer vite et réessayer plus tard.
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Content-Type': 'application/json'},
    ),
  );
});
