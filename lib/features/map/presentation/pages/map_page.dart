import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/field_providers.dart';
import '../../../../core/di/interventions_providers.dart';
import '../../../interventions/domain/entities/intervention.dart';
import '../../../interventions/domain/usecases/get_interventions.dart';
import '../widgets/intervention_marker.dart';
import '../widgets/intervention_quick_sheet.dart';

/// Toutes les interventions du technicien, sous forme de pins.
final mapInterventionsProvider = StreamProvider<List<Intervention>>(
        (ref) => ref.watch(getInterventionsProvider)(sort: InterventionSort.date));

/// Saint-Louis : centre par défaut si la position GPS n'est pas disponible.
const _defaultCenter = LatLng(16.0326, -16.4818);

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interventions = ref.watch(mapInterventionsProvider).value ?? [];
    final position = ref.watch(currentPositionProvider).value;

    final markers = <Marker>[
      for (final i in interventions)
        Marker(
          point: LatLng(i.latitude, i.longitude),
          width: 44,
          height: 44,
          child: InterventionMarker(
            status: i.status,
            onTap: () => _openSheet(context, i),
          ),
        ),
      if (position != null)
        Marker(
          point: LatLng(position.latitude, position.longitude),
          width: 28,
          height: 28,
          child: const Icon(Icons.my_location, color: Colors.indigo),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Carte')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ma position',
        onPressed: () => ref.invalidate(currentPositionProvider),
        child: const Icon(Icons.gps_fixed),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: position == null
              ? _defaultCenter
              : LatLng(position.latitude, position.longitude),
          initialZoom: 13,
        ),
        children: [
          // Hors ligne, les tuiles non mises en cache restent grises :
          // les pins, eux, viennent de SQLite et s'affichent toujours.
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.techfix.fieldtask_pro',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, Intervention i) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => InterventionQuickSheet(
        intervention: i,
        onOpenDetail: () {
          Navigator.pop(sheet);
          context.push('/interventions/${i.id}');
        },
      ),
    );
  }
}