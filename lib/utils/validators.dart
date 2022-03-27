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

  static String? odometerHigherThanPreviousValidator(
      String? input, double minimalValue) {
    if (input == null || input.isEmpty) return 'Wartość nie może być pusta';
    final value = double.tryParse(input);
    if (value == null) return 'Wartość nie jest liczbą';
    if (value <= 0) return 'Wartość musi być większa od 0';
    if (value <= minimalValue) {
      return 'Wartość nie może być mniejsza niż $minimalValue';
    }
    return null;
  }
}
