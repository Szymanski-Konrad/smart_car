import 'package:flutter/cupertino.dart';
import 'package:smart_car/utils/list_extension.dart';

abstract class ObdCommand {
  ObdCommand(
    this.command, {
    this.min,
    this.max,
    required int prio,
    this.enableHistorical = true,
  }) {
    priority = prio;
    waitTimes = prio;
  }

  num result = double.nan;
  final String command;

  // Priority
  late final int priority;
  late int waitTimes;

  // Time
  DateTime sendTime = DateTime.now();
  DateTime? lastReciveTime;
  int responseTime = 0;
  int differenceMiliseconds = 0;

  // Extreme values
  num? max;
  num? min;
  num maxValue = double.negativeInfinity;
  num minValue = double.infinity;

  // History data
  List<double> historyData = [];

  /// Define if command should store historical data
  bool enableHistorical;

  @mustCallSuper
  void performCalculations(List<int> data) {
    if (result > maxValue) maxValue = result;
    if (result < minValue) minValue = result;
    if (enableHistorical) {
      insertHistoryData();
    }
  }

  /// Called when ELM send back [data] from command, then do
  void commandBack(List<int> data) {
    final now = DateTime.now();
    final lastTime = lastReciveTime;
    if (lastTime != null) {
      differenceMiliseconds = now.difference(lastTime).inMilliseconds.abs();
    }
    lastReciveTime = now;
    responseTime = now.difference(sendTime).inMilliseconds.abs();
    performCalculations(data);
  }

  String? sendCommand() {
    if (waitTimes >= priority) {
      waitTimes = 0;
      sendTime = DateTime.now();
      return command;
    } else {
      waitTimes++;
    }
  }

  void insertHistoryData() {
    historyData.addWithMax(result.toDouble(), 10);
  }

  List<double> get lastHistoryData {
    return historyData;
  }
}
