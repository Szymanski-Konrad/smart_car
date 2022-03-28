import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

abstract class FirestoreHandler {
  static const kStationsCollection = 'stations';
  static const kFuelLogCollection = 'fuelLogs';
  static const kChunkSize = 10;

  /// Save info about [station]
  static Future<void> saveStation(GasStation station) async {
    await FirebaseFirestore.instance
        .collection(kStationsCollection)
        .doc(station.id.toString())
        .set(
          station.toJson(),
          SetOptions(merge: true),
        );
  }

  /// Update [station] price
  static Future<void> updateStationPrice({required GasStation station}) async {
    await FirebaseFirestore.instance
        .collection(kStationsCollection)
        .doc(station.id.toString())
        .set(
          station.toJson(),
          SetOptions(merge: true),
        );
  }

  /// Get info about stations fetched from map
  static Future<List<GasStation>> getAllStations(List<String> ids) async {
    final chunks = (ids.length / kChunkSize).ceil();
    final stations = <GasStation>[];
    for (int i = 0; i < chunks; i++) {
      final end = (i + 1) * kChunkSize;
      final chunk =
          ids.sublist(i * kChunkSize, end <= ids.length ? end : ids.length);
      final results = await getChunkStations(chunk);
      stations.addAll(results);
    }
    return stations;
  }

  /// Get up to 10 stations at once
  static Future<List<GasStation>> getChunkStations(List<String> ids) async {
    final query = await FirebaseFirestore.instance
        .collection(kStationsCollection)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return query.docs.map(((e) => GasStation.fromJson(e.data()))).toList();
  }

  /// Save [fuelLog]
  static Future<void> saveFuelLog(FuelLog fuelLog) async {
    await FirebaseFirestore.instance
        .collection(kFuelLogCollection)
        .doc(fuelLog.id)
        .set(
          fuelLog.toJson(),
          SetOptions(merge: true),
        );
  }

  /// Fetch all fuel logs for account
  static Future<List<FuelLog>> fetchFuelLogs() async {
    final query =
        await FirebaseFirestore.instance.collection(kFuelLogCollection).get();
    return query.docs.map((e) => FuelLog.fromJson(e.data())).toList();
  }
}
