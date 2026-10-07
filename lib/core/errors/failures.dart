/// Erreurs métier. Les couches data les lancent à la place des exceptions
/// techniques (Dio, SQLite), pour que l'écran affiche un message clair.
sealed class Failure implements Exception {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Réseau indisponible. Réessayez plus tard.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Erreur de stockage sur le téléphone.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Email ou mot de passe incorrect.']);
}
