import 'dart:async';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

/// Item model for testing.
class TestItem {
  const TestItem({
    required this.id,
    required this.title,
    this.category = 'general',
    this.score = 0,
  });

  final String id;
  final String title;
  final String category;
  final int score;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestItem &&
        other.id == id &&
        other.title == title &&
        other.category == category &&
        other.score == score;
  }

  @override
  int get hashCode => Object.hash(id, title, category, score);

  @override
  String toString() => 'TestItem(id: $id, title: $title)';
}

/// Fake pagination data source for unit and widget testing.
class FakePaginationDataSource {
  FakePaginationDataSource({
    List<TestItem>? initialItems,
    this.defaultDelay = Duration.zero,
  }) : _items = initialItems ??
            List.generate(
              100,
              (i) => TestItem(
                id: 'item_${i + 1}',
                title: 'Item ${i + 1}',
                category: (i % 2 == 0) ? 'even' : 'odd',
                score: i * 10,
              ),
            );

  final List<TestItem> _items;
  final Duration defaultDelay;

  int fetchCallCount = 0;
  SmartPaginationRequest? lastRequest;

  bool shouldThrowError = false;
  Object? customError;
  int? failOnPage;
  Map<String, Duration> queryDelays = {};

  Future<SmartPageResult<TestItem>> fetch(
      SmartPaginationRequest request) async {
    fetchCallCount++;
    lastRequest = request;

    final queryKey = request.search ?? '';
    final delay = queryDelays[queryKey] ?? defaultDelay;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (shouldThrowError) {
      throw customError ?? Exception('Simulated API Failure');
    }

    if (failOnPage != null && request.page == failOnPage) {
      throw Exception('Failed on page $failOnPage');
    }

    var filtered = List<TestItem>.from(_items);

    if (request.search != null && request.search!.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.title.toLowerCase().contains(request.search!.toLowerCase()))
          .toList();
    }

    if (request.filters.containsKey('category')) {
      final targetCat = request.filters['category'];
      filtered = filtered.where((item) => item.category == targetCat).toList();
    }

    if (request.sort != null) {
      filtered.sort((a, b) {
        int comp = 0;
        if (request.sort!.field == 'score') {
          comp = a.score.compareTo(b.score);
        } else {
          comp = a.title.compareTo(b.title);
        }
        return request.sort!.descending ? -comp : comp;
      });
    }

    final startIndex = request.offset.clamp(0, filtered.length);
    final endIndex = (startIndex + request.pageSize).clamp(0, filtered.length);

    final slicedItems = filtered.sublist(startIndex, endIndex);

    String? nextCursorToken;
    if (endIndex < filtered.length) {
      nextCursorToken = 'cursor_${endIndex + 1}';
    }

    return SmartPageResult<TestItem>(
      items: slicedItems,
      totalItems: filtered.length,
      hasMore: endIndex < filtered.length,
      nextCursor: nextCursorToken,
    );
  }
}
