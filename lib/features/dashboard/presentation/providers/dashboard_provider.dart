import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/interventions_providers.dart';
import '../../../interventions/domain/entities/intervention.dart';
import '../../../interventions/domain/usecases/get_dashboard_stats.dart';
import '../../../interventions/presentation/providers/interventions_provider.dart';

final dashboardStatsProvider = StreamProvider<DashboardStats>(
    (ref) => ref.watch(getDashboardStatsProvider)());

/// Les trois prochaines interventions non terminées, par date.
final upcomingInterventionsProvider = Provider<List<Intervention>>((ref) {
  final all = ref.watch(allInterventionsProvider).value ?? const [];
  final open = all.where((i) => i.status != InterventionStatus.done).toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return open.take(3).toList();
});
