import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/interventions/data/datasources/intervention_local_datasource.dart';
import '../../features/interventions/data/datasources/intervention_remote_datasource.dart';
import '../../features/interventions/data/repositories/fake_intervention_repository.dart';
import '../../features/interventions/data/repositories/intervention_repository_impl.dart';
import '../../features/interventions/domain/entities/intervention.dart';
import '../../features/interventions/domain/repositories/intervention_repository.dart';
import '../../features/interventions/domain/usecases/create_intervention.dart';
import '../../features/interventions/domain/usecases/get_dashboard_stats.dart';
import '../../features/interventions/domain/usecases/get_interventions.dart';
import '../../features/interventions/domain/usecases/refresh_interventions.dart';
import '../../features/interventions/domain/usecases/update_intervention_status.dart';
import '../network/dio_client.dart';
import '../sync/sync_provider.dart';

/// true  = dépôt factice en mémoire (UI sans serveur, pour les Lots 1 et 3)
/// false = vrai dépôt SQLite + synchro
/// Lot 2 passera cette valeur à false quand tout est testé.
const bool useFakeRepository = true;

/// Racine de composition : seul endroit où la couche data est branchée
/// sur le domaine.
final interventionRepositoryProvider = Provider<InterventionRepository>((ref) {
  if (useFakeRepository) return FakeInterventionRepository();
  return InterventionRepositoryImpl(
    InterventionLocalDataSource(ref.watch(appDatabaseProvider)),
    InterventionRemoteDataSource(ref.watch(dioProvider)),
    () => ref.read(syncServiceProvider).processQueue(),
  );
});

final getInterventionsProvider = Provider<GetInterventions>(
    (ref) => GetInterventions(ref.watch(interventionRepositoryProvider)));

final getDashboardStatsProvider = Provider<GetDashboardStats>(
    (ref) => GetDashboardStats(ref.watch(interventionRepositoryProvider)));

final updateInterventionStatusProvider = Provider<UpdateInterventionStatus>(
    (ref) => UpdateInterventionStatus(ref.watch(interventionRepositoryProvider)));

final createInterventionProvider = Provider<CreateIntervention>(
    (ref) => CreateIntervention(ref.watch(interventionRepositoryProvider)));

final refreshInterventionsProvider = Provider<RefreshInterventions>(
    (ref) => RefreshInterventions(ref.watch(interventionRepositoryProvider)));

/// Une intervention par identifiant (fiche détail), mise à jour en direct.
final interventionProvider =
    StreamProvider.family<Intervention?, String>((ref, id) {
  return ref.watch(interventionRepositoryProvider).watchAll().map((list) {
    for (final i in list) {
      if (i.id == id) return i;
    }
    return null;
  });
});
