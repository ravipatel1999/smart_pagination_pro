# Smart Pagination Pro 🚀

<p align="center">
  <img
    src="https://raw.githubusercontent.com/ravipatel1999/smart_pagination_pro/main/assets/smart_pagination_pro_showcase.png"
    alt="Smart Pagination Pro - Infinite Scroll, Scroll Pagination and Load More"
    width="100%"
  />
</p>

<p align="center">
  Production-ready Flutter pagination framework for Infinite Scroll,
  Scroll Pagination, Load More, API Pagination and more.
</p>

<p align="center">

[![pub package](https://img.shields.io/pub/v/smart_pagination_pro.svg)](https://pub.dev/packages/smart_pagination_pro)
[![likes](https://img.shields.io/pub/likes/smart_pagination_pro.svg)](https://pub.dev/packages/smart_pagination_pro)
[![popularity](https://img.shields.io/pub/popularity/smart_pagination_pro.svg)](https://pub.dev/packages/smart_pagination_pro)
[![GitHub stars](https://img.shields.io/github/stars/ravipatel1999/smart_pagination_pro.svg)](https://github.com/ravipatel1999/smart_pagination_pro)
[![license](https://img.shields.io/github/license/ravipatel1999/smart_pagination_pro.svg)](https://github.com/ravipatel1999/smart_pagination_pro)

</p>

---

## ✨ Key Features

- ♾️ **Infinite Scroll Pagination**: Automatically fetch the next page as the user scrolls near the bottom.
- 📜 **Scroll Pagination**: Seamless scroll-based pagination with automatic viewport prefetching.
- 🔄 **Load More Pagination**: Smooth pagination with inline footer load-more state and manual retry capability.
- 🌐 **Async / API Pagination**: Connect to any REST API, GraphQL query, Firebase Firestore, SQLite, or custom backend.
- 📄 **Page-based Pagination**: Standard page number strategy (`?page=1&pageSize=20`).
- 📊 **Offset-based Pagination**: Record offset strategy (`?offset=20&limit=20`).
- 🎯 **Cursor-based Pagination**: Keyset/cursor token strategy (`?cursor=abc123&limit=20`).
- 🔍 **Search with Debouncing**: Real-time async search query debouncing (`searchDebounceDuration`) with automatic pagination reset.
- 🎛️ **Filters**: Apply single or multiple key-value filters (`setFilter`, `setFilters`, `clearFilters`).
- ↕️ **Sorting**: Sort fields in ascending or descending order (`SmartSort`).
- 🔃 **Pull-to-Refresh**: Native pull-to-refresh integration keeping search, filter, and sort criteria intact.
- ⚡ **Configurable Prefetching**: Prefetch the next page before reaching the bottom (`prefetchDistance: 500`).
- 🛡️ **Race-Condition Protection**: Generation token tracking prevents out-of-order API responses from overwriting newer data.
- 🚫 **Duplicate Request Protection**: Deduplicates concurrent requests for identical query parameter keys.
- 💀 **Shimmer Loading**: Built-in, zero-dependency skeleton shimmer loader (`SmartShimmer`, `showShimmer: true`).
- ❌ **Error & Retry States**: Graceful error catching and retries without clearing existing data.
- 📱 **Responsive Mobile / Tablet / Desktop / Web**: Adaptive list, grid, and pagination bar layouts.
- 🌙 **Light & Dark Theme**: Inherits `Theme.of(context)` with full dark mode support.
- 📋 **Paginated List**: `SmartPaginatedList` with scroll listeners, pull-to-refresh, and customizable builders.
- 🔲 **Paginated Grid**: `SmartPaginatedGrid` with adaptive cross-axis layout.

---

## 📦 Installation

Add `smart_pagination_pro` to your `pubspec.yaml`:

```yaml
dependencies:
  smart_pagination_pro: ^1.0.1
```

---

## 🚀 Quick Start

### 1. Beginner-Friendly Simple API

For standard use cases, `SmartPaginatedList.simple` handles controller creation, lifecycle, and scroll listening automatically:

```dart
import 'package:flutter/material.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

class SimpleUserList extends StatelessWidget {
  const SimpleUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartPaginatedList<User>.simple(
      pageSize: 20,
      showShimmer: true,
      fetch: (request) async {
        final response = await userApi.getUsers(
          page: request.page,
          limit: request.pageSize,
        );
        return SmartPageResult<User>(
          items: response.users,
          totalItems: response.total,
        );
      },
      itemBuilder: (context, user, index) {
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      },
    );
  }
}
```

---

### 2. Advanced Controller Architecture

For full control over search, multi-filtering, sorting, or custom state management:

```dart
class AdvancedPatientDirectory extends StatefulWidget {
  const AdvancedPatientDirectory({super.key});

  @override
  State<AdvancedPatientDirectory> createState() => _AdvancedPatientDirectoryState();
}

class _AdvancedPatientDirectoryState extends State<AdvancedPatientDirectory> {
  late final SmartPaginationController<Patient> controller;

  @override
  void initState() {
    super.initState();
    controller = SmartPaginationController<Patient>(
      pageSize: 20,
      strategy: PaginationStrategy.page,
      prefetchDistance: 500,
      autoFillViewport: true,
      deduplicateItems: true,
      itemKey: (patient) => patient.id,
      fetch: (request) async {
        final response = await api.getPatients(
          page: request.page,
          limit: request.pageSize,
          search: request.search,
          department: request.filters['department'],
          sort: request.sort?.field,
        );
        return SmartPageResult(
          items: response.items,
          totalItems: response.totalCount,
        );
      },
    );
    controller.loadInitial();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input
        TextField(
          decoration: const InputDecoration(hintText: 'Search patients...'),
          onChanged: (query) => controller.search(query),
        ),

        // Filter Dropdown
        DropdownButton<String>(
          hint: const Text('Filter Department'),
          onChanged: (dept) => controller.setFilter('department', dept),
          items: const [
            DropdownMenuItem(value: 'Cardiology', child: Text('Cardiology')),
            DropdownMenuItem(value: 'Neurology', child: Text('Neurology')),
          ],
        ),

        // Responsive List View
        Expanded(
          child: SmartPaginatedList<Patient>(
            controller: controller,
            showShimmer: true,
            itemBuilder: (context, patient, index) {
              return PatientCard(patient: patient);
            },
          ),
        ),
      ],
    );
  }
}
```

---

## ♾️ Infinite Scroll

Smart Pagination Pro automatically requests the next page while the user approaches the end of the scrollable viewport.

```dart
SmartPaginatedList<Article>(
  controller: controller,
  displayMode: PaginationDisplayMode.infiniteScroll,
  itemBuilder: (context, article, index) => ArticleTile(article: article),
)
```

### Key Infinite Scroll Capabilities:
- **Automatic Prefetching**: Triggers `loadNextPage()` when the scroll position reaches `prefetchDistance` (default `500.0` logical pixels before the bottom).
- **Viewport Auto-Fill**: Automatically loads additional pages if initial results don't fill the viewport (`autoFillViewport: true`, bounded by `maxAutoFillPages`).
- **Last Page Detection**: Intelligently determines when no more data exists based on `hasMore`, `nextCursor`, or `totalItems`.
- **Duplicate Request Guard**: Deduplicates rapid scroll events so `loadNextPage()` is only called once per page key.
- **Inline Load More Footer**: Shows progress, error retry, or "You've reached the end" message at the bottom.

---

## 📜 Scroll Pagination & Load More

Smart Pagination Pro provides three flexible presentation patterns:

1. **Infinite Scroll**: Pages load automatically as the user scrolls near the bottom.
2. **Scroll Pagination**: Page numbers and range counts appear in an adaptive bottom bar (`SmartPaginationBar`).
3. **Manual Load More**: Configure custom footers or button triggers using `loadMoreErrorBuilder` and `loadingMoreBuilder`.

---

## 📄 Pagination Strategies

Smart Pagination Pro supports all 3 major API pagination strategies:

### 1. Page-based Pagination
Used when APIs expect page numbers (`page=1`, `page=2`).
```dart
SmartPaginationController<Item>(
  strategy: PaginationStrategy.page,
  initialPage: 1, // Supports 1-based or 0-based initial page
  pageSize: 20,
  fetch: (request) async => api.getItems(page: request.page, size: request.pageSize),
);
```

### 2. Offset-based Pagination
Used when APIs expect record offsets (`offset=0`, `offset=20`).
```dart
SmartPaginationController<Item>(
  strategy: PaginationStrategy.offset,
  initialOffset: 0,
  pageSize: 20,
  fetch: (request) async => api.getItems(offset: request.offset, limit: request.pageSize),
);
```

### 3. Cursor-based Pagination
Used for keyset pagination where backend returns an opaque cursor token (`nextCursor`).
```dart
SmartPaginationController<Item>(
  strategy: PaginationStrategy.cursor,
  pageSize: 20,
  fetch: (request) async {
    final res = await api.getItems(cursor: request.cursor, limit: request.pageSize);
    return SmartPageResult(items: res.items, nextCursor: res.nextCursorToken);
  },
);
```

---

## 🔍 Search + Pagination

Built-in search with automatic debouncing, query token protection, and pagination reset:

```dart
// Triggers debounced search (default 400ms delay)
controller.search('Flutter');

// Resets pagination, invalidates pending queries, and fetches Page 1
```

### Race-Condition Protection
If rapid queries (`"r"` -> `"ra"` -> `"ravi"`) complete out of order, the `RequestCoordinator` generation token discards stale responses, guaranteeing only the newest query results appear on screen.

---

## 📱 Responsive UI

Smart Pagination Pro adapts smoothly across **Mobile**, **Tablet**, **Desktop**, and **Web**:

- **`SmartPaginatedList<T>`**: Paginated `ListView` supporting infinite scroll, pull-to-refresh, custom item builders, and dividers.
- **`SmartPaginatedGrid<T>`**: Responsive `GridView` with `maxCrossAxisExtent` or fixed `crossAxisCount`.
- **`SmartPaginationBar<T>`**: Responsive bar with `PaginationLayout.auto` (switches between `compact` mobile layout, `standard` tablet layout, and `expanded` desktop layout with page-size selector).

---

## 🎨 UI States

Smart Pagination Pro manages all standard asynchronous state transitions:

| State | Visual Behavior |
|---|---|
| **Initial Loading** | Renders `SmartShimmerList` or `CircularProgressIndicator` |
| **Success** | Renders non-empty paginated item list or grid |
| **Loading More** | Keeps existing items visible; displays inline loader footer |
| **Refreshing** | Keeps existing items visible; triggers pull-to-refresh spinner |
| **Empty State** | Displays customizable empty state view (`emptyBuilder`) |
| **Error State** | Displays customizable error view (`errorBuilder`) with Retry button |
| **End of List** | Displays "You've reached the end" footer indicator |

---

## 🏗️ State Management Integration

`smart_pagination_pro` does not enforce BLoC, Provider, Riverpod, or GetX. `SmartPaginationController<T>` extends Flutter's `ChangeNotifier` and implements `ValueListenable<SmartPaginationState<T>>`.

### BLoC / Cubit Integration Example

```dart
class PatientCubit extends Cubit<SmartPaginationState<Patient>> {
  PatientCubit(this.api) : super(SmartPaginationState.initial(initialPage: 1, initialOffset: 0, pageSize: 20)) {
    controller = SmartPaginationController<Patient>(
      pageSize: 20,
      fetch: (req) => api.fetchPatients(req),
      onStateChanged: (newState) => emit(newState),
    );
  }

  final PatientApi api;
  late final SmartPaginationController<Patient> controller;

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
```

---

## 📖 API Reference

### Core Classes & Exports

* `SmartPaginationController<T>`: Main controller for triggering queries, resets, searches, filters, sorting, and state updates.
* `SmartPaginationState<T>`: Immutable state containing `items`, `status`, `currentPage`, `currentOffset`, `pageSize`, `totalItems`, `hasMore`, `search`, `filters`, `sort`, `nextCursor`, and `error`.
* `SmartPaginationRequest`: Request parameters model passed into `fetch`.
* `SmartPageResult<T>`: Result payload returned by user data source fetch functions.
* `SmartPaginatedList<T>`: Paginated list widget.
* `SmartPaginatedGrid<T>`: Paginated grid widget.
* `SmartPaginationBar<T>`: Material 3 responsive pagination bar widget.
* `SmartShimmer`: Built-in zero-dependency shimmer animation wrapper.

---

## 📄 License

MIT License. Free to use in commercial and open-source applications.
