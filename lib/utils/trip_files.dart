import 'dart:convert';
import 'dart:io';

import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/pages/live_data/model/test_data/test_command.dart';

abstract class TripFiles {
  /// Save trip file
  static Future<void> saveCommandsToFile(List<TestCommand> testCommands) async {
    if (testCommands.isNotEmpty) {
      final feedback = jsonEncode(testCommands.map((e) => e.toJson()).toList());
      Directory appDocDir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final path = '${appDocDir.path}/trip${now.toString()}.json';
      File file = File(path);
      file.writeAsString(feedback);
    }
  }

  /// Show files in app documents directory
  static Future<List<String>> showFilesInDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final files = appDocDir.listSync();
    final paths = files.map((e) => e.path).toList();
    return paths.where((element) => element.contains('trip')).toList();
  }

  /// Send [files] with mail
  static Future<void> sendTripsToMail(List<String> files) async {
    final mailOptions = MailOptions(
      body: 'Sending my last trips',
      recipients: ['hunteelar.programowanie@gmail.com'],
      isHTML: true,
      attachments: files,
    );

    await FlutterMailer.send(mailOptions);
    for (final path in files) {
      final file = File(path);
      file.delete();
    }
  }
}
