import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Model przechowujący pełne dane przejazdu do serializacji
class SavedTrip {
  SavedTrip({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.tripData,
    required this.obdSnapshots,
    this.metadata = const {},
  });

  final String id;
  final DateTime startTime;
  final DateTime endTime;

  /// Dane TripRecord w formie mapy
  final Map<String, dynamic> tripData;

  /// Lista snapshotów OBD z czasem (do odtwarzania)
  final List<OBDSnapshot> obdSnapshots;

  /// Dodatkowe metadane (nazwa pojazdu, notatki, itp.)
  final Map<String, dynamic> metadata;

  Duration get duration => endTime.difference(startTime);

  String get durationFormatted {
    final d = duration;
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s';
  }

  String get startTimeFormatted {
    return '${startTime.day.toString().padLeft(2, '0')}.'
        '${startTime.month.toString().padLeft(2, '0')}.'
        '${startTime.year} '
        '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }

  double get distance => (tripData['distance'] as num?)?.toDouble() ?? 0.0;
  double get avgFuelConsumption {
    final usedFuel =
        ((tripData['usedFuel'] as num?)?.toDouble() ?? 0.0) +
        ((tripData['idleUsedFuel'] as num?)?.toDouble() ?? 0.0);
    final dist = distance;
    if (dist == 0 || usedFuel == 0) return 0.0;
    return 100 * usedFuel / dist;
  }

  double get totalFuelUsed =>
      ((tripData['usedFuel'] as num?)?.toDouble() ?? 0.0) +
      ((tripData['idleUsedFuel'] as num?)?.toDouble() ?? 0.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'tripData': tripData,
    'obdSnapshots': obdSnapshots.map((s) => s.toJson()).toList(),
    'metadata': metadata,
    'version': 1,
  };

  factory SavedTrip.fromJson(Map<String, dynamic> json) => SavedTrip(
    id: json['id'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    tripData: Map<String, dynamic>.from(json['tripData'] as Map),
    obdSnapshots:
        (json['obdSnapshots'] as List<dynamic>?)
            ?.map((s) => OBDSnapshot.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [],
    metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
  );
}

/// Snapshot danych OBD w określonym momencie (do odtwarzania)
class OBDSnapshot {
  OBDSnapshot({
    required this.timestamp,
    required this.elapsedMs,
    required this.data,
  });

  final DateTime timestamp;
  final int elapsedMs; // ms od startu przejazdu
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'elapsedMs': elapsedMs,
    'data': data,
  };

  factory OBDSnapshot.fromJson(Map<String, dynamic> json) => OBDSnapshot(
    timestamp: DateTime.parse(json['timestamp'] as String),
    elapsedMs: json['elapsedMs'] as int,
    data: Map<String, dynamic>.from(json['data'] as Map),
  );
}

/// Uproszczone info o zapisanym przejeździe (bez pełnych danych)
class SavedTripInfo {
  SavedTripInfo({
    required this.id,
    required this.path,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.avgFuelConsumption,
    required this.snapshotCount,
    this.vehicleName,
  });

  final String id;
  final String path;
  final DateTime startTime;
  final DateTime endTime;
  final double distance;
  final double avgFuelConsumption;
  final int snapshotCount;
  final String? vehicleName;

  Duration get duration => endTime.difference(startTime);

  String get durationFormatted {
    final d = duration;
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s';
  }

  String get startTimeFormatted {
    return '${startTime.day.toString().padLeft(2, '0')}.'
        '${startTime.month.toString().padLeft(2, '0')}.'
        '${startTime.year} '
        '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get distanceFormatted => '${distance.toStringAsFixed(1)} km';
  String get fuelFormatted =>
      '${avgFuelConsumption.toStringAsFixed(1)} l/100km';
}

/// Serwis do zarządzania zapisanymi przejazdami
class TripStorage {
  TripStorage._();
  static final TripStorage instance = TripStorage._();

  DateTime? _tripStartTime;
  bool _isRecording = false;
  final List<OBDSnapshot> _snapshots = [];

  /// Czy nagrywanie jest aktywne
  bool get isRecording => _isRecording;

  /// Liczba zarejestrowanych snapshotów
  int get snapshotCount => _snapshots.length;

  /// Rozpocznij nagrywanie przejazdu
  void startRecording({Map<String, dynamic>? metadata}) {
    if (_isRecording) return;

    _tripStartTime = DateTime.now();
    _isRecording = true;
    _snapshots.clear();
    print('TripStorage: Started recording trip');
  }

  /// Zarejestruj snapshot danych OBD
  void recordSnapshot(Map<String, dynamic> data) {
    if (!_isRecording || _tripStartTime == null) return;

    final now = DateTime.now();
    final elapsedMs = now.difference(_tripStartTime!).inMilliseconds;

    _snapshots.add(
      OBDSnapshot(
        timestamp: now,
        elapsedMs: elapsedMs,
        data: Map<String, dynamic>.from(data),
      ),
    );
  }

  /// Zatrzymaj nagrywanie i zapisz przejazd
  Future<String?> stopRecording(
    Map<String, dynamic> tripData, {
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isRecording || _tripStartTime == null) return null;

    final endTime = DateTime.now();
    final tripId = 'trip_${_tripStartTime!.millisecondsSinceEpoch}';

    final savedTrip = SavedTrip(
      id: tripId,
      startTime: _tripStartTime!,
      endTime: endTime,
      tripData: tripData,
      obdSnapshots: List.from(_snapshots),
      metadata: metadata ?? {},
    );

    _isRecording = false;
    _tripStartTime = null;
    _snapshots.clear();

    final path = await _saveTrip(savedTrip);
    print('TripStorage: Saved trip to $path');
    return path;
  }

  /// Anuluj nagrywanie bez zapisu
  void cancelRecording() {
    _isRecording = false;
    _tripStartTime = null;
    _snapshots.clear();
  }

  /// Zapisz przejazd do pliku JSON
  Future<String> _saveTrip(SavedTrip trip) async {
    final dir = await _getTripsDirectory();
    final filename =
        'trip_${trip.startTime.toIso8601String().replaceAll(':', '-')}.json';
    final file = File('${dir.path}/$filename');

    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(trip.toJson());
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Pobierz katalog przejazdów
  Future<Directory> _getTripsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final tripsDir = Directory('${appDocDir.path}/saved_trips');
    if (!await tripsDir.exists()) {
      await tripsDir.create(recursive: true);
    }
    return tripsDir;
  }

  /// Pobierz listę zapisanych przejazdów
  Future<List<SavedTripInfo>> getSavedTrips() async {
    final dir = await _getTripsDirectory();
    if (!await dir.exists()) return [];

    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.json'),
    );

    final trips = <SavedTripInfo>[];
    for (final file in files) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final tripData = json['tripData'] as Map<String, dynamic>? ?? {};

        final usedFuel =
            ((tripData['usedFuel'] as num?)?.toDouble() ?? 0.0) +
            ((tripData['idleUsedFuel'] as num?)?.toDouble() ?? 0.0);
        final distance = (tripData['distance'] as num?)?.toDouble() ?? 0.0;
        final avgFuel = distance > 0 ? 100 * usedFuel / distance : 0.0;

        trips.add(
          SavedTripInfo(
            id: json['id'] as String,
            path: file.path,
            startTime: DateTime.parse(json['startTime'] as String),
            endTime: DateTime.parse(json['endTime'] as String),
            distance: distance,
            avgFuelConsumption: avgFuel,
            snapshotCount:
                (json['obdSnapshots'] as List<dynamic>?)?.length ?? 0,
            vehicleName: (json['metadata'] as Map?)?['vehicleName'] as String?,
          ),
        );
      } catch (e) {
        print('TripStorage: Error reading trip file ${file.path}: $e');
      }
    }

    trips.sort((a, b) => b.startTime.compareTo(a.startTime));
    return trips;
  }

  /// Wczytaj pełny przejazd z pliku
  Future<SavedTrip?> loadTrip(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return SavedTrip.fromJson(json);
    } catch (e) {
      print('TripStorage: Error loading trip: $e');
      return null;
    }
  }

  /// Importuj przejazd z zewnętrznego pliku
  Future<SavedTrip?> importTrip() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final trip = SavedTrip.fromJson(json);

      // Zapisz do lokalnego katalogu
      await _saveTrip(trip);
      return trip;
    } catch (e) {
      print('TripStorage: Error importing trip: $e');
      return null;
    }
  }

  /// Eksportuj przejazd do CSV
  Future<String> exportToCsv(String tripPath) async {
    final trip = await loadTrip(tripPath);
    if (trip == null) throw Exception('Cannot load trip');

    final csvPath = tripPath.replaceAll('.json', '.csv');
    final file = File(csvPath);

    final buffer = StringBuffer();

    // Header z info o przejeździe
    buffer.writeln('# Trip Export');
    buffer.writeln('# Start: ${trip.startTimeFormatted}');
    buffer.writeln('# Duration: ${trip.durationFormatted}');
    buffer.writeln('# Distance: ${trip.distance.toStringAsFixed(1)} km');
    buffer.writeln(
      '# Avg Fuel: ${trip.avgFuelConsumption.toStringAsFixed(1)} l/100km',
    );
    buffer.writeln('');

    // Dane z tripData
    buffer.writeln('## Trip Summary');
    buffer.writeln('key,value');
    for (final entry in trip.tripData.entries) {
      buffer.writeln('${entry.key},${entry.value}');
    }
    buffer.writeln('');

    // Snapshoty OBD
    if (trip.obdSnapshots.isNotEmpty) {
      buffer.writeln('## OBD Snapshots');

      // Zbierz wszystkie klucze
      final allKeys = <String>{};
      for (final snapshot in trip.obdSnapshots) {
        allKeys.addAll(snapshot.data.keys);
      }
      final sortedKeys = allKeys.toList()..sort();

      // Header
      buffer.writeln('timestamp,elapsedMs,${sortedKeys.join(',')}');

      // Dane
      for (final snapshot in trip.obdSnapshots) {
        final values = sortedKeys
            .map((k) => snapshot.data[k]?.toString() ?? '')
            .join(',');
        buffer.writeln(
          '${snapshot.timestamp.toIso8601String()},${snapshot.elapsedMs},$values',
        );
      }
    }

    await file.writeAsString(buffer.toString());
    return csvPath;
  }

  /// Udostępnij przejazd (JSON)
  Future<void> shareTrip(String path, {String? message}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], text: message ?? 'Dane przejazdu'),
    );
  }

  /// Udostępnij przejazd jako CSV
  Future<void> shareTripAsCsv(String path) async {
    final csvPath = await exportToCsv(path);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(csvPath)], text: 'Dane przejazdu (CSV)'),
    );
  }

  /// Usuń przejazd
  Future<void> deleteTrip(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    // Usuń też CSV jeśli istnieje
    final csvPath = path.replaceAll('.json', '.csv');
    final csvFile = File(csvPath);
    if (await csvFile.exists()) {
      await csvFile.delete();
    }
  }

  /// Wyczyść wszystkie przejazdy
  Future<void> clearAllTrips() async {
    final dir = await _getTripsDirectory();
    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>();
      for (final file in files) {
        await file.delete();
      }
    }
  }

  /// Pobierz statystyki
  Future<TripStorageStats> getStats() async {
    final trips = await getSavedTrips();
    final totalDistance = trips.fold<double>(0, (sum, t) => sum + t.distance);
    final totalDuration = trips.fold<Duration>(
      Duration.zero,
      (sum, t) => sum + t.duration,
    );

    return TripStorageStats(
      tripCount: trips.length,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
    );
  }
}

/// Statystyki przechowywania przejazdów
class TripStorageStats {
  TripStorageStats({
    required this.tripCount,
    required this.totalDistance,
    required this.totalDuration,
  });

  final int tripCount;
  final double totalDistance;
  final Duration totalDuration;
}
