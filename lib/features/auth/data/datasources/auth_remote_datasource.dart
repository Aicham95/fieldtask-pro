import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

/// Connexion auprès de l'API de test : cherche l'utilisateur par email et
/// mot de passe. Le comptes sont créés côté serveur (db.json), pas dans l'app.
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<(UserModel, String)> login(String email, String password) async {
    final List data;
    try {
      final res = await _dio.get(
        ApiConstants.users,
        queryParameters: {'email': email, 'password': password},
      );
      data = res.data as List;
    } on DioException {
      throw const NetworkFailure(
          'Serveur injoignable. Vérifiez la connexion et que JSON-Server est lancé.');
    }
    if (data.isEmpty) throw const AuthFailure();
    final user = UserModel.fromJson(data.first as Map<String, dynamic>);
    return (user, _simulatedJwt(user));
  }

  /// JWT simulé (en-tête.contenu.signature en base64) : JSON-Server n'en
  /// délivre pas. Un vrai serveur renverrait un token signé.
  String _simulatedJwt(UserModel u) {
    String enc(Map<String, dynamic> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    final exp =
        DateTime.now().add(const Duration(hours: 12)).millisecondsSinceEpoch ~/ 1000;
    return '${enc({'alg': 'none', 'typ': 'JWT'})}.${enc({'sub': u.id, 'email': u.email, 'exp': exp})}.simulated';
  }
}
