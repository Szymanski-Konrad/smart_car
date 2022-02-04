import 'dart:async';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:smart_car/app/navigation/navigator.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SettingsCubit()..loadSettings(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        home: const ToastProvider(child: PageNavigator()),
        theme: ThemeData.dark(),
      ),
    );
  }
}
