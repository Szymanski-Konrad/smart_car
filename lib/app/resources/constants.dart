abstract class Constants {
  static const minGpsDistance = 50; // m
  static const historyDataLength = 20; // number of history data to show
  static const tileHeight = 100.0;
  static const rapidBreaking = -1.5; // acceleration in m/s2
  static const rapidAcceleration = 2.0; // acceleration in m/s2

  static const minRapidSpeedTimeThreshold = 30; // s

  static const liveModeSpeedUp = 64;
  static const localModeMiliseconds = 1000 ~/ liveModeSpeedUp;

  static const co2GenerationRatio = 11 / 3;
}
