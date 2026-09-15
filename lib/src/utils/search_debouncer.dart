import 'dart:async';
import 'package:flutter/foundation.dart';

/// Helper class to debounce rapid search input changes.
class SearchDebouncer {
  /// Creates a [SearchDebouncer] with specified delay.
  SearchDebouncer({
    this.delay = const Duration(milliseconds: 400),
  });

  /// Debounce duration.
  final Duration delay;

  Timer? _timer;

  /// Runs the provided callback after [delay]. Cancels any pending previous action.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any active timer.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
