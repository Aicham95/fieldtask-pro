import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_saved_session_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../network/dio_client.dart';
import '../sync/sync_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(
        AuthRemoteDataSource(ref.watch(dioProvider)), AuthLocalDataSource()));

final loginUseCaseProvider =
    Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));

final getSavedSessionUseCaseProvider = Provider(
    (ref) => GetSavedSessionUseCase(ref.watch(authRepositoryProvider)));

final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(
      ref.watch(authRepositoryProvider),
      () => ref.read(syncServiceProvider).pendingCount(),
      () => ref.read(appDatabaseProvider).clearUserData(),
    ));
