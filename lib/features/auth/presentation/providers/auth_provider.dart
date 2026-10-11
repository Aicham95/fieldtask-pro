import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/auth_providers.dart';
import '../../../../core/di/interventions_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool busy;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.busy = false,
  });
}

/// État de connexion exposé aux écrans et au routeur.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restore);
    return const AuthState();
  }

  Future<void> _restore() async {
    try {
      final user = await ref.read(getSavedSessionUseCaseProvider)();
      if (user == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _refresh(user.id);
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.unauthenticated, busy: true);
    try {
      final user = await ref.read(loginUseCaseProvider)(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _refresh(user.id);
    } on Failure catch (f) {
      state = AuthState(status: AuthStatus.unauthenticated, error: f.message);
    } on ArgumentError catch (e) {
      state = AuthState(
          status: AuthStatus.unauthenticated, error: e.message.toString());
    } catch (_) {
      state = const AuthState(
          status: AuthStatus.unauthenticated, error: 'Erreur inattendue.');
    }
  }

  /// Retourne null si la déconnexion a eu lieu, sinon le message de refus.
  Future<String?> logout() async {
    try {
      await ref.read(logoutUseCaseProvider)();
      state = const AuthState(status: AuthStatus.unauthenticated);
      return null;
    } on StateError catch (e) {
      return e.message;
    } catch (_) {
      return 'Déconnexion impossible.';
    }
  }

  /// Télécharge les interventions du technicien. Hors ligne : on garde la
  /// base locale, sans erreur pour l'utilisateur.
  Future<void> _refresh(String technicianId) async {
    try {
      await ref.read(refreshInterventionsProvider)(technicianId);
    } catch (_) {}
  }

  Future<void> refreshInterventions() async {
    final user = state.user;
    if (user != null) {
      await ref.read(refreshInterventionsProvider)(user.id);
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
