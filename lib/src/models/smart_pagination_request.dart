import 'package:flutter/foundation.dart';
import 'smart_sort.dart';

/// Represents an asynchronous data page request containing current pagination parameters.
@immutable
class SmartPaginationRequest {
  /// Creates a [SmartPaginationRequest].
  const SmartPaginationRequest({
    required this.page,
    required this.offset,
    required this.pageSize,
    this.cursor,
    this.search,
    this.filters = const <String, dynamic>{},
    this.sort,
  });

  /// The 1-based or 0-based page index being requested.
  final int page;

  /// The record index offset (e.g., `0`, `20`, `40`).
  final int offset;

  /// The configured number of items requested per page.
  final int pageSize;

  /// Opaque cursor value for cursor-based pagination (String, int, Map, etc.).
  final dynamic cursor;

  /// Current search query string if active.
  final String? search;

  /// Active key-value filter parameters map.
  final Map<String, dynamic> filters;

  /// Active sorting criteria.
  final SmartSort? sort;

  /// Generates a unique deduplication key for this query combination.
  String toDeduplicationKey({required String strategyName}) {
    final filtersKey =
        filters.entries.map((e) => '${e.key}:${e.value}').toList()..sort();
    return '$strategyName|p:$page|o:$offset|s:$pageSize|c:$cursor|q:$search|f:${filtersKey.join(",")}|sort:${sort?.field}_${sort?.descending}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartPaginationRequest &&
        other.page == page &&
        other.offset == offset &&
        other.pageSize == pageSize &&
        other.cursor == cursor &&
        other.search == search &&
        mapEquals(other.filters, filters) &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(
        page,
        offset,
        pageSize,
        cursor,
        search,
        Object.hashAll(filters.keys),
        Object.hashAll(filters.values),
        sort,
      );

  @override
  String toString() {
    return 'SmartPaginationRequest(page: $page, offset: $offset, pageSize: $pageSize, cursor: $cursor, search: $search, filters: $filters, sort: $sort)';
  }
}
