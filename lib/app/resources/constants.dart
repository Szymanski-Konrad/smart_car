abstract class Constants {
  static const minGpsDistance = 50; // m
  static const historyDataLength = 20; // number of history data to show
  static const tileHeight = 120.0;
  static const rapidBreaking = -1.5; // acceleration in m/s2
  static const rapidAcceleration = 1.5; // acceleration in m/s2
  static const minRapidSpeedTimeThreshold = 30; // s
  static const co2GenerationRatio = 11 / 3;
  static const throttlePositionIdle = 18;
  static const minModuleVoltage = 13.3;
  static const idleSpeedLimit = 1;
  static const defaultLocalFile = 'work';

  static const localFiles = [
    'work',
    'ford1',
    'nowiakKolno',
    'passat1',
    'passat2',
    'passat3',
    'passat4',
    'passat5',
    'toyota1',
    'toyota2',
    'toyota3',
  ];
}

abstract class Durations {
  static const maxNoDataReciveSeconds = 3;
  static const closingTripDuration = Duration(seconds: 10);
}
