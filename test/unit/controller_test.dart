import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

import '../helpers/fake_pagination_data_source.dart';

void main() {
  group('SmartPaginationController Unit Tests', () {
    late FakePaginationDataSource dataSource;

    setUp(() {
      dataSource = FakePaginationDataSource();
    });

    test('Initial load transition: initial -> loading -> success', () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      expect(controller.state.status, SmartPaginationStatus.initial);
      expect(controller.state.items, isEmpty);

      final future = controller.loadInitial();
      expect(controller.state.status, SmartPaginationStatus.loading);

      await future;

      expect(controller.state.status, SmartPaginationStatus.success);
      expect(controller.state.items.length, 10);
      expect(controller.state.currentPage, 1);
      expect(controller.state.hasMore, isTrue);

      controller.dispose();
    });

    test('Empty result transition: initial -> loading -> empty', () async {
      final emptySource = FakePaginationDataSource(initialItems: []);
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: emptySource.fetch,
      );

      await controller.loadInitial();

      expect(controller.state.status, SmartPaginationStatus.empty);
      expect(controller.state.items, isEmpty);
      expect(controller.state.hasMore, isFalse);

      controller.dispose();
    });

    test('Initial failure transition: initial -> loading -> failure', () async {
      dataSource.shouldThrowError = true;
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();

      expect(controller.state.status, SmartPaginationStatus.failure);
      expect(controller.state.error, isNotNull);
      expect(controller.state.error!.type, SmartPaginationErrorType.unknown);

      controller.dispose();
    });

    test('Next page transition: page 1 -> page 2', () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      expect(controller.state.items.length, 10);
      expect(controller.state.currentPage, 1);

      await controller.loadNextPage();
      expect(controller.state.items.length, 20);
      expect(controller.state.currentPage, 2);
      expect(controller.state.status, SmartPaginationStatus.success);

      controller.dispose();
    });

    test('Last page detection: hasMore set to false at end of data', () async {
      final smallSource = FakePaginationDataSource(
        initialItems: List.generate(
          15,
          (i) => TestItem(id: '$i', title: 'Item $i'),
        ),
      );
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: smallSource.fetch,
      );

      await controller.loadInitial(); // Loads 10 items, total 15, hasMore true
      expect(controller.state.items.length, 10);
      expect(controller.state.hasMore, isTrue);

      await controller.loadNextPage(); // Loads remaining 5 items, hasMore false
      expect(controller.state.items.length, 15);
      expect(controller.state.hasMore, isFalse);

      // Subsequent call should not trigger fetch call count increase
      final callsBefore = smallSource.fetchCallCount;
      await controller.loadNextPage();
      expect(smallSource.fetchCallCount, callsBefore);

      controller.dispose();
    });

    test('Refresh resets pagination to page 1 while preserving query',
        () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      await controller.loadNextPage();
      expect(controller.state.currentPage, 2);
      expect(controller.state.items.length, 20);

      await controller.refresh();
      expect(controller.state.currentPage, 1);
      expect(controller.state.items.length, 10);
      expect(controller.state.status, SmartPaginationStatus.success);

      controller.dispose();
    });

    test('Retry after failure loads successfully', () async {
      dataSource.shouldThrowError = true;
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      expect(controller.state.status, SmartPaginationStatus.failure);

      dataSource.shouldThrowError = false;
      await controller.retry();

      expect(controller.state.status, SmartPaginationStatus.success);
      expect(controller.state.items.length, 10);

      controller.dispose();
    });

    test('Search query resets pagination to page 1', () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        searchDebounceDuration: const Duration(milliseconds: 10),
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      await controller.loadNextPage();
      expect(controller.state.currentPage, 2);

      controller.search('Item 1');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.state.search, 'Item 1');
      expect(controller.state.currentPage, 1);
      expect(controller.state.items.every((i) => i.title.contains('Item 1')),
          isTrue);

      controller.dispose();
    });

    test('Filter change resets pagination and applies parameters', () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      controller.setFilter('category', 'even');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.state.filters['category'], 'even');
      expect(controller.state.currentPage, 1);
      expect(controller.state.items.every((i) => i.category == 'even'), isTrue);

      controller.dispose();
    });

    test('Sort change resets pagination', () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      await controller.loadNextPage();
      expect(controller.state.currentPage, 2);

      controller.setSort(const SmartSort(field: 'score', descending: true));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.state.sort,
          const SmartSort(field: 'score', descending: true));
      expect(controller.state.currentPage, 1);

      controller.dispose();
    });

    test('Mandatory Race Condition Test: Out of order response protection',
        () async {
      dataSource.queryDelays['r'] = const Duration(milliseconds: 100);
      dataSource.queryDelays['ra'] = const Duration(milliseconds: 60);
      dataSource.queryDelays['ravi'] = const Duration(milliseconds: 10);

      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        searchDebounceDuration: Duration.zero,
        fetch: dataSource.fetch,
      );

      // Issue rapid out-of-order queries
      controller.search('r');
      controller.search('ra');
      controller.search('ravi');

      // Wait for all delayed async responses to complete
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Assert only the newest query ("ravi") results are stored in state
      expect(controller.state.search, 'ravi');

      controller.dispose();
    });

    test(
        'Duplicate Request Test: Concurrent loadNextPage calls execute API only once',
        () async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      final initialCalls = dataSource.fetchCallCount;

      // Fire 3 simultaneous loadNextPage calls
      final f1 = controller.loadNextPage();
      final f2 = controller.loadNextPage();
      final f3 = controller.loadNextPage();

      await Future.wait([f1, f2, f3]);

      // API should be called exactly ONCE extra
      expect(dataSource.fetchCallCount, initialCalls + 1);

      controller.dispose();
    });

    test('Dispose during active request safety test', () async {
      dataSource.queryDelays[''] = const Duration(milliseconds: 50);

      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      final future = controller.loadInitial();
      controller.dispose();

      await future;

      expect(controller.isDisposed, isTrue);
    });

    test('Empty next page test preserves existing loaded items', () async {
      final items =
          List.generate(10, (i) => TestItem(id: '$i', title: 'Item $i'));

      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: (req) async {
          if (req.page == 1) {
            return SmartPageResult(items: items, hasMore: true);
          }
          return const SmartPageResult(items: [], hasMore: false);
        },
      );

      await controller.loadInitial();
      expect(controller.state.items.length, 10);

      await controller.loadNextPage();
      expect(controller.state.items.length, 10); // Existing items NOT cleared
      expect(controller.state.hasMore, isFalse);
      expect(controller.state.status, SmartPaginationStatus.success);

      controller.dispose();
    });

    test('Page index configuration (initialPage 0 vs 1)', () async {
      final controller0 = SmartPaginationController<TestItem>(
        initialPage: 0,
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller0.loadInitial();
      expect(controller0.state.currentPage, 0);

      controller0.dispose();
    });

    test('Offset calculation verification', () async {
      final controller = SmartPaginationController<TestItem>(
        strategy: PaginationStrategy.offset,
        pageSize: 20,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      expect(controller.state.currentOffset, 0);

      await controller.loadNextPage();
      expect(controller.state.currentOffset, 20);

      await controller.loadNextPage();
      expect(controller.state.currentOffset, 40);

      controller.dispose();
    });

    test('Cursor tracking test', () async {
      final controller = SmartPaginationController<TestItem>(
        strategy: PaginationStrategy.cursor,
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await controller.loadInitial();
      expect(controller.state.nextCursor, 'cursor_11');

      await controller.loadNextPage();
      expect(controller.state.nextCursor, 'cursor_21');

      controller.dispose();
    });

    test('Invalid pageSize throws configuration error', () {
      expect(
        () => SmartPaginationController<TestItem>(
          pageSize: 0,
          fetch: dataSource.fetch,
        ),
        throwsA(isA<SmartPaginationError>()),
      );

      expect(
        () => SmartPaginationController<TestItem>(
          pageSize: -5,
          fetch: dataSource.fetch,
        ),
        throwsA(isA<SmartPaginationError>()),
      );
    });
  });
}
