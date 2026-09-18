import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

void main() {
  group('SmartPagination Widget Tests', () {
    testWidgets('Renders page info, range text, and page buttons',
        (tester) async {
      tester.view.physicalSize = const Size(1024 * 2, 768 * 2);
      tester.view.devicePixelRatio = 2.0;

      int currentPage = 1;
      int pageSize = 10;
      int totalItems = 50;
      int? changedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPagination(
              currentPage: currentPage,
              pageSize: pageSize,
              totalItems: totalItems,
              itemsLabel: 'items',
              onPageChanged: (page) => changedPage = page,
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Showing 1–10 of 50 items'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(changedPage, equals(2));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Triggers First and Last page callbacks when enabled',
        (tester) async {
      tester.view.physicalSize = const Size(1200 * 2, 768 * 2);
      tester.view.devicePixelRatio = 2.0;

      int? targetPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPagination(
              currentPage: 3,
              pageSize: 10,
              totalItems: 100,
              showFirstLastButtons: true,
              onPageChanged: (page) => targetPage = page,
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.first_page), findsOneWidget);
      expect(find.byIcon(Icons.last_page), findsOneWidget);

      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pump();
      expect(targetPage, equals(1));

      await tester.tap(find.byIcon(Icons.last_page));
      await tester.pump();
      expect(targetPage, equals(10));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets(
        'Page size dropdown changes page size and resets current page to 1',
        (tester) async {
      tester.view.physicalSize = const Size(1024 * 2, 768 * 2);
      tester.view.devicePixelRatio = 2.0;

      int? newSize;
      int? resetPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPagination(
              currentPage: 4,
              pageSize: 10,
              totalItems: 100,
              onPageChanged: (page) => resetPage = page,
              onPageSizeChanged: (size) => newSize = size,
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButton<int>), findsOneWidget);
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('20 / page').last);
      await tester.pumpAndSettle();

      expect(newSize, equals(20));
      expect(resetPage, equals(1));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Handles totalItems = 0 gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPagination(
              currentPage: 1,
              pageSize: 10,
              totalItems: 0,
              itemsLabel: 'items',
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SmartPagination), findsOneWidget);
      expect(find.text('Showing 1–10 of 0 items'), findsNothing);
    });

    testWidgets('Keyboard navigation shortcuts trigger page changes',
        (tester) async {
      tester.view.physicalSize = const Size(1024 * 2, 768 * 2);
      tester.view.devicePixelRatio = 2.0;

      int? navigatedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPagination(
              currentPage: 2,
              pageSize: 10,
              totalItems: 50,
              enableKeyboardNavigation: true,
              onPageChanged: (page) => navigatedPage = page,
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(navigatedPage, equals(3));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(navigatedPage, equals(1));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Deprecated GlobalPagination widget adapter works seamlessly',
        (tester) async {
      tester.view.physicalSize = const Size(1024 * 2, 768 * 2);
      tester.view.devicePixelRatio = 2.0;

      int? changedPage;
      int? changedSize;

      // Ignore deprecation warning in test setup
      // ignore: deprecated_member_use_from_same_package
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalPagination(
              currentPage: 1,
              pageSize: 10,
              totalItems: 50,
              onPageChanged: (p) => changedPage = p,
              onRowsPerPageChanged: (r) => changedSize = r,
            ),
          ),
        ),
      );

      expect(find.byType(SmartPagination), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(changedPage, equals(2));

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50 / page').last);
      await tester.pumpAndSettle();
      expect(changedSize, equals(50));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
