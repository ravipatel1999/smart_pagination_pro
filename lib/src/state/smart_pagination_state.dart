import 'package:flutter/foundation.dart';

import '../errors/smart_pagination_error.dart';
import '../models/smart_pagination_enums.dart';
import '../models/smart_sort.dart';

/// Strongly typed immutable state model representing the current pagination status and data.
@immutable
class SmartPaginationState<T> {
  /// Creates a [SmartPaginationState] instance.
  SmartPaginationState({
    required List<T> items,
    required this.status,
    required this.currentPage,
    required this.currentOffset,
    required this.pageSize,
    this.totalItems,
    this.hasMore = true,
    this.search,
    Map<String, dynamic> filters = const <String, dynamic>{},
    this.sort,
    this.nextCursor,
    this.error,
    this.stackTrace,
  })  : _items = List<T>.unmodifiable(items),
        filters = Map<String, dynamic>.unmodifiable(filters);

  /// Factory helper to generate initial empty state.
  factory SmartPaginationState.initial({
    required int initialPage,
    required int initialOffset,
    required int pageSize,
  }) {
    return SmartPaginationState<T>(
      items: const [],
      status: SmartPaginationStatus.initial,
      currentPage: initialPage,
      currentOffset: initialOffset,
      pageSize: pageSize,
      hasMore: true,
    );
  }

  final List<T> _items;

  /// Unmodifiable view of loaded items.
  List<T> get items => _items;

  /// Current pagination status.
  final SmartPaginationStatus status;

  /// Current page index (1-based or 0-based based on configuration).
  final int currentPage;

  /// Current record offset index.
  final int currentOffset;

  /// Number of requested items per page.
  final int pageSize;

  /// Total item count across all pages if reported by data source.
  final int? totalItems;

  /// Whether more pages are available to be loaded.
  final bool hasMore;

  /// Active search query string.
  final String? search;

  /// Active filters map.
  final Map<String, dynamic> filters;

  /// Active sorting specification.
  final SmartSort? sort;

  /// Current cursor token for cursor pagination.
  final dynamic nextCursor;

  /// Error object if status is [SmartPaginationStatus.failure].
  final SmartPaginationError? error;

  /// StackTrace associated with error if present.
  final StackTrace? stackTrace;

  /// Convenience getters.
  bool get isLoading => status == SmartPaginationStatus.loading;
  bool get isLoadingMore => status == SmartPaginationStatus.loadingMore;
  bool get isRefreshing => status == SmartPaginationStatus.refreshing;
  bool get isSuccess => status == SmartPaginationStatus.success;
  bool get isEmpty => status == SmartPaginationStatus.empty;
  bool get isFailure => status == SmartPaginationStatus.failure;

  /// Calculates total pages count if totalItems is known.
  int? get totalPages {
    if (totalItems == null || pageSize <= 0) return null;
    return (totalItems! / pageSize).ceil();
  }

  /// Creates a copy of this state with specified fields updated.
  SmartPaginationState<T> copyWith({
    List<T>? items,
    SmartPaginationStatus? status,
    int? currentPage,
    int? currentOffset,
    int? pageSize,
    int? Function()? totalItems,
    bool? hasMore,
    String? Function()? search,
    Map<String, dynamic>? filters,
    SmartSort? Function()? sort,
    dynamic Function()? nextCursor,
    SmartPaginationError? Function()? error,
    StackTrace? Function()? stackTrace,
  }) {
    return SmartPaginationState<T>(
      items: items ?? _items,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      currentOffset: currentOffset ?? this.currentOffset,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems != null ? totalItems() : this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      search: search != null ? search() : this.search,
      filters: filters ?? this.filters,
      sort: sort != null ? sort() : this.sort,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      error: error != null ? error() : this.error,
      stackTrace: stackTrace != null ? stackTrace() : this.stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartPaginationState<T> &&
        listEquals(other._items, _items) &&
        other.status == status &&
        other.currentPage == currentPage &&
        other.currentOffset == currentOffset &&
        other.pageSize == pageSize &&
        other.totalItems == totalItems &&
        other.hasMore == hasMore &&
        other.search == search &&
        mapEquals(other.filters, filters) &&
        other.sort == sort &&
        other.nextCursor == nextCursor &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(_items),
        status,
        currentPage,
        currentOffset,
        pageSize,
        totalItems,
        hasMore,
        search,
        Object.hashAll(filters.keys),
        Object.hashAll(filters.values),
        sort,
        nextCursor,
        error,
      );

  @override
  String toString() {
    return 'SmartPaginationState<$T>(status: $status, itemsCount: ${_items.length}, page: $currentPage, offset: $currentOffset, totalItems: $totalItems, hasMore: $hasMore, search: $search)';
  }
}
