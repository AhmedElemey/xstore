import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueUI<T> on AsyncValue<T> {
  /// Builds a small widget tree for list/detail placeholders.
  Widget toWidget({
    required Widget Function(T data) data,
    Widget Function()? loading,
    Widget Function(Object err)? errorBuilder,
  }) {
    return when(
      data: data,
      loading: () =>
          loading?.call() ??
          const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          errorBuilder?.call(err) ??
          Center(child: Text(err.toString(), textAlign: TextAlign.center)),
    );
  }
}
