import '../repositories/auth_repository.dart';

/// Déconnexion. Refusée tant que des modifications attendent d'être envoyées,
/// sinon elles seraient perdues avec la base locale.
class LogoutUseCase {
  final AuthRepository _repository;
  final Future<int> Function() _pendingCount;
  final Future<void> Function() _clearLocalData;

  LogoutUseCase(this._repository, this._pendingCount, this._clearLocalData);

  Future<void> call() async {
    final pending = await _pendingCount();
    if (pending > 0) {
      throw StateError(
          '$pending élément(s) en attente d\'envoi. Reconnectez-vous au réseau et synchronisez avant de vous déconnecter.');
    }
    await _repository.logout();
    await _clearLocalData();
  }
}
