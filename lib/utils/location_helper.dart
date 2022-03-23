import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:haversine_distance/haversine_distance.dart' as hav;

@immutable
abstract class LocationHelper {
  const LocationHelper._();

  static double calculateDistance(LocationData previous, LocationData current) {
    final start = hav.Location(previous.latitude ?? 0, previous.longitude ?? 0);
    final end = hav.Location(current.latitude ?? 0, current.longitude ?? 0);
    return hav.HaversineDistance().haversine(start, end, hav.Unit.METER);
  }

  static double calculateAngle(
    LocationData previous,
    LocationData current,
    double distance,
  ) {
    final currentAlt = current.altitude ?? 0;
    final previousAlt = previous.altitude ?? 0;
    final hightDiff = currentAlt - previousAlt;
    final c = sqrt(pow(distance, 2) + pow(hightDiff, 2));
    return asin(hightDiff / c);
  }

  static Future<void> checkLocationService(Location location) async {
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
  }

  static Map<String, dynamic> coordsToJson(LatLng latLng) => {
        'coordinates': [latLng.longitude, latLng.latitude]
      };
}
