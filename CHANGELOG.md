## 1.0.4

* Feature: Comprehensive State Management Integration guides (Plain Flutter/ChangeNotifier, ValueListenableBuilder, BLoC, Cubit, Provider, Riverpod, GetX).
* Documentation: Added State Management Comparison Table and Patient Directory integration examples using real controller APIs.

## 1.0.3

* Feature: Enhanced pub.dev documentation featuring high-resolution feature showcase banner.
* Feature: Added prominent Infinite Scroll, Scroll Pagination, Load More, API Pagination, and responsive List/Grid layout guides.
* Fix: Responsive horizontal scroll optimization for `SmartPaginationBar` on narrow mobile screens.

## 1.0.2

* Fix: Update README showcase image URL to absolute GitHub raw URL for 100% pub.dev rendering compatibility.

## 1.0.1

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
