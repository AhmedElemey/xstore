extension StringX on String {
  String get trimmedOrEmpty => trim();

  bool get isBlank => trim().isEmpty;
}
