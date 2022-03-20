import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

abstract class FirestoreHandler {
  static const kStationsCollection = 'stations';
  static const kChunkSize = 10;

  static Future<void> saveStation(GasStation station) async {
    await FirebaseFirestore.instance
        .collection(kStationsCollection)
        .doc(station.id.toString())
        .update(station.toJson());
  }

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

  static Future<List<GasStation>> getChunkStations(List<String> ids) async {
    final query = await FirebaseFirestore.instance
        .collection(kStationsCollection)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return query.docs.map(((e) => GasStation.fromJson(e.data()))).toList();
  }
}
