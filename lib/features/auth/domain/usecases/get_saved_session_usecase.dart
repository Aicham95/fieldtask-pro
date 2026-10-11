import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Au démarrage : retrouve la session pour passer l'écran de connexion.
class GetSavedSessionUseCase {
  final AuthRepository _repository;

  GetSavedSessionUseCase(this._repository);

  Future<User?> call() => _repository.getSavedSession();
}
