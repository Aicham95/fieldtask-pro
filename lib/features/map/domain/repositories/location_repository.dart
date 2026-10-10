import '../entities/geo_position.dart';

abstract class LocationRepository {
  /// Position actuelle, ou null si la permission est refusée ou le GPS coupé.
  Future<GeoPosition?> currentPosition();
}
