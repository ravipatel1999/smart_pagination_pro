## 1.0.0

* Initial production release of `smart_pagination_pro`.
* Feature: Support for Page-based, Offset-based, and Cursor-based pagination strategies.
* Feature: Infinite scrolling UI mode with customizable `prefetchDistance` threshold.
* Feature: Viewport auto-filling (`autoFillViewport` and `maxAutoFillPages`).
* Feature: Reactive, framework-agnostic `SmartPaginationController<T>` extending `ChangeNotifier`.
* Feature: Search debouncing (`searchDebounceDuration`) with token generation race-condition protection.
* Feature: Multi-filter management (`setFilter`, `setFilters`, `clearFilters`) and sorting (`SmartSort`).
* Feature: Request key deduplication and optional item deduplication (`deduplicateItems`).
* Feature: Built-in, zero-dependency customizable Shimmer loading (`SmartShimmer`, `SmartShimmerList`).
* Feature: Responsive Material 3 widgets (`SmartPaginatedList`, `SmartPaginatedGrid`, `SmartPaginationBar`).
* Feature: Structured error handling with `SmartPaginationError` and `SmartPaginationErrorType`.
* Feature: Full state immutability with `SmartPaginationState<T>`.
