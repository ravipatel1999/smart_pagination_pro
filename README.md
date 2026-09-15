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
  smart_pagination_pro: ^1.0.3
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

`smart_pagination_pro` is completely state-management agnostic. It does not enforce any third-party framework such as BLoC, Cubit, Provider, Riverpod, or GetX.

Because `SmartPaginationController<T>` extends Flutter's built-in `ChangeNotifier` and implements `ValueListenable<SmartPaginationState<T>>`, it seamlessly integrates with any Flutter state management solution or works zero-dependency out of the box.

> [!NOTE]
> Packages like `flutter_bloc`, `provider`, `flutter_riverpod`, and `get` are application-level state management libraries. They are **not** dependencies of `smart_pagination_pro`. `smart_pagination_pro` remains completely zero-dependency for state management.

---

### 📊 State Management Comparison Table

| Architecture / Library | External Dependency | Best Use Case | Setup Complexity |
|---|---|---|---|
| **Plain `StatefulWidget` / `ChangeNotifier`** | None (Built-in) | Simple apps, quick prototypes, component-level lists | Low ⚡ |
| **`ValueListenableBuilder`** | None (Built-in) | Direct reactive UI rebuilding without external state containers | Lowest ⚡⚡ |
| **BLoC (`flutter_bloc`)** | `flutter_bloc` | Strict event-driven enterprise architecture & team workflows | Medium 🛠️ |
| **Cubit (`flutter_bloc`)** | `flutter_bloc` | Method-based state management with predictable state streams | Low/Medium 🛠️ |
| **Provider (`provider`)** | `provider` | Standard Flutter dependency injection & scoped controllers | Low ⚡ |
| **Riverpod (`flutter_riverpod`)** | `flutter_riverpod` | Modern compile-safe dependency injection & global scope | Low/Medium ⚡ |
| **GetX (`get`)** | `get` | Fast route/state binding with minimal boilerplate | Low ⚡ |

---

### 1. Plain Flutter / `ChangeNotifier` (Zero Dependency)

The simplest approach using a standard `StatefulWidget`. Pass `controller` directly to `SmartPaginatedList`. `SmartPaginatedList` automatically listens to controller notifications and rebuilds when state changes.

```dart
import 'package:flutter/material.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

class Patient {
  final String id;
  final String name;
  final String department;

  const Patient({
    required this.id,
    required this.name,
    required this.department,
  });
}

class PatientListView extends StatefulWidget {
  const PatientListView({super.key});

  @override
  State<PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> {
  late final SmartPaginationController<Patient> controller;

  @override
  void initState() {
    super.initState();
    controller = SmartPaginationController<Patient>(
      pageSize: 20,
      strategy: PaginationStrategy.page,
      fetch: (request) async {
        final response = await patientApi.getPatients(
          page: request.page,
          limit: request.pageSize,
          search: request.search,
          department: request.filters['department'],
        );
        return SmartPageResult(
          items: response.items,
          totalItems: response.total,
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: controller.search,
          ),
        ),
        Expanded(
          child: SmartPaginatedList<Patient>(
            controller: controller,
            showShimmer: true,
            itemBuilder: (context, patient, index) {
              return ListTile(
                title: Text(patient.name),
                subtitle: Text(patient.department),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

---

### 2. `ValueListenableBuilder` (Zero Dependency Reactive UI)

Since `SmartPaginationController<T>` implements `ValueListenable<SmartPaginationState<T>>`, you can build completely reactive custom headers, counters, or total record indicators without importing any state management packages:

```dart
class PatientHeaderWidget extends StatelessWidget {
  final SmartPaginationController<Patient> controller;

  const PatientHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPaginationState<Patient>>(
      valueListenable: controller,
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Text('Loading patients...');
        }
        return Text(
          'Showing ${state.items.length} of ${state.totalItems ?? 'many'} patients',
          style: Theme.of(context).textTheme.titleSmall,
        );
      },
    );
  }
}
```

---

### 3. BLoC Integration (`flutter_bloc`)

In BLoC pattern, map UI user actions to Events and emit new pagination states using `SmartPaginationController`.

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

// --- Events ---
abstract class PatientEvent {}

class LoadPatientsRequested extends PatientEvent {}
class SearchPatientsQueryChanged extends PatientEvent {
  final String query;
  SearchPatientsQueryChanged(this.query);
}
class FilterPatientDepartmentChanged extends PatientEvent {
  final String? department;
  FilterPatientDepartmentChanged(this.department);
}
class RefreshPatientsRequested extends PatientEvent {}

// --- BLoC ---
class PatientBloc extends Bloc<PatientEvent, SmartPaginationState<Patient>> {
  final PatientApi api;
  late final SmartPaginationController<Patient> controller;

  PatientBloc({required this.api})
      : super(SmartPaginationState<Patient>.initial()) {
    controller = SmartPaginationController<Patient>(
      pageSize: 20,
      fetch: (request) async {
        final res = await api.getPatients(
          page: request.page,
          limit: request.pageSize,
          search: request.search,
          department: request.filters['department'],
        );
        return SmartPageResult(items: res.items, totalItems: res.total);
      },
      onStateChanged: (newState) => add(_PaginationStateUpdated(newState)),
    );

    on<_PaginationStateUpdated>((event, emit) => emit(event.state));
    on<LoadPatientsRequested>((event, emit) => controller.loadInitial());
    on<SearchPatientsQueryChanged>((event, emit) => controller.search(event.query));
    on<FilterPatientDepartmentChanged>((event, emit) => controller.setFilter('department', event.department));
    on<RefreshPatientsRequested>((event, emit) => controller.refresh());
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}

class _PaginationStateUpdated extends PatientEvent {
  final SmartPaginationState<Patient> state;
  _PaginationStateUpdated(this.state);
}

// --- UI View ---
class PatientBlocView extends StatelessWidget {
  const PatientBlocView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloc, SmartPaginationState<Patient>>(
      builder: (context, state) {
        final bloc = context.read<PatientBloc>();
        return Column(
          children: [
            TextField(
              onChanged: (q) => bloc.add(SearchPatientsQueryChanged(q)),
            ),
            Expanded(
              child: SmartPaginatedList<Patient>(
                controller: bloc.controller,
                itemBuilder: (context, patient, index) {
                  return ListTile(title: Text(patient.name));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

---

### 4. Cubit Integration (`flutter_bloc`)

Using `Cubit` simplifies event mapping. Forward controller state changes via `onStateChanged`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

class PatientCubit extends Cubit<SmartPaginationState<Patient>> {
  final PatientApi api;
  late final SmartPaginationController<Patient> controller;

  PatientCubit({required this.api})
      : super(SmartPaginationState<Patient>.initial()) {
    controller = SmartPaginationController<Patient>(
      pageSize: 20,
      fetch: (request) async {
        final res = await api.getPatients(
          page: request.page,
          limit: request.pageSize,
          search: request.search,
          department: request.filters['department'],
        );
        return SmartPageResult(items: res.items, totalItems: res.total);
      },
      onStateChanged: (newState) => emit(newState),
    );
    controller.loadInitial();
  }

  void search(String query) => controller.search(query);
  void filterDepartment(String? dept) => controller.setFilter('department', dept);
  void refresh() => controller.refresh();

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}

class PatientCubitView extends StatelessWidget {
  const PatientCubitView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCubit, SmartPaginationState<Patient>>(
      builder: (context, state) {
        final cubit = context.read<PatientCubit>();
        return SmartPaginatedList<Patient>(
          controller: cubit.controller,
          itemBuilder: (context, patient, index) {
            return ListTile(
              title: Text(patient.name),
              subtitle: Text(patient.department),
            );
          },
        );
      },
    );
  }
}
```

---

### 5. Provider Integration (`provider`)

Provide `SmartPaginationController<T>` directly through `ChangeNotifierProvider`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

class PatientProviderScreen extends StatelessWidget {
  const PatientProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmartPaginationController<Patient>>(
      create: (_) => SmartPaginationController<Patient>(
        pageSize: 20,
        fetch: (request) async {
          final res = await patientApi.getPatients(
            page: request.page,
            limit: request.pageSize,
            search: request.search,
          );
          return SmartPageResult(items: res.items, totalItems: res.total);
        },
      )..loadInitial(),
      child: Consumer<SmartPaginationController<Patient>>(
        builder: (context, controller, child) {
          return Column(
            children: [
              TextField(
                onChanged: controller.search,
                decoration: const InputDecoration(hintText: 'Search...'),
              ),
              Expanded(
                child: SmartPaginatedList<Patient>(
                  controller: controller,
                  itemBuilder: (context, patient, index) {
                    return ListTile(title: Text(patient.name));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

### 6. Riverpod Integration (`flutter_riverpod`)

Create a Riverpod `ChangeNotifierProvider` for `SmartPaginationController<Patient>`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

final patientPaginationProvider = ChangeNotifierProvider.autoDispose<SmartPaginationController<Patient>>((ref) {
  final controller = SmartPaginationController<Patient>(
    pageSize: 20,
    fetch: (request) async {
      final res = await patientApi.getPatients(
        page: request.page,
        limit: request.pageSize,
        search: request.search,
      );
      return SmartPageResult(items: res.items, totalItems: res.total);
    },
  );
  controller.loadInitial();
  return controller;
});

class PatientRiverpodWidget extends ConsumerWidget {
  const PatientRiverpodWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(patientPaginationProvider);

    return Column(
      children: [
        TextField(
          onChanged: (query) => ref.read(patientPaginationProvider).search(query),
          decoration: const InputDecoration(hintText: 'Search patients...'),
        ),
        Expanded(
          child: SmartPaginatedList<Patient>(
            controller: controller,
            itemBuilder: (context, patient, index) {
              return ListTile(
                title: Text(patient.name),
                subtitle: Text(patient.department),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

---

### 7. GetX Integration (`get`)

Wrap `SmartPaginationController` inside a `GetxController`:

```dart
import 'package:get/get.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

class PatientGetXController extends GetxController {
  final PatientApi api;
  late final SmartPaginationController<Patient> paginationController;

  PatientGetXController({required this.api});

  @override
  void onInit() {
    super.onInit();
    paginationController = SmartPaginationController<Patient>(
      pageSize: 20,
      fetch: (request) async {
        final res = await api.getPatients(
          page: request.page,
          limit: request.pageSize,
          search: request.search,
        );
        return SmartPageResult(items: res.items, totalItems: res.total);
      },
      onStateChanged: (_) => update(), // Trigger GetBuilder update
    );
    paginationController.loadInitial();
  }

  void search(String query) => paginationController.search(query);
  void refresh() => paginationController.refresh();

  @override
  void onClose() {
    paginationController.dispose();
    super.onClose();
  }
}

class PatientGetXView extends StatelessWidget {
  const PatientGetXView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientGetXController>(
      init: PatientGetXController(api: patientApi),
      builder: (controller) {
        return Column(
          children: [
            TextField(
              onChanged: controller.search,
              decoration: const InputDecoration(hintText: 'Search patients...'),
            ),
            Expanded(
              child: SmartPaginatedList<Patient>(
                controller: controller.paginationController,
                itemBuilder: (context, patient, index) {
                  return ListTile(title: Text(patient.name));
                },
              ),
            ),
          ],
        );
      },
    );
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
