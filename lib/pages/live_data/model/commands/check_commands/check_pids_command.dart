const List<String> checkPids = [
  '0100',
  '0120',
  '0140',
  '0160',
  '0180',
  '01A0',
  '01C0',
];

abstract class CheckPidsCommand {
  static List<String> extractSupportedPids(
      List<String> receivedData, String command) {
    final startIndex = int.parse(command, radix: 16) + 1;
    final joinedPids = receivedData.skip(2).join('');
    final supportedCommands = <String>[];
    String sectionBinary = '';
    for (int i = 0; i < joinedPids.length; i++) {
      sectionBinary +=
          int.parse(joinedPids[i], radix: 16).toRadixString(2).padLeft(4, '0');
    }
    for (int i = 0; i < sectionBinary.length; i++) {
      final command = '01' +
          (i + startIndex).toRadixString(16).padLeft(2, '0').toUpperCase();
      if (sectionBinary[i] == '1') {
        supportedCommands.add(command);
      }
    }

    return supportedCommands;
  }
}
