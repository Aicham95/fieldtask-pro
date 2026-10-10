import '../../domain/entities/geo_position.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource _source;

  LocationRepositoryImpl(this._source);

  @override
  Future<GeoPosition?> currentPosition() async {
    try {
      final p = await _source.currentPosition();
      return p == null ? null : GeoPosition(p.latitude, p.longitude);
    } catch (_) {
      // Délai dépassé, GPS indisponible... : la carte marche sans position.
      return null;
    }
  }
}
