import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'permission_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final permissionService = ref.read(permissionServiceProvider);
  return LocationService(permissionService);
});

class LocationService {
  final PermissionService _permissionService;
  LocationService(this._permissionService);

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check and request location permission
    bool hasPermission = await _permissionService.requestLocationPermission();
    if (!hasPermission) {
      return Future.error('Location permission denied.');
    }

    // Get the current location
    try {
      return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ));
    } catch (e) {
      return Future.error('Failed to get location: $e');
    }
  }
}
