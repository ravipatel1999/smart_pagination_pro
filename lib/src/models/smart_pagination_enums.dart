/// Defines the strategy used to request paginated data from an asynchronous source.
enum PaginationStrategy {
  /// Page-based pagination (e.g., `?page=1&limit=20`).
  page,

  /// Offset-based pagination (e.g., `?offset=0&limit=20`).
  offset,

  /// Cursor-based pagination (e.g., `?cursor=abc123&limit=20`).
  cursor,
}

/// Defines the display mode for paginated user interfaces.
enum PaginationDisplayMode {
  /// Traditional numbered pagination bar mode.
  pagination,

  /// Infinite scrolling mode that auto-fetches next page near bottom threshold.
  infiniteScroll,
}

/// Represents the status of pagination execution within [SmartPaginationState].
enum SmartPaginationStatus {
  /// Initial uninitialized state before any page request is made.
  initial,

  /// Primary loading state during the first page fetch.
  loading,

  /// Data successfully loaded and non-empty.
  success,

  /// Query returned no results on initial load.
  empty,

  /// Fetching the next page while keeping existing items visible.
  loadingMore,

  /// Refreshing first page while keeping existing items visible.
  refreshing,

  /// Primary or next-page fetch failed with an error.
  failure,
}

/// Controls the responsive layout mode of [SmartPaginationBar].
enum PaginationLayout {
  /// Automatically toggles layout based on available parent constraints width.
  auto,

  /// Compact mobile layout showing page numbers count (e.g., `← 2 / 10 →`).
  compact,

  /// Standard tablet/mobile layout with page numbers.
  standard,

  /// Expanded desktop layout showing items range, page numbers, and size selector.
  expanded,
}
