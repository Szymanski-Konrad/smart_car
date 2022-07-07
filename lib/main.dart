import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigator.dart';
import 'package:smart_car/feautures/alert_center/alert_center.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final appKey = GlobalKey();
  AlertCenter.initialize(globalKey: appKey);

  runZonedGuarded<Future<void>>(
    () async {
      await SentryFlutter.init(
        (options) {
          options.dsn =
              'https://7264306b4e064a84ad91d9889c9ed294@o1307209.ingest.sentry.io/6551194';
          options.tracesSampleRate = 1.0;
        },
      );

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
      runApp(_App(appKey: appKey));
    },
    ((error, stack) async {
      print('Error occured in app!!!');
      await Sentry.captureException(error, stackTrace: stack);
    }),
  );
}

class _App extends StatelessWidget {
  const _App({Key? key, required this.appKey}) : super(key: key);

  final GlobalKey appKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: FlutterBlueApp(key: appKey),
    );
  }
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: GlobalBlocs.blocs,
      child: const ToastProvider(child: PageNavigator()),
    );
  }
}
