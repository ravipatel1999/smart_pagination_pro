import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

import '../helpers/fake_pagination_data_source.dart';

void main() {
  group('SmartPaginatedList Widget Tests', () {
    late FakePaginationDataSource dataSource;

    setUp(() {
      dataSource = FakePaginationDataSource();
    });

    testWidgets('Renders items and loads next page on scroll threshold',
        (tester) async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPaginatedList<TestItem>(
              controller: controller,
              itemBuilder: (context, item, index) {
                return SizedBox(
                  height: 100,
                  child: Text(item.title),
                );
              },
            ),
          ),
        ),
      );

      // Trigger initial load
      await controller.loadInitial();
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(controller.state.items.length, 10);

      // Scroll down to trigger prefetch threshold
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.state.items.length >= 20, isTrue);

      controller.dispose();
    });

    testWidgets('Renders built-in Shimmer loader when showShimmer is true',
        (tester) async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: (req) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return dataSource.fetch(req);
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPaginatedList<TestItem>(
              controller: controller,
              showShimmer: true,
              itemBuilder: (context, item, index) => Text(item.title),
            ),
          ),
        ),
      );

      unawaited(controller.loadInitial());
      await tester.pump(); // Pump frame during loading

      expect(find.byType(SmartShimmerList), findsOneWidget);

      await tester
          .pump(const Duration(milliseconds: 300)); // Advance past delay
      await tester.pump(); // Rebuild with loaded data
      expect(find.text('Item 1'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Renders custom error builder and triggers retry',
        (tester) async {
      dataSource.shouldThrowError = true;
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPaginatedList<TestItem>(
              controller: controller,
              errorBuilder: (context, error, retry) {
                return Column(
                  children: [
                    Text('Custom Error: ${error.message}'),
                    ElevatedButton(
                      onPressed: retry,
                      child: const Text('Custom Retry'),
                    ),
                  ],
                );
              },
              itemBuilder: (context, item, index) => Text(item.title),
            ),
          ),
        ),
      );

      await controller.loadInitial();
      await tester.pump();

      expect(find.textContaining('Custom Error'), findsOneWidget);
      expect(find.text('Custom Retry'), findsOneWidget);

      dataSource.shouldThrowError = false;
      await tester.tap(find.text('Custom Retry'));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Renders in Dark Theme without hardcoded color crashes',
        (tester) async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 5,
        fetch: dataSource.fetch,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: Scaffold(
            body: SmartPaginatedList<TestItem>(
              controller: controller,
              displayMode: PaginationDisplayMode.pagination,
              itemBuilder: (context, item, index) => Text(item.title),
            ),
          ),
        ),
      );

      await controller.loadInitial();
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(SmartPaginationBar<TestItem>), findsOneWidget);

      controller.dispose();
    });
  });
}
