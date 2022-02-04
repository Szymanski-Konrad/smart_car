abstract class Constants {
  static const minGpsDistance = 50; // m
  static const historyDataLength = 20; // number of history data to show
  static const tileHeight = 90.0;
  static const rapidBreaking = -1.5; // acceleration in m/s2
  static const rapidAcceleration = 1.5; // acceleration in m/s2
  static const minRapidSpeedTimeThreshold = 30; // s
  static const co2GenerationRatio = 11 / 3;
  static const throttlePositionIdle = 18;
  static const minModuleVoltage = 13.3;
  static const idleSpeedLimit = 5;
  static const defaultLocalFile = 'work';

  static const localFiles = [
    'legionowo_trip',
    'long_trip',
    'trip_12_01_2022',
    'trip2022-01-22 nwd-kolno',
    'trip2022-01-23 kolno-nwd',
    'very_long',
    'work',
    'trip2022-02-02 10_52_59.920311',
    'zsiatki',
    'nasiatke',
  ];
}

abstract class Durations {
  static const maxNoDataReciveSeconds = 3;
  static const closingTripDuration = Duration(seconds: 10);
}
