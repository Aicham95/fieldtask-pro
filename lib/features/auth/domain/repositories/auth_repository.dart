import '../entities/user.dart';

abstract class AuthRepository {
  /// Vérifie les identifiants auprès du serveur et enregistre la session.
  Future<User> login(String email, String password);

  /// Efface la session (token et utilisateur).
  Future<void> logout();

  /// Session enregistrée sur le téléphone, ou null (fonctionne hors ligne).
  Future<User?> getSavedSession();
}
