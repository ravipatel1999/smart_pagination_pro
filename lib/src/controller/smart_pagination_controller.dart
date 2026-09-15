import 'dart:async';
import 'package:flutter/foundation.dart';

import '../errors/smart_pagination_error.dart';
import '../models/smart_page_result.dart';
import '../models/smart_pagination_enums.dart';
import '../models/smart_pagination_request.dart';
import '../models/smart_sort.dart';
import '../state/smart_pagination_state.dart';
import '../utils/request_coordinator.dart';
import '../utils/search_debouncer.dart';

/// Function signature for fetching paginated data from an async data source.
typedef SmartPageFetch<T> = FutureOr<SmartPageResult<T>> Function(
    SmartPaginationRequest request);

/// Reusable, lightweight, production-grade pagination controller.
///
/// Controls pagination state, search debouncing, request deduplication,
/// race-condition protection, filters, sorting, and lifecycle management.
class SmartPaginationController<T> extends ChangeNotifier
    implements ValueListenable<SmartPaginationState<T>> {
  /// Creates a [SmartPaginationController].
  SmartPaginationController({
    required this.fetch,
    int pageSize = 20,
    this.strategy = PaginationStrategy.page,
    this.initialPage = 1,
    this.initialOffset = 0,
    this.prefetchDistance = 500.0,
    Duration searchDebounceDuration = const Duration(milliseconds: 400),
    this.autoFillViewport = false,
    this.maxAutoFillPages = 3,
    this.deduplicateItems = false,
    this.itemKey,
    this.cacheEnabled = false,
    this.maxAutomaticRetries = 0,
    this.onStateChanged,
    this.onError,
    this.onPageLoaded,
    this.onLoadMore,
    this.onRefresh,
    this.onEmpty,
    this.onItemCountChanged,
  })  : _pageSize = pageSize,
        _searchDebouncer = SearchDebouncer(delay: searchDebounceDuration) {
    if (_pageSize <= 0) {
      throw SmartPaginationError(
        type: SmartPaginationErrorType.configuration,
        message: 'pageSize must be greater than 0, received: $_pageSize',
      );
    }
    _state = SmartPaginationState<T>.initial(
      initialPage: initialPage,
      initialOffset: initialOffset,
      pageSize: _pageSize,
    );
  }

  /// Asynchronous data source fetch callback.
  final SmartPageFetch<T> fetch;

  /// Strategy used for pagination (page, offset, or cursor).
  final PaginationStrategy strategy;

  /// Starting page index (1 or 0 based on target backend API).
  final int initialPage;

  /// Starting record offset index.
  final int initialOffset;

  /// Distance from scroll bottom in logical pixels to trigger next page fetch.
  final double prefetchDistance;

  /// Automatically fetch extra pages if viewport is not initially filled.
  final bool autoFillViewport;

  /// Max consecutive auto-fill page fetches allowed.
  final int maxAutoFillPages;

  /// Whether to filter out duplicate items based on [itemKey] or object equality.
  final bool deduplicateItems;

  /// Custom item key generator for deduplication.
  final Object Function(T item)? itemKey;

  /// Optional in-memory cache toggle for completed page queries.
  final bool cacheEnabled;

  /// Maximum automatic retry attempts on network error (defaults to 0).
  final int maxAutomaticRetries;

  /// Callbacks
  final void Function(SmartPaginationState<T> state)? onStateChanged;
  final void Function(SmartPaginationError error)? onError;
  final void Function(SmartPageResult<T> result, int page)? onPageLoaded;
  final void Function(int page)? onLoadMore;
  final void Function()? onRefresh;
  final void Function()? onEmpty;
  final void Function(int count)? onItemCountChanged;

  int _pageSize;
  final SearchDebouncer _searchDebouncer;
  final RequestCoordinator _coordinator = RequestCoordinator();
  final Map<String, SmartPageResult<T>> _queryCache = {};

  late SmartPaginationState<T> _state;
  bool _isDisposed = false;
  int _autoFillCount = 0;
  int _retryAttempts = 0;

  @override
  SmartPaginationState<T> get value => _state;

  /// Current pagination state.
  SmartPaginationState<T> get state => _state;

  /// Configured page size.
  int get pageSize => _pageSize;

  /// Whether controller is disposed.
  bool get isDisposed => _isDisposed;

  /// Helper to safely update state and notify listeners.
  void _updateState(SmartPaginationState<T> newState) {
    if (_isDisposed) return;
    final previousCount = _state.items.length;
    _state = newState;
    notifyListeners();

    onStateChanged?.call(_state);

    if (_state.error != null) {
      onError?.call(_state.error!);
    }

    if (_state.items.length != previousCount) {
      onItemCountChanged?.call(_state.items.length);
    }
  }

  /// Builds a [SmartPaginationRequest] for the current query parameters and target page/offset.
  SmartPaginationRequest _buildRequest({
    required int page,
    required int offset,
    dynamic cursor,
  }) {
    return SmartPaginationRequest(
      page: page,
      offset: offset,
      pageSize: _pageSize,
      cursor: cursor,
      search: _state.search,
      filters: _state.filters,
      sort: _state.sort,
    );
  }

  /// Evaluates whether more items are available based on result data and response length.
  bool _determineHasMore(
      SmartPageResult<T> result, SmartPaginationRequest req) {
    if (result.hasMore != null) {
      return result.hasMore!;
    }
    if (strategy == PaginationStrategy.cursor) {
      return result.nextCursor != null;
    }
    if (result.totalItems != null) {
      final loadedSoFar = (strategy == PaginationStrategy.page)
          ? (req.page - initialPage + 1) * req.pageSize
          : req.offset + result.items.length;
      return loadedSoFar < result.totalItems!;
    }
    return result.items.length >= _pageSize;
  }

  /// Applies item deduplication if enabled.
  List<T> _deduplicate(List<T> rawItems) {
    if (!deduplicateItems) return rawItems;
    final seen = <Object>{};
    final result = <T>[];
    for (final item in rawItems) {
      final key = itemKey != null ? itemKey!(item) : item as Object;
      if (seen.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  /// Triggers initial first page load.
  Future<void> loadInitial() async {
    if (_isDisposed) return;
    final genToken = _coordinator.nextGeneration();
    _autoFillCount = 0;
    _retryAttempts = 0;

    _updateState(_state.copyWith(
      status: SmartPaginationStatus.loading,
      currentPage: initialPage,
      currentOffset: initialOffset,
      nextCursor: () => null,
      error: () => null,
      stackTrace: () => null,
    ));

    await _executeFetch(
      page: initialPage,
      offset: initialOffset,
      cursor: null,
      genToken: genToken,
      isNextPage: false,
      isRefresh: false,
    );
  }

  /// Alias for [loadInitial].
  Future<void> loadFirstPage() => loadInitial();

  /// Loads the next page of items.
  Future<void> loadNextPage() async {
    if (_isDisposed ||
        !_state.hasMore ||
        _state.isLoading ||
        _state.isLoadingMore ||
        _state.isRefreshing) {
      return;
    }

    final nextPage = _state.currentPage + 1;
    final nextOffset = _state.currentOffset + _pageSize;
    final cursor = _state.nextCursor;
    final genToken = _coordinator.currentGeneration;

    _updateState(_state.copyWith(
      status: SmartPaginationStatus.loadingMore,
      error: () => null,
      stackTrace: () => null,
    ));

    onLoadMore?.call(nextPage);

    await _executeFetch(
      page: nextPage,
      offset: nextOffset,
      cursor: cursor,
      genToken: genToken,
      isNextPage: true,
      isRefresh: false,
    );
  }

  /// Refreshes data while maintaining search, filter, and sort context.
  Future<void> refresh() async {
    if (_isDisposed) return;
    final genToken = _coordinator.nextGeneration();
    _autoFillCount = 0;
    _retryAttempts = 0;

    _updateState(_state.copyWith(
      status: SmartPaginationStatus.refreshing,
      error: () => null,
      stackTrace: () => null,
    ));

    onRefresh?.call();

    await _executeFetch(
      page: initialPage,
      offset: initialOffset,
      cursor: null,
      genToken: genToken,
      isNextPage: false,
      isRefresh: true,
    );
  }

  /// Retries the last failed operation (initial load or next page load).
  Future<void> retry() async {
    if (_isDisposed || !_state.isFailure) return;

    if (_state.items.isEmpty) {
      await loadInitial();
    } else {
      await loadNextPage();
    }
  }

  /// Updates search query with debouncing and token protection.
  void search(String? query) {
    if (_isDisposed) return;
    final trimmed = query?.trim();
    final newQuery = (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;

    if (_state.search == newQuery) return;

    _searchDebouncer.run(() {
      if (_isDisposed) return;
      _updateState(_state.copyWith(
        search: () => newQuery,
        items: [],
      ));
      loadInitial();
    });
  }

  /// Sets a single filter key-value pair and resets pagination.
  void setFilter(String key, dynamic value) {
    final currentFilters = Map<String, dynamic>.from(_state.filters);
    if (value == null) {
      currentFilters.remove(key);
    } else {
      currentFilters[key] = value;
    }
    setFilters(currentFilters);
  }

  /// Replaces active filters map and resets pagination.
  void setFilters(Map<String, dynamic> newFilters) {
    if (_isDisposed) return;
    if (mapEquals(_state.filters, newFilters)) return;

    _searchDebouncer.cancel();
    _updateState(_state.copyWith(
      filters: newFilters,
      items: [],
    ));
    loadInitial();
  }

  /// Clears all active filters and resets pagination.
  void clearFilters() {
    if (_state.filters.isEmpty) return;
    setFilters(const <String, dynamic>{});
  }

  /// Sets active sorting parameter and resets pagination.
  void setSort(SmartSort? sort) {
    if (_isDisposed) return;
    if (_state.sort == sort) return;

    _searchDebouncer.cancel();
    _updateState(_state.copyWith(
      sort: () => sort,
      items: [],
    ));
    loadInitial();
  }

  /// Changes configured page size and resets pagination safely.
  void setPageSize(int newSize) {
    if (newSize <= 0) {
      throw SmartPaginationError(
        type: SmartPaginationErrorType.configuration,
        message: 'pageSize must be greater than 0, received: $newSize',
      );
    }
    if (_pageSize == newSize) return;

    _pageSize = newSize;
    _searchDebouncer.cancel();
    _updateState(_state.copyWith(
      pageSize: _pageSize,
      items: [],
    ));
    loadInitial();
  }

  /// Resets controller state to uninitialized defaults.
  void reset() {
    if (_isDisposed) return;
    _searchDebouncer.cancel();
    _coordinator.nextGeneration();
    _coordinator.clear();
    _queryCache.clear();
    _autoFillCount = 0;
    _retryAttempts = 0;

    _updateState(SmartPaginationState<T>.initial(
      initialPage: initialPage,
      initialOffset: initialOffset,
      pageSize: _pageSize,
    ));
  }

  /// Cancels pending debounces and invalidates current generation token.
  void cancelCurrentRequest() {
    _searchDebouncer.cancel();
    _coordinator.nextGeneration();
  }

  /// Evaluates if auto-filling viewport is required when initial page doesn't fill screen.
  void checkAutoFillViewport(double viewportExtent, double contentExtent) {
    if (_isDisposed ||
        !autoFillViewport ||
        !_state.hasMore ||
        _state.isLoading ||
        _state.isLoadingMore ||
        _autoFillCount >= maxAutoFillPages) {
      return;
    }

    if (contentExtent < viewportExtent) {
      _autoFillCount++;
      loadNextPage();
    }
  }

  /// Internal engine method executing the async fetch callback with deduplication & token checks.
  Future<void> _executeFetch({
    required int page,
    required int offset,
    required dynamic cursor,
    required int genToken,
    required bool isNextPage,
    required bool isRefresh,
  }) async {
    final request = _buildRequest(page: page, offset: offset, cursor: cursor);
    final reqKey = request.toDeduplicationKey(strategyName: strategy.name);

    if (!_coordinator.registerRequestKey(reqKey)) {
      return;
    }

    try {
      SmartPageResult<T> result;

      if (cacheEnabled && _queryCache.containsKey(reqKey)) {
        result = _queryCache[reqKey]!;
      } else {
        final rawResult = await fetch(request);
        result = rawResult;
        if (cacheEnabled) {
          _queryCache[reqKey] = result;
        }
      }

      _coordinator.releaseRequestKey(reqKey);

      if (_isDisposed || !_coordinator.isValidGeneration(genToken)) {
        return;
      }

      final newHasMore = _determineHasMore(result, request);
      final deduplicatedNewItems = _deduplicate(result.items);

      final List<T> updatedItems;
      if (isNextPage) {
        updatedItems = _deduplicate([..._state.items, ...deduplicatedNewItems]);
      } else {
        updatedItems = deduplicatedNewItems;
      }

      final SmartPaginationStatus newStatus;
      if (updatedItems.isEmpty) {
        newStatus = SmartPaginationStatus.empty;
        onEmpty?.call();
      } else {
        newStatus = SmartPaginationStatus.success;
      }

      _retryAttempts = 0;
      _updateState(_state.copyWith(
        items: updatedItems,
        status: newStatus,
        currentPage: page,
        currentOffset: offset,
        totalItems: () => result.totalItems ?? _state.totalItems,
        hasMore: newHasMore,
        nextCursor: () => result.nextCursor,
        error: () => null,
        stackTrace: () => null,
      ));

      onPageLoaded?.call(result, page);
    } catch (e, st) {
      _coordinator.releaseRequestKey(reqKey);

      if (_isDisposed || !_coordinator.isValidGeneration(genToken)) {
        return;
      }

      final errorModel = SmartPaginationError.from(e, st);

      _updateState(_state.copyWith(
        status: SmartPaginationStatus.failure,
        error: () => errorModel,
        stackTrace: () => st,
      ));

      if (maxAutomaticRetries > 0 && _retryAttempts < maxAutomaticRetries) {
        _retryAttempts++;
        await Future<void>.delayed(
            Duration(milliseconds: 300 * _retryAttempts));
        if (!_isDisposed && _coordinator.isValidGeneration(genToken)) {
          await retry();
        }
      }
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _searchDebouncer.cancel();
    _coordinator.clear();
    _queryCache.clear();
    super.dispose();
  }
}
