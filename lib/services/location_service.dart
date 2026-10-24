import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../models/meta.dart';

enum LocationProblem { serviceOff, permissionDenied, timeout }

class LocationException implements Exception {
  LocationException(this.problem);

  final LocationProblem problem;
}

class LocationReading {
  LocationReading({required this.lat, required this.lng, this.accuracy, this.demo = false});

  final double lat;
  final double lng;
  final double? accuracy;
  final bool demo;

  /// Straight-line distance from the ward centre, in metres.
  int distanceTo(Ward ward) => Geolocator.distanceBetween(ward.centerLat, ward.centerLng, lat, lng).round();

  bool isInside(Ward ward) => distanceTo(ward) <= ward.radiusMeters;
}

/// Takes one GPS reading when a survey or complaint is submitted. No background
/// tracking. "Demo location" places the phone inside the ward so the app can be
/// shown outside Mirzapur; the backend still checks every reading.
class LocationService {
  static final _random = Random();

  static Future<LocationReading> read({required Ward ward, required bool demo}) async {
    if (demo) {
      final distance = ward.radiusMeters * 0.4 * sqrt(_random.nextDouble());
      final bearing = _random.nextDouble() * 2 * pi;
      final lat = ward.centerLat + distance * cos(bearing) / 111320.0;
      final lng = ward.centerLng + distance * sin(bearing) / (111320.0 * cos(ward.centerLat * pi / 180));
      return LocationReading(lat: lat, lng: lng, accuracy: 10, demo: true);
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException(LocationProblem.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw LocationException(LocationProblem.permissionDenied);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      return LocationReading(lat: p.latitude, lng: p.longitude, accuracy: p.accuracy);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return LocationReading(lat: last.latitude, lng: last.longitude, accuracy: last.accuracy);
      }
      throw LocationException(LocationProblem.timeout);
    }
  }
}
