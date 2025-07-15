import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_to/scroll_to.dart';

void main() {
  group('ScrollAnimationType', () {
    test('should have all expected animation types', () {
      expect(ScrollAnimationType.values, hasLength(11));
      expect(ScrollAnimationType.values, contains(ScrollAnimationType.linear));
      expect(ScrollAnimationType.values, contains(ScrollAnimationType.easeIn));
      expect(ScrollAnimationType.values, contains(ScrollAnimationType.bounce));
      expect(ScrollAnimationType.values, contains(ScrollAnimationType.spring));
    });
  });

  group('ScrollEasing', () {
    test('should return correct curve for each animation type', () {
      expect(ScrollEasing.getCurve(ScrollAnimationType.linear), Curves.linear);
      expect(ScrollEasing.getCurve(ScrollAnimationType.easeIn), Curves.easeIn);
      expect(
        ScrollEasing.getCurve(ScrollAnimationType.easeOut),
        Curves.easeOut,
      );
      expect(
        ScrollEasing.getCurve(ScrollAnimationType.bounce),
        Curves.bounceOut,
      );
    });

    test('should create custom cubic curve', () {
      final curve = ScrollEasing.cubic(0.25, 0.1, 0.25, 1);
      expect(curve, isA<Cubic>());
    });

    test('should create spring curve', () {
      final curve = ScrollEasing.spring(mass: 2, stiffness: 150);
      expect(curve, isA<SpringCurve>());
    });
  });

  group('SpringCurve', () {
    test('should create with default parameters', () {
      const curve = SpringCurve();
      expect(curve.mass, 1.0);
      expect(curve.stiffness, 100.0);
      expect(curve.damping, 10.0);
    });

    test('should create with custom parameters', () {
      const curve = SpringCurve(mass: 2, stiffness: 200, damping: 20);
      expect(curve.mass, 2.0);
      expect(curve.stiffness, 200.0);
      expect(curve.damping, 20.0);
    });

    test('should transform values correctly', () {
      const curve = SpringCurve();
      expect(curve.transform(0), 0.0);
      expect(curve.transform(1), closeTo(1.0, 0.1));
      expect(curve.transform(0.5), greaterThan(0.0));
      // Spring curves can overshoot, so remove the lessThan constraint
    });
  });

  group('ScrollToConfig', () {
    test('should create with default values', () {
      const config = ScrollToConfig.smooth;
      expect(config.duration, const Duration(milliseconds: 800));
      expect(config.animationType, ScrollAnimationType.easeInOut);
      expect(config.offset, 0.0);
      expect(config.alignment, 0.0);
      expect(config.debugMode, false);
    });

    test('should create with custom values', () {
      const config = ScrollToConfig(
        duration: Duration(milliseconds: 1000),
        animationType: ScrollAnimationType.bounce,
        offset: 100,
        alignment: 0.5,
        paddingTop: 20,
        debugMode: true,
      );
      expect(config.duration, const Duration(milliseconds: 1000));
      expect(config.animationType, ScrollAnimationType.bounce);
      expect(config.offset, 100.0);
      expect(config.alignment, 0.5);
      expect(config.paddingTop, 20.0);
      expect(config.debugMode, true);
    });

    test('should calculate total padding correctly', () {
      const config = ScrollToConfig.smooth;
      expect(config.totalVerticalPadding, -30);
      expect(config.totalHorizontalPadding, -20);
    });

    test('should return effective curve', () {
      const config1 = ScrollToConfig(animationType: ScrollAnimationType.linear);
      expect(config1.effectiveCurve, Curves.linear);

      const config2 = ScrollToConfig(curve: Curves.ease);
      expect(config2.effectiveCurve, Curves.ease);
    });

    test('should copy with new values', () {
      const original = ScrollToConfig(duration: Duration(milliseconds: 500));
      final copy = original.copyWith(
        duration: const Duration(milliseconds: 1000),
      );
      expect(copy.duration, const Duration(milliseconds: 1000));
      expect(copy.animationType, original.animationType);
    });

    test('should have predefined configurations', () {
      expect(ScrollToConfig.fast.duration, const Duration(milliseconds: 300));
      expect(ScrollToConfig.smooth.duration, const Duration(milliseconds: 800));
      expect(ScrollToConfig.bouncy.animationType, ScrollAnimationType.bounce);
      expect(ScrollToConfig.spring.animationType, ScrollAnimationType.spring);
    });
  });

  group('ScrollToController', () {
    late ScrollToController controller;

    setUp(() {
      controller = ScrollToController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize with default values', () {
      expect(controller.isScrolling, false);
      expect(controller.registeredKeys, isEmpty);
      expect(controller.defaultConfig, isA<ScrollToConfig>());
    });

    test('should register and unregister keys', () {
      final key = GlobalKey();
      controller.registerKey('test', key);
      expect(controller.registeredKeys, containsPair('test', key));

      controller.unregisterKey('test');
      expect(controller.registeredKeys, isEmpty);
    });

    test('should handle multiple registered keys', () {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      controller
        ..registerKey('item1', key1)
        ..registerKey('item2', key2);

      expect(controller.registeredKeys.length, 2);
      expect(controller.registeredKeys['item1'], key1);
      expect(controller.registeredKeys['item2'], key2);
    });

    test('should replace key when registering same id', () {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      controller
        ..registerKey('test', key1)
        ..registerKey('test', key2);

      expect(controller.registeredKeys.length, 1);
      expect(controller.registeredKeys['test'], key2);
    });
  });

  group('ScrollToWidget', () {
    testWidgets('should build correctly', (tester) async {
      final controller = ScrollToController();
      const testId = 'test-widget';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToWidget(
              id: testId,
              controller: controller,
              child: const Text('Test Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      expect(controller.registeredKeys.containsKey(testId), isTrue);

      controller.dispose();
    });

    testWidgets('should auto-register when autoRegister is true', (
      tester,
    ) async {
      final controller = ScrollToController();
      const testId = 'auto-register-test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToWidget(
              id: testId,
              controller: controller,
              child: const Text('Auto Register Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys.containsKey(testId), isTrue);

      controller.dispose();
    });

    testWidgets('should not auto-register when autoRegister is false', (
      tester,
    ) async {
      final controller = ScrollToController();
      const testId = 'no-auto-register-test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToWidget(
              id: testId,
              controller: controller,
              autoRegister: false,
              child: const Text('No Auto Register Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys, isEmpty);

      controller.dispose();
    });
  });

  group('ScrollToListView', () {
    testWidgets('should build list with scroll-to functionality', (
      tester,
    ) async {
      final controller = ScrollToController();
      const itemCount = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToListView(
              controller: controller,
              itemCount: itemCount,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(controller.registeredKeys.length, greaterThanOrEqualTo(itemCount));

      controller.dispose();
    });

    testWidgets('should use custom key builder', (tester) async {
      final controller = ScrollToController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollToListView(
              controller: controller,
              itemCount: 3,
              keyBuilder: (index) => 'custom-$index',
              itemBuilder: (context, index) => Text('Custom Item $index'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.registeredKeys.containsKey('custom-0'), isTrue);
      expect(controller.registeredKeys.containsKey('custom-1'), isTrue);
      expect(controller.registeredKeys.containsKey('custom-2'), isTrue);

      controller.dispose();
    });
  });
}
