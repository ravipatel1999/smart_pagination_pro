import 'package:flutter/foundation.dart';

/// The result returned by a pagination data source fetch callback.
@immutable
class SmartPageResult<T> {
  /// Creates a [SmartPageResult] with loaded items and metadata.
  const SmartPageResult({
    required this.items,
    this.totalItems,
    this.hasMore,
    this.nextCursor,
  });

  /// The list of items fetched for the requested page.
  final List<T> items;

  /// Optional total count of items across all pages.
  final int? totalItems;

  /// Optional explicit flag indicating whether more pages exist.
  final bool? hasMore;

  /// Optional cursor token for the next page in cursor-based pagination.
  final dynamic nextCursor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartPageResult<T> &&
        listEquals(other.items, items) &&
        other.totalItems == totalItems &&
        other.hasMore == hasMore &&
        other.nextCursor == nextCursor;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        totalItems,
        hasMore,
        nextCursor,
      );

  @override
  String toString() {
    return 'SmartPageResult<$T>(itemsCount: ${items.length}, totalItems: $totalItems, hasMore: $hasMore, nextCursor: $nextCursor)';
  }
}
