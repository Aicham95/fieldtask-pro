import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_interventions.dart';
import '../providers/interventions_provider.dart';

/// Menu « Trier par » : priorité ou date.
class SortMenu extends ConsumerWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortOptionProvider);
    return PopupMenuButton<InterventionSort>(
      icon: const Icon(Icons.sort),
      tooltip: 'Trier par',
      initialValue: current,
      onSelected: (v) => ref.read(sortOptionProvider.notifier).set(v),
      itemBuilder: (_) => const [
        PopupMenuItem(value: InterventionSort.priority, child: Text('Priorité')),
        PopupMenuItem(value: InterventionSort.date, child: Text('Date prévue')),
      ],
    );
  }
}
