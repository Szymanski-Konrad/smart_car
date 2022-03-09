import 'package:flutter_logs/flutter_logs.dart';

abstract class Logger {
  static void logToFile(Object data) {
    if (data.toString().isNotEmpty) {
      FlutterLogs.logToFile(
        appendTimeStamp: true,
        logFileName: "device",
        overwrite: false,
        logMessage: '${data.toString()}\n',
      );
    }
  }
}
