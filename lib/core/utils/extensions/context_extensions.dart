import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void showSnack(String message) {
    ScaffoldMessenger.maybeOf(this)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
