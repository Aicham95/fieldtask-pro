import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/interventions_providers.dart';
import '../../domain/entities/intervention.dart';
import '../../domain/usecases/get_interventions.dart';

class StatusFilter extends Notifier<InterventionStatus?> {
  @override
  InterventionStatus? build() => null;
  void set(InterventionStatus? value) => state = value;
}

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

class SortOption extends Notifier<InterventionSort> {
  @override
  InterventionSort build() => InterventionSort.priority;
  void set(InterventionSort value) => state = value;
}

/// Filtre de statut choisi (null = Tout).
final statusFilterProvider =
    NotifierProvider<StatusFilter, InterventionStatus?>(StatusFilter.new);

final searchQueryProvider =
    NotifierProvider<SearchQuery, String>(SearchQuery.new);

final sortOptionProvider =
    NotifierProvider<SortOption, InterventionSort>(SortOption.new);

/// Toutes les interventions du technicien (pour les compteurs et l'accueil).
final allInterventionsProvider = StreamProvider<List<Intervention>>(
    (ref) => ref.watch(getInterventionsProvider)(sort: InterventionSort.date));

/// Liste affichée : statut + recherche + tri appliqués.
final filteredInterventionsProvider = StreamProvider<List<Intervention>>((ref) {
  return ref.watch(getInterventionsProvider)(
    status: ref.watch(statusFilterProvider),
    query: ref.watch(searchQueryProvider),
    sort: ref.watch(sortOptionProvider),
  );
});
