import 'package:fieldtask_pro/features/auth/domain/entities/user.dart';
import 'package:fieldtask_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:fieldtask_pro/features/auth/domain/usecases/login_usecase.dart';
import 'package:fieldtask_pro/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  bool loggedOut = false;

  @override
  Future<User> login(String email, String password) async =>
      User(id: '1', name: 'Test', email: email, team: 'Équipe');

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  Future<User?> getSavedSession() async => null;
}

void main() {
  test('la déconnexion est refusée tant que des éléments attendent', () async {
    final repo = _FakeAuthRepository();
    var cleared = false;
    final logout = LogoutUseCase(repo, () async => 2, () async => cleared = true);

    await expectLater(logout(), throwsA(isA<StateError>()));
    expect(repo.loggedOut, false);
    expect(cleared, false);
  });

  test('la déconnexion efface la session et la base si la file est vide', () async {
    final repo = _FakeAuthRepository();
    var cleared = false;
    await LogoutUseCase(repo, () async => 0, () async => cleared = true)();

    expect(repo.loggedOut, true);
    expect(cleared, true);
  });

  test('la connexion refuse un email vide', () {
    expect(() => LoginUseCase(_FakeAuthRepository())('', '1234'),
        throwsA(isA<ArgumentError>()));
  });
}
