import 'dart:typed_data';

class TestCommand {
  TestCommand(this.command, this.responseTime, this.data);

  final String command;
  final int responseTime;
  final Uint8List data;

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'responseTime': responseTime,
      'data': data,
    };
  }

  static TestCommand fromJson(Map<String, dynamic> json) {
    final data = Uint8List.fromList(json['data']);
    return TestCommand(
      json['command'],
      json['responseTime'],
      data,
    );
  }
}
