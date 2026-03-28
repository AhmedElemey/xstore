import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueUI<T> on AsyncValue<T> {
  /// Runs [data] only for [AsyncData]; otherwise returns [orElse].
  R whenData<R>(R Function(T data) data, R Function() orElse) {
    return switch (this) {
      AsyncData(:final value) => data(value),
      _ => orElse(),
    };
  }

  /// Maps [data] while forwarding loading/error to callbacks.
  R whenDataOr<R>({
    required R Function(T data) data,
    required R Function() loading,
    required R Function(Object err, StackTrace stack) onError,
  }) {
    return switch (this) {
      AsyncData(:final value) => data(value),
      AsyncError(:final error, :final stackTrace) => onError(error, stackTrace),
      _ => loading(),
    };
  }

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
