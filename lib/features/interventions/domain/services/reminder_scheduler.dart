/// Contrat du domaine pour programmer une notification.
/// Le domaine ne connaît pas le plugin : l'implémentation est dans la couche data.
abstract class ReminderScheduler {
  /// Programme une notification à [when] (heure locale).
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  });

  /// Affiche une notification tout de suite.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  });

  Future<void> cancel(int id);
}
