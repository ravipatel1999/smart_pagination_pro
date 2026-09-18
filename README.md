# Smart Pagination Pro

Production-ready Flutter pagination for APIs, lists, grids, infinite scroll, search, filters, sorting, and responsive UIs — with zero dependency on external state-management libraries.

[![pub package](https://img.shields.io/pub/v/smart_pagination_pro.svg)](https://pub.dev/packages/smart_pagination_pro)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- ⚡ **Two Levels of Usage**: Simple direct widget (`SmartPagination`) for instant adoption or Advanced Controller (`SmartPaginationController<T>`) for API-driven state management.
- 🎯 **State-Management Agnostic**: Depends ONLY on Flutter SDK. Works seamlessly with `StatefulWidget`, `Provider`, `Riverpod`, `BLoC/Cubit`, `GetX`, `ValueListenableBuilder`, or any custom setup.
- 🌐 **3 Pagination Strategies**: Support for Page-based (`page`), Offset-based (`offset`), and Cursor-based (`cursor`) backend APIs.
- ♾️ **Infinite Scroll & Load More**: Built-in automatic infinite scroll with prefetching thresholds and viewport auto-fill.
- 🔍 **Search & Filters**: Instant search debouncing, key-value filter management, and multi-field sorting (`SmartSort`).
- 🛡️ **Race-Condition & Duplicate Protection**: Generation tokens prevent out-of-order API response overlaps and request key deduplication.
- 🎨 **Shimmer & Custom States**: Zero-dependency shimmer skeleton loaders, custom error state retry builders, and empty state fallbacks.
- 📱 **Responsive & Accessible**: Material 3 responsive layouts (Mobile / Tablet / Desktop) with full accessibility semantics, tooltips, and optional keyboard navigation (Arrow keys, Home, End).

---

## 📦 Installation

Add `smart_pagination_pro` to your `pubspec.yaml`:

```yaml
dependencies:
  smart_pagination_pro: ^2.0.0
```

Or run:

```bash
flutter pub add smart_pagination_pro
```

Import it in your Dart code:

```dart
import 'package:smart_pagination_pro/smart_pagination_pro.dart';
```

---

## 🚀 Quick Start (Simple API - Level 1)

For simple UI pagination without managing complex controllers:

```dart
SmartPagination(
  currentPage: currentPage,
  pageSize: pageSize,
  totalItems: totalItems,
  onPageChanged: (page) {
    setState(() {
      currentPage = page;
    });
    fetchUsers(page: page, size: pageSize);
  },
  onPageSizeChanged: (size) {
    setState(() {
      pageSize = size;
      currentPage = 1;
    });
    fetchUsers(page: 1, size: size);
  },
)
```

> **Note:** `totalPages` is automatically calculated internally (`(totalItems + pageSize - 1) ~/ pageSize`). You do NOT need to calculate or supply `totalPages` manually.

---

## 🎯 Simple API Configuration

All features can be toggled using intuitive `bool` properties:

```dart
SmartPagination(
  currentPage: currentPage,
  pageSize: pageSize,
  totalItems: totalItems,
  onPageChanged: (page) => loadPage(page),
  onPageSizeChanged: (size) => updatePageSize(size),

  showPageNumbers: true,         // Show numbered page buttons
  showPreviousNext: true,        // Show Previous and Next buttons
  showFirstLastButtons: true,    // Show First (<<) and Last (>>) page buttons
  showPageSizeSelector: true,    // Show page size dropdown
  showItemRange: true,           // Show "Showing 1–20 of 100 items"
  enableKeyboardNavigation: true,// Left/Right arrow keys & Home/End
  showCard: true,                // Wrap in styled card container
)
```

### Configuration Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `currentPage` | `int` | *required* | Current active 1-based page index. |
| `pageSize` | `int` | *required* | Number of items displayed per page. |
| `totalItems` | `int` | *required* | Total count of items across all pages. |
| `onPageChanged` | `ValueChanged<int>` | *required* | Fired when user selects a new page. |
| `onPageSizeChanged` | `ValueChanged<int>` | *required* | Fired when user selects a new page size. |
| `pageSizeOptions` | `List<int>` | `[10, 20, 50, 100]` | Dropdown page size choices. |
| `showPageNumbers` | `bool` | `true` | Show numeric page buttons. |
| `showPreviousNext` | `bool` | `true` | Show Previous/Next navigation. |
| `showFirstLastButtons` | `bool` | `false` | Show First (<<) and Last (>>) buttons. |
| `showPageSizeSelector` | `bool` | `true` | Show page size selector dropdown. |
| `showItemRange` | `bool` | `true` | Show item range count label. |
| `itemsLabel` | `String` | `'items'` | Plural item description label. |
| `maxVisiblePageButtons` | `int` | `5` | Max visible numbered page buttons. |
| `layout` | `PaginationLayout` | `PaginationLayout.auto` | Layout strategy (`auto`, `compact`, `standard`, `expanded`). |
| `enableKeyboardNavigation` | `bool` | `true` | Enable keyboard arrow controls when focused. |
| `showCard` | `bool` | `true` | Wrap controls inside styled card surface. |

---

## ⚡ Advanced API (Controller Driven - Level 2)

For full API pagination with search debouncing, filters, sorting, shimmer, and infinite scrolling:

```dart
// 1. Initialize Controller
final controller = SmartPaginationController<User>(
  pageSize: 20,
  fetch: (request) async {
    final response = await api.getUsers(
      page: request.page,
      limit: request.pageSize,
      search: request.search,
    );
    return SmartPageResult(
      items: response.items,
      totalItems: response.total,
    );
  },
);

// 2. Render Widget
SmartPaginatedList<User>(
  controller: controller,
  displayMode: PaginationDisplayMode.pagination,
  showShimmer: true,
  itemBuilder: (context, user, index) {
    return UserTile(user: user);
  },
)
```

---

## 🌐 API Pagination Integration

Integrate cleanly with any REST API, GraphQL query, or database call:

```dart
Future<SmartPageResult<Product>> fetchProducts(
  SmartPaginationRequest request,
) async {
  final response = await myApiClient.getProducts(
    page: request.page,
    limit: request.pageSize,
    search: request.search,
    category: request.filters['category'],
    sortBy: request.sort?.field,
    sortOrder: request.sort?.ascending == true ? 'asc' : 'desc',
  );

  return SmartPageResult<Product>(
    items: response.products,
    totalItems: response.totalCount,
  );
}
```

---

## 🔍 Search & Debouncing

Search query input is automatically debounced to prevent unnecessary server requests:

```dart
// Triggers debounced search (default: 400ms delay)
controller.search('john');

// Clear search
controller.search(null);
```

---

## 🎛️ Filters & Sorting

Set single or multiple filters and apply sorting parameters:

```dart
// Single filter
controller.setFilter('status', 'active');

// Multiple filters
controller.setFilters({
  'status': 'active',
  'department': 'Engineering',
});

// Clear all filters
controller.clearFilters();

// Apply sorting
controller.setSort(const SmartSort(field: 'name', ascending: true));
```

---

## 📄 Pagination Strategies

`SmartPaginationController` natively supports 3 pagination strategies:

```dart
// Page-based (page=1, page=2)
SmartPaginationController<User>(
  strategy: PaginationStrategy.page,
  fetch: fetchUsersByPage,
);

// Offset-based (offset=0, offset=20)
SmartPaginationController<Product>(
  strategy: PaginationStrategy.offset,
  fetch: fetchProductsByOffset,
);

// Cursor-based (cursor="eyJpZCI6MTB9")
SmartPaginationController<Transaction>(
  strategy: PaginationStrategy.cursor,
  fetch: fetchTransactionsByCursor,
);
```

---

## ♾️ Infinite Scroll & Load More

Switch from traditional page bar navigation to smooth infinite scrolling:

```dart
SmartPaginatedList<Article>(
  controller: controller,
  displayMode: PaginationDisplayMode.infiniteScroll,
  showShimmer: true,
  enablePullToRefresh: true,
  itemBuilder: (context, article, index) {
    return ArticleCard(article: article);
  },
)
```

---

## 📱 Responsive UI & Theme System

The UI automatically adapts across Mobile, Tablet, Desktop, and Flutter Web using `PaginationLayout.auto`.

Customize theme properties globally or per-widget:

```dart
SmartPaginationTheme(
  data: SmartPaginationThemeData(
    primaryColor: Colors.indigo,
    surfaceColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: MyApp(),
)
```

---

## 🧠 State Management Agnostic

> **Smart Pagination Pro is state-management agnostic.**

It depends solely on the Flutter SDK (`ChangeNotifier` / `ValueListenableBuilder`). You can use it effortlessly with any state management option:

### 1. StatefulWidget (Plain Flutter)
```dart
SmartPagination(
  currentPage: currentPage,
  pageSize: pageSize,
  totalItems: totalItems,
  onPageChanged: (p) => setState(() => currentPage = p),
  onPageSizeChanged: (s) => setState(() => pageSize = s),
)
```

### 2. ValueListenableBuilder
```dart
ValueListenableBuilder<SmartPaginationState<User>>(
  valueListenable: controller,
  builder: (context, state, child) {
    return Text('Loaded ${state.items.length} of ${state.totalItems}');
  },
)
```

### 3. Provider
```dart
ChangeNotifierProvider.value(
  value: controller,
  child: Consumer<SmartPaginationController<User>>(
    builder: (context, controller, child) {
      return SmartPaginatedList<User>(controller: controller, ...);
    },
  ),
)
```

### 4. Riverpod
```dart
final userControllerProvider = ChangeNotifierProvider((ref) {
  return SmartPaginationController<User>(fetch: fetchUsers);
});
```

### 5. BLoC / Cubit
```dart
class UserCubit extends Cubit<SmartPaginationState<User>> {
  final SmartPaginationController<User> controller;
  UserCubit(this.controller) : super(controller.state) {
    controller.addListener(() => emit(controller.state));
  }
}
```

### 6. GetX
```dart
class UserController extends GetxController {
  final pagination = SmartPaginationController<User>(fetch: fetchUsers);
}
```

---

## 🔄 Migration Guide (From GlobalPagination)

If you are migrating from `GlobalPagination` (or older versions), simply replace `GlobalPagination` with `SmartPagination`:

**Before:**
```dart
GlobalPagination(
  currentPage: vm.currentPage,
  pageSize: vm.rowsPerPage,
  totalItems: vm.currentTotalItems,
  totalPages: vm.totalPages,
  onPageChanged: (p) => vm.setPage(p),
  onRowsPerPageChanged: (r) => vm.setRowsPerPage(r),
)
```

**After:**
```dart
SmartPagination(
  currentPage: vm.currentPage,
  pageSize: vm.rowsPerPage,
  totalItems: vm.currentTotalItems,
  onPageChanged: vm.setPage,
  onPageSizeChanged: vm.setRowsPerPage,
)
```

*Note: `GlobalPagination` is retained as a `@Deprecated` compatibility wrapper so your existing code continues to compile without breaking.*

---

## 🧪 Testing

Run unit and widget tests:

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
