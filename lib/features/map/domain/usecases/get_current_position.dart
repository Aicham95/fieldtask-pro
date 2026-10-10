import '../entities/geo_position.dart';
import '../repositories/location_repository.dart';

class GetCurrentPosition {
  final LocationRepository _repository;

  GetCurrentPosition(this._repository);

  Future<GeoPosition?> call() => _repository.currentPosition();
}
