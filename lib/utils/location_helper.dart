import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:haversine_distance/haversine_distance.dart' as hav;

@immutable
abstract class LocationHelper {
  const LocationHelper._();

  /// Get current location of phone
  static Future<LatLng?> getCurrentLocation() async {
    final location = Location.instance;
    await checkLocationService();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.granted) return null;
    final currentLocation = await location.getLocation();
    final latitude = currentLocation.latitude;
    final longitude = currentLocation.longitude;
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  /// Return distance between [first] and [second] in km
  static double calculateDistanceLatLng(LatLng first, LatLng second) {
    final start = hav.Location(first.latitude, first.longitude);
    final end = hav.Location(second.latitude, second.longitude);
    final distance =
        hav.HaversineDistance().haversine(start, end, hav.Unit.METER);
    return distance / 1000;
  }

  /// Calculate distance between [previous] and [current] location
  static double calculateDistance(LocationData previous, LocationData current) {
    final start = hav.Location(previous.latitude ?? 0, previous.longitude ?? 0);
    final end = hav.Location(current.latitude ?? 0, current.longitude ?? 0);
    return hav.HaversineDistance().haversine(start, end, hav.Unit.METER);
  }

  /// Calculate angle between two points, [distance] is optional if calculate previously
  static double calculateAngle(
    LocationData previous,
    LocationData current, {
    double? distance,
  }) {
    final _distance = distance ?? calculateDistance(previous, current);
    final currentAlt = current.altitude ?? 0;
    final previousAlt = previous.altitude ?? 0;
    final hightDiff = currentAlt - previousAlt;
    final c = sqrt(pow(_distance, 2) + pow(hightDiff, 2));
    return asin(hightDiff / c) * 100;
  }

  /// Check if GPS is already enabled and is turn on
  static Future<bool> checkLocationService() async {
    final location = Location.instance;
    bool serviceEnabled;

    PermissionStatus permission;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == PermissionStatus.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    serviceEnabled = await location.serviceEnabled();

    return serviceEnabled;
  }

  static Map<String, dynamic>? tryCoordsToJson(LatLng? latLng) {
    if (latLng == null) return null;
    return coordsToJson(latLng);
  }

  static Map<String, dynamic> coordsToJson(LatLng latLng) => {
        'coordinates': [latLng.longitude, latLng.latitude]
      };
}

extension LocationDataExtension on LocationData {
  LatLng get toLatLng => LatLng(latitude ?? 0, longitude ?? 0);
}
