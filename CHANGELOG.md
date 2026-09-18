## 2.0.0

* Feature: Major release introducing Level 1 Simple Pagination API widget (`SmartPagination`) for instant, stateless/state-agnostic pagination with zero setup.
* Feature: Auto-calculated `totalPages` based on `totalItems` and `pageSize`.
* Feature: Added First (<<) and Last (>>) page navigation buttons (`showFirstLastButtons`).
* Feature: Added accessible keyboard shortcut navigation (`enableKeyboardNavigation`).
* Feature: Enhanced `SmartPaginationThemeData` with `fromTheme` factory constructor and extensive color/style properties.
* Feature: Added `GlobalPagination` compatibility widget wrapper with `@Deprecated` annotation for smooth migration.
* Architecture: Unified Level 1 (`SmartPagination`) and Level 2 (`SmartPaginationBar` + `SmartPaginationController<T>`) onto the same internal UI pagination engine.
* Documentation & Examples: Complete overhaul with generic real-world developer examples (`User`, `Product`, `Order`, `Article`, `Employee`, `Transaction`) and zero domain-specific healthcare terms.

## 1.0.4

* Feature: Comprehensive State Management Integration guides (Plain Flutter/ChangeNotifier, ValueListenableBuilder, BLoC, Cubit, Provider, Riverpod, GetX).
* Documentation: Added State Management Comparison Table and integration examples using real controller APIs.

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
