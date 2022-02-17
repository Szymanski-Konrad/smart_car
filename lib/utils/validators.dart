abstract class Validators {
  static String? defaultValidator(String? input) {
    if (input == null || input.isEmpty) return 'Wartość nie może być pusta';
    final value = double.tryParse(input);
    if (value == null) return 'Wartość nie jest liczbą';
    return null;
  }

  static String? positiveNumberValidator(String? input) {
    if (input == null || input.isEmpty) return 'Wartość nie może być pusta';
    final value = double.tryParse(input);
    if (value == null) return 'Wartość nie jest liczbą';
    if (value <= 0) return 'Wartość musi być większa od 0';
    return null;
  }
}
