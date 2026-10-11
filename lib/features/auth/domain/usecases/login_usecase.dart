import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Email et mot de passe obligatoires.');
    }
    return _repository.login(email.trim(), password);
  }
}
