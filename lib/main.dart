import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:smart_car/pages/device_search/ui/device_search_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterLogs.initLogs(
    logLevelsEnabled: LogLevel.values,
    timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
    singleLogFileSize: 32,
    directoryStructure: DirectoryStructure.SINGLE_FILE_FOR_DAY,
    logTypesEnabled: ["device", "network", "errors"],
    logFileExtension: LogFileExtension.LOG,
    logsWriteDirectoryName: "MyLogs",
    attachTimeStamp: true,
    logSystemCrashes: true,
    autoExportErrors: true,
    logsExportDirectoryName: "MyLogs/Exported",
    debugFileOperations: true,
    isDebuggable: true,
  );

  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DeviceSearchPage(),
      theme: ThemeData.dark(),
    );
  }
}
