abstract class Constants {
  static const minGpsDistance = 50; // m
  static const historyDataLength = 20; // number of history data to show
  static const tileHeight = 100.0;
  static const infoTileHeight = 80.0;
  static const infoTileWidthFactor = 0.48;
  static const largeInfoTileWidthFactor = 0.31;
  static const rapidBreaking = -2; // acceleration in m/s2
  static const rapidAcceleration = 1.5; // acceleration in m/s2
  static const minRapidSpeedTimeThreshold = 30; // s
  static const co2GenerationRatio = 11 / 3;
  static const minModuleVoltage = 13.3;
  static const idleSpeedLimit = 1;
  static const defaultLocalFile = 'work';
  static const largeScreenWidth = 400.0;

  static const localFiles = [
    'trip1',
    'trip2',
    'trip3',
    'trip4',
    'trip5',
    'trip6',
    'work',
    'work2',
    'work3',
    'work4',
    'ford1',
    'gizycko-kolno',
    'nowiak-mikolajki',
    'nowiakKolno',
    'passat1',
    'passat2',
    'passat3',
    'passat4',
    'passat5',
    'praca',
    'toyota1',
    'toyota2',
    'toyota3',
  ];
}

abstract class Durations {
  static const maxNoDataReciveSeconds = 3;
  static const closingTripDuration = Duration(seconds: 10);
}
