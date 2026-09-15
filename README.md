# Smart Pagination Pro (`smart_pagination_pro`)

🚀 **Production-grade, highly configurable, zero-external-dependency Flutter pagination framework.**

Designed for real-world enterprise Flutter applications. Supports **Page**, **Offset**, and **Cursor** pagination strategies across any async data source (REST APIs, GraphQL, Firebase, SQLite, Isar, etc.) and integrates seamlessly with BLoC, Riverpod, Provider, GetX, or standard Flutter state management.

---

## Key Features

* ⚡ **3 Pagination Strategies**: Page-based (`?page=1`), Offset-based (`?offset=20`), and Cursor-based (`?cursor=xyz`).
* 📱 **Infinite Scroll & Prefetching**: Automatic background page prefetching based on configurable threshold (`prefetchDistance: 500`).
* 🛡️ **Race-Condition & Stale Response Safety**: Query generation token tracking ensures out-of-order API responses never overwrite newer data.
* 🔍 **Search Debouncing**: Built-in timer debouncer (`searchDebounceDuration`) with automatic pagination reset.
* 🎛️ **Filtering & Sorting**: Multi-filter management (`setFilter`, `setFilters`) and sorting (`SmartSort`).
* 🔒 **Request Deduplication**: Prevents duplicate concurrent API requests for identical pagination keys.
* ✨ **Built-In Lightweight Shimmer**: Zero-dependency customizable skeleton shimmer animation (`SmartShimmer`, `showShimmer: true`).
* 📐 **Responsive Material 3 UI**: Adaptive widgets (`SmartPaginatedList`, `SmartPaginatedGrid`, `SmartPaginationBar`) with compact, standard, and expanded modes for Mobile, Tablet, Desktop, and Web.
* 🌗 **Theme & Dark Mode Ready**: Inherits `Theme.of(context)` without hardcoded color constraints.
* ♿ **Accessibility Support**: Full semantic labels, screen reader text, keyboard focus states, and touch targets.

---

## Installation

Add `smart_pagination_pro` to your `pubspec.yaml`:

```yaml
dependencies:
  smart_pagination_pro: ^1.0.0
```

---

## Quick Start

### 1. Beginner-Friendly Simple API

For standard use cases, `SmartPaginatedList.simple` manages controller creation and lifecycle automatically:

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

For complex features like search, multi-filters, sorting, or BLoC integration:

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

## State Management Integration

`smart_pagination_pro` does not enforce BLoC, Provider, Riverpod, or GetX. `SmartPaginationController<T>` extends Flutter's built-in `ChangeNotifier` and implements `ValueListenable<SmartPaginationState<T>>`.

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

## API Reference

### Core Public Exports

* `SmartPaginationController<T>`: Main controller for triggering queries, resets, searches, and state updates.
* `SmartPaginationState<T>`: Immutable state containing `items`, `status`, `currentPage`, `currentOffset`, `pageSize`, `totalItems`, `hasMore`, `search`, `filters`, `sort`, `nextCursor`, and `error`.
* `SmartPaginationRequest`: Generic request model passed into the `fetch` callback.
* `SmartPageResult<T>`: Result container returned by data source `fetch` functions.
* `SmartPaginatedList<T>`: Paginated `ListView` with built-in infinite scroll and shimmer support.
* `SmartPaginatedGrid<T>`: Paginated `GridView` supporting fixed or maximum cross-axis layout.
* `SmartPaginationBar<T>`: Responsive Material 3 pagination control bar with compact, standard, and expanded modes.

---

## License

MIT License. Free to use in commercial and open-source applications.
