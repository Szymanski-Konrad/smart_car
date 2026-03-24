import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// Model reprezentujący pojedynczy odczyt OBD
class OBDReading {
  OBDReading({
    required this.timestamp,
    required this.pid,
    required this.name,
    required this.value,
    required this.unit,
    this.responseTime = 0,
  });

  final DateTime timestamp;
  final String pid;
  final String name;
  final double value;
  final String unit;
  final int responseTime;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'timestampMs': timestamp.millisecondsSinceEpoch,
    'pid': pid,
    'name': name,
    'value': value,
    'unit': unit,
    'responseTime': responseTime,
  };

  factory OBDReading.fromJson(Map<String, dynamic> json) => OBDReading(
    timestamp: DateTime.parse(json['timestamp'] as String),
    pid: json['pid'] as String,
    name: json['name'] as String,
    value: (json['value'] as num).toDouble(),
    unit: json['unit'] as String,
    responseTime: json['responseTime'] as int? ?? 0,
  );

  String toCsvRow() =>
      '${timestamp.toIso8601String()},$pid,$name,$value,$unit,$responseTime';

  static String csvHeader() => 'timestamp,pid,name,value,unit,responseTime';
}

/// Model sesji logowania
class LogSession {
  LogSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.readings = const [],
    this.metadata = const {},
  });

  final String id;
  final DateTime startTime;
  DateTime? endTime;
  List<OBDReading> readings;
  Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'readingsCount': readings.length,
    'metadata': metadata,
    'readings': readings.map((r) => r.toJson()).toList(),
  };

  factory LogSession.fromJson(Map<String, dynamic> json) => LogSession(
    id: json['id'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null
        ? DateTime.parse(json['endTime'] as String)
        : null,
    readings:
        (json['readings'] as List<dynamic>?)
            ?.map((r) => OBDReading.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [],
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  String get durationFormatted {
    final d = duration;
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s';
  }
}

/// Serwis do logowania danych OBD
class DataLogger {
  DataLogger._();
  static final DataLogger instance = DataLogger._();

  LogSession? _currentSession;
  bool _isLogging = false;
  final int _bufferFlushCount = 100; // Flush co 100 odczytów
  int _readingsSinceLastFlush = 0;

  /// Czy logger jest aktywny
  bool get isLogging => _isLogging;

  /// Aktualna sesja
  LogSession? get currentSession => _currentSession;

  /// Liczba odczytów w bieżącej sesji
  int get readingsCount => _currentSession?.readings.length ?? 0;

  /// Rozpocznij nową sesję logowania
  Future<void> startSession({Map<String, dynamic>? metadata}) async {
    if (_isLogging) {
      await stopSession();
    }

    final now = DateTime.now();
    final sessionId = 'session_${now.millisecondsSinceEpoch}';

    _currentSession = LogSession(
      id: sessionId,
      startTime: now,
      readings: [],
      metadata: metadata ?? {},
    );
    _isLogging = true;
    _readingsSinceLastFlush = 0;

    print('DataLogger: Started session $sessionId');
  }

  /// Zatrzymaj sesję i zapisz do pliku
  Future<String?> stopSession() async {
    if (!_isLogging || _currentSession == null) return null;

    _currentSession!.endTime = DateTime.now();
    _isLogging = false;

    final path = await _saveSession(_currentSession!);
    print('DataLogger: Stopped session ${_currentSession!.id}, saved to $path');

    _currentSession = null;
    return path;
  }

  /// Zapisz odczyt z komendy OBD
  void logCommand(ObdCommand command) {
    if (!_isLogging || _currentSession == null) return;

    if (command is VisibleObdCommand && command.result.isFinite) {
      final reading = OBDReading(
        timestamp: DateTime.now(),
        pid: command.command,
        name: command.name,
        value: command.result.toDouble(),
        unit: command.unit,
        responseTime: command.responseTime,
      );

      _currentSession!.readings.add(reading);
      _readingsSinceLastFlush++;

      // Auto-flush do pliku co N odczytów (backup)
      if (_readingsSinceLastFlush >= _bufferFlushCount) {
        _flushToTempFile();
      }
    }
  }

  /// Zapisz wiele odczytów naraz (np. wszystkie komendy)
  void logCommands(List<ObdCommand> commands) {
    for (final command in commands) {
      logCommand(command);
    }
  }

  /// Zapisz dodatkowe dane (np. GPS, przyspieszenia)
  void logExtra(String name, double value, String unit) {
    if (!_isLogging || _currentSession == null) return;

    final reading = OBDReading(
      timestamp: DateTime.now(),
      pid: 'EXTRA',
      name: name,
      value: value,
      unit: unit,
    );

    _currentSession!.readings.add(reading);
  }

  /// Zapisz mapę danych (np. GPS, snapshot stanu)
  void logMap(Map<String, dynamic> data, {String prefix = 'DATA'}) {
    if (!_isLogging || _currentSession == null) return;

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is num) {
        final reading = OBDReading(
          timestamp: DateTime.now(),
          pid: prefix,
          name: entry.key,
          value: value.toDouble(),
          unit: '',
        );
        _currentSession!.readings.add(reading);
      } else if (value != null) {
        // Dla nie-numerycznych wartości zapisz jako metadata
        addMetadata('${prefix}_${entry.key}', value.toString());
      }
    }
  }

  /// Dodaj metadane do sesji
  void addMetadata(String key, dynamic value) {
    _currentSession?.metadata[key] = value;
  }

  /// Zapisz sesję do pliku JSON
  Future<String> _saveSession(LogSession session) async {
    final dir = await _getLogsDirectory();
    final filename =
        'obd_log_${session.startTime.toIso8601String().replaceAll(':', '-')}.json';
    final file = File('${dir.path}/$filename');

    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(session.toJson());
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Flush tymczasowy do pliku (backup)
  Future<void> _flushToTempFile() async {
    if (_currentSession == null) return;

    try {
      final dir = await _getLogsDirectory();
      final tempFile = File('${dir.path}/.temp_${_currentSession!.id}.json');
      final jsonString = jsonEncode(_currentSession!.toJson());
      await tempFile.writeAsString(jsonString);
      _readingsSinceLastFlush = 0;
    } catch (e) {
      print('DataLogger: Error flushing to temp file: $e');
    }
  }

  /// Pobierz katalog logów
  Future<Directory> _getLogsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${appDocDir.path}/obd_logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir;
  }

  /// Pobierz listę wszystkich zapisanych sesji
  Future<List<LogSessionInfo>> getLoggedSessions() async {
    final dir = await _getLogsDirectory();
    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.json') && !f.path.contains('.temp_'),
    );

    final sessions = <LogSessionInfo>[];
    for (final file in files) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        sessions.add(
          LogSessionInfo(
            id: json['id'] as String,
            path: file.path,
            startTime: DateTime.parse(json['startTime'] as String),
            endTime: json['endTime'] != null
                ? DateTime.parse(json['endTime'] as String)
                : null,
            readingsCount: json['readingsCount'] as int? ?? 0,
          ),
        );
      } catch (e) {
        print('DataLogger: Error reading session file: $e');
      }
    }

    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Wczytaj pełną sesję z pliku
  Future<LogSession?> loadSession(String path) async {
    try {
      final file = File(path);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return LogSession.fromJson(json);
    } catch (e) {
      print('DataLogger: Error loading session: $e');
      return null;
    }
  }

  /// Eksportuj sesję do CSV
  Future<String> exportToCsv(String sessionPath) async {
    final session = await loadSession(sessionPath);
    if (session == null) throw Exception('Cannot load session');

    final csvPath = sessionPath.replaceAll('.json', '.csv');
    final file = File(csvPath);

    final buffer = StringBuffer();
    buffer.writeln(OBDReading.csvHeader());
    for (final reading in session.readings) {
      buffer.writeln(reading.toCsvRow());
    }

    await file.writeAsString(buffer.toString());
    return csvPath;
  }

  /// Udostępnij plik sesji
  Future<void> shareSession(String path) async {
    await Share.shareXFiles([XFile(path)], text: 'OBD Data Log');
  }

  /// Usuń sesję
  Future<void> deleteSession(String path) async {
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

  /// Wyczyść wszystkie logi
  Future<void> clearAllLogs() async {
    final dir = await _getLogsDirectory();
    final files = dir.listSync().whereType<File>();
    for (final file in files) {
      await file.delete();
    }
  }

  /// Pobierz statystyki logowania
  Future<LoggingStats> getStats() async {
    final sessions = await getLoggedSessions();
    final totalReadings = sessions.fold<int>(
      0,
      (sum, s) => sum + s.readingsCount,
    );
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + (s.duration ?? Duration.zero),
    );

    return LoggingStats(
      sessionCount: sessions.length,
      totalReadings: totalReadings,
      totalDuration: totalDuration,
    );
  }
}

/// Uproszczone info o sesji (bez pełnych odczytów)
class LogSessionInfo {
  LogSessionInfo({
    required this.id,
    required this.path,
    required this.startTime,
    this.endTime,
    required this.readingsCount,
  });

  final String id;
  final String path;
  final DateTime startTime;
  final DateTime? endTime;
  final int readingsCount;

  Duration? get duration =>
      endTime?.difference(startTime);

  String get durationFormatted {
    final d = duration;
    if (d == null) return '--';
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s';
  }

  String get startTimeFormatted {
    return '${startTime.day}.${startTime.month}.${startTime.year} '
        '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Statystyki logowania
class LoggingStats {
  LoggingStats({
    required this.sessionCount,
    required this.totalReadings,
    required this.totalDuration,
  });

  final int sessionCount;
  final int totalReadings;
  final Duration totalDuration;
}
