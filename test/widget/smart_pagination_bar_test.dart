import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

import '../helpers/fake_pagination_data_source.dart';

void main() {
  group('SmartPaginationBar Widget Tests', () {
    late FakePaginationDataSource dataSource;

    setUp(() {
      dataSource = FakePaginationDataSource();
    });

    testWidgets('Renders compact mode on narrow viewports (320px)',
        (tester) async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPaginationBar<TestItem>(
              controller: controller,
              layout: PaginationLayout.auto,
            ),
          ),
        ),
      );

      await controller.loadInitial();
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      controller.dispose();
    });

    testWidgets(
        'Renders expanded mode with range count & page size dropdown on wide viewports (1024px)',
        (tester) async {
      final controller = SmartPaginationController<TestItem>(
        pageSize: 10,
        fetch: dataSource.fetch,
      );

      tester.view.physicalSize = const Size(1024 * 2, 768 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartPaginationBar<TestItem>(
              controller: controller,
              layout: PaginationLayout.auto,
            ),
          ),
        ),
      );

      await controller.loadInitial();
      await tester.pump();

      expect(find.text('Showing 1–10 of 100'), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      controller.dispose();
    });
  });
}
