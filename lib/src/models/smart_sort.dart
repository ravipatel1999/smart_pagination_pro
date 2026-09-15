import 'package:flutter/foundation.dart';

/// Represents a sorting parameter for pagination queries.
@immutable
class SmartSort {
  /// Creates a [SmartSort] instance.
  const SmartSort({
    required this.field,
    this.descending = false,
  });

  /// Target field name to sort by (e.g., `'created_at'`, `'name'`).
  final String field;

  /// Whether sorting should be in descending order. Defaults to `false`.
  final bool descending;

  /// Creates a copy of this [SmartSort] with updated fields.
  SmartSort copyWith({
    String? field,
    bool? descending,
  }) {
    return SmartSort(
      field: field ?? this.field,
      descending: descending ?? this.descending,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartSort &&
        other.field == field &&
        other.descending == descending;
  }

  @override
  int get hashCode => Object.hash(field, descending);

  @override
  String toString() => 'SmartSort(field: $field, descending: $descending)';
}
