import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_to/scroll_to.dart';

void main() {
  group('ScrollToController Edge Cases', () {
    test('should handle unregistered key gracefully', () async {
      final controller = ScrollToController();

      await controller.scrollToKey('non-existent-key');

      expect(controller.isScrolling, false);
      controller.dispose();
    });

    test('should handle null context gracefully', () async {
      final controller = ScrollToController();
      final key = GlobalKey();

      controller.registerKey('test', key);
      await controller.scrollToKey('test');

      expect(controller.isScrolling, false);
      controller.dispose();
    });

    test('should dispose properly', () {
      final controller = ScrollToController()..registerKey('test', GlobalKey());
      expect(controller.registeredKeys.length, 1);

      controller.dispose();
    });

    test('should handle debounced scroll operations', () async {
      final controller = ScrollToController();
      final key = GlobalKey();

      controller
        ..registerKey('test', key)
        ..scrollToKeyDebounced('test')
        ..scrollToKeyDebounced('test')
        ..scrollToKeyDebounced('test');

      await Future<void>.delayed(const Duration(milliseconds: 150));

      controller.dispose();
    });

    test('should handle custom debounce delay', () async {
      final controller = ScrollToController();
      final key = GlobalKey();

      controller
        ..registerKey('test', key)
        ..scrollToKeyDebounced(
          'test',
          debounceDelay: const Duration(milliseconds: 50),
        );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      controller.dispose();
    });
  });

  group('ScrollToConfig Edge Cases', () {
    test('should handle extreme values', () {
      const config = ScrollToConfig(
        duration: Duration.zero,
        offset: double.infinity,
        alignment: -1,
        paddingTop: double.maxFinite,
      );

      expect(config.duration, Duration.zero);
      expect(config.offset, double.infinity);
      expect(config.alignment, -1.0);
      expect(config.paddingTop, double.maxFinite);
    });

    test('should handle negative padding values', () {
      const config = ScrollToConfig.smooth;

      expect(config.totalVerticalPadding, -30.0);
      expect(config.totalHorizontalPadding, -20.0);
    });
  });

  group('SpringCurve Edge Cases', () {
    test('should handle zero values', () {
      const curve = SpringCurve(mass: 0, stiffness: 0, damping: 0);

      expect(curve.mass, 0.0);
      expect(curve.stiffness, 0.0);
      expect(curve.damping, 0.0);
    });

    test('should handle extreme spring parameters', () {
      const curve = SpringCurve(mass: 1000, stiffness: 0.1, damping: 1000);

      final result = curve.transform(0.5);
      expect(result, isA<double>());
      expect(result.isFinite, true);
    });

    test('should handle edge transform values', () {
      const curve = SpringCurve();

      expect(curve.transform(-1), isA<double>());
      expect(curve.transform(2), isA<double>());
    });
  });

  group('ScrollToWidget Edge Cases', () {
    testWidgets('should handle widget disposal', (tester) async {
      final controller = ScrollToController();
      const testId = 'disposal-test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToWidget(
              id: testId,
              controller: controller,
              child: const Text('Disposal Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys.containsKey(testId), true);

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(controller.registeredKeys.containsKey(testId), false);

      controller.dispose();
    });

    testWidgets('should handle widget updates', (tester) async {
      final controller1 = ScrollToController();
      final controller2 = ScrollToController();
      const testId = 'update-test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToWidget(
              id: testId,
              controller: controller1,
              child: const Text('Update Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller1.registeredKeys.containsKey(testId), true);
      expect(controller2.registeredKeys.containsKey(testId), false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToWidget(
              id: testId,
              controller: controller2,
              child: const Text('Update Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller1.registeredKeys.containsKey(testId), false);
      expect(controller2.registeredKeys.containsKey(testId), true);

      controller1.dispose();
      controller2.dispose();
    });
  });

  group('ScrollToListView Edge Cases', () {
    testWidgets('should handle empty list', (tester) async {
      final controller = ScrollToController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToListView(
              controller: controller,
              itemCount: 0,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys, isEmpty);

      controller.dispose();
    });

    testWidgets('should handle single item list', (tester) async {
      final controller = ScrollToController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToListView(
              controller: controller,
              itemCount: 1,
              itemBuilder: (context, index) => const Text('Single Item'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys.length, 1);
      expect(controller.registeredKeys.containsKey(0), true);

      controller.dispose();
    });

    testWidgets('should handle horizontal scroll direction', (tester) async {
      final controller = ScrollToController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToListView(
              controller: controller,
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) =>
                  SizedBox(width: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys.length, greaterThanOrEqualTo(3));

      controller.dispose();
    });
  });
}
