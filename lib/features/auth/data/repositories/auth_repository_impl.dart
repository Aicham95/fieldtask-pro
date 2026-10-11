import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<User> login(String email, String password) async {
    final (user, token) = await _remote.login(email, password);
    await _local.saveSession(token, user);
    return user.toEntity();
  }

  @override
  Future<void> logout() => _local.clear();

  @override
  Future<User?> getSavedSession() async {
    final token = await _local.readToken();
    if (token == null) return null;
    return (await _local.readUser())?.toEntity();
  }
}
