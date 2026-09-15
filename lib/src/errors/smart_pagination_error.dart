import 'package:flutter/foundation.dart';

/// Categories of errors that can occur during pagination operations.
enum SmartPaginationErrorType {
  /// Connectivity or network socket errors.
  network,

  /// Request or operation timeout.
  timeout,

  /// HTTP 401 Authentication failure.
  unauthorized,

  /// HTTP 403 Access forbidden.
  forbidden,

  /// HTTP 404 Resource not found.
  notFound,

  /// HTTP 5xx Internal Server Error.
  server,

  /// JSON parsing or data deserialization error.
  parsing,

  /// Operation cancelled manually or by generation superseding.
  cancelled,

  /// Invalid developer configuration (e.g., `pageSize <= 0`).
  configuration,

  /// Fallback for unclassified exceptions.
  unknown,
}

/// Represents a structured error produced by [SmartPaginationController].
@immutable
class SmartPaginationError implements Exception {
  /// Creates a [SmartPaginationError].
  const SmartPaginationError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  /// Factory helper that converts any caught exception into a structured [SmartPaginationError].
  factory SmartPaginationError.from(Object error, [StackTrace? stackTrace]) {
    if (error is SmartPaginationError) {
      return error;
    }

    final str = error.toString().toLowerCase();

    SmartPaginationErrorType type = SmartPaginationErrorType.unknown;

    if (str.contains('socket') ||
        str.contains('network') ||
        str.contains('connection refused') ||
        str.contains('offline')) {
      type = SmartPaginationErrorType.network;
    } else if (str.contains('timeout')) {
      type = SmartPaginationErrorType.timeout;
    } else if (str.contains('401') || str.contains('unauthorized')) {
      type = SmartPaginationErrorType.unauthorized;
    } else if (str.contains('403') || str.contains('forbidden')) {
      type = SmartPaginationErrorType.forbidden;
    } else if (str.contains('404') || str.contains('not found')) {
      type = SmartPaginationErrorType.notFound;
    } else if (str.contains('500') ||
        str.contains('502') ||
        str.contains('503') ||
        str.contains('server error')) {
      type = SmartPaginationErrorType.server;
    } else if (str.contains('typeerror') ||
        str.contains('formatException') ||
        str.contains('parse') ||
        str.contains('cast')) {
      type = SmartPaginationErrorType.parsing;
    }

    return SmartPaginationError(
      type: type,
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Categorized error type.
  final SmartPaginationErrorType type;

  /// Human-readable error description message.
  final String message;

  /// Original underlying exception/error instance if available.
  final Object? originalError;

  /// Stack trace associated with the original error.
  final StackTrace? stackTrace;

  @override
  String toString() => 'SmartPaginationError(type: $type, message: $message)';
}
