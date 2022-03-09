import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String get showSpaced {
    NumberFormat formatter = NumberFormat();
    final formatted = formatter.format(this);
    return formatted.replaceAll(',', ' ');
  }
}
