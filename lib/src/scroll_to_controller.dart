import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_to/src/scroll_to_config.dart';

/// Controls scrolling to specific widgets with animations.
final class ScrollToController extends ChangeNotifier {
  /// Creates a scroll controller.
  ScrollToController({
    ScrollController? scrollController,
    this.defaultConfig = ScrollToConfig.smooth,
  }) : _scrollController = scrollController ?? ScrollController();

  final ScrollController _scrollController;

  /// Default settings for scroll operations.
  final ScrollToConfig defaultConfig;
  final Map<Object, GlobalKey> _registeredKeys = {};

  Timer? _debounceTimer;
  bool _isScrolling = false;

  /// The Flutter scroll controller being used.
  ScrollController get scrollController => _scrollController;

  /// Whether a scroll animation is currently running.
  bool get isScrolling => _isScrolling;

  /// All currently registered widget keys (for debugging).
  Map<Object, GlobalKey> get registeredKeys =>
      Map.unmodifiable(_registeredKeys);

  /// Registers a widget so it can be scrolled to later.
  void registerKey(Object id, GlobalKey key) {
    _registeredKeys[id] = key;
    if (defaultConfig.debugMode) {
      debugPrint('ScrollToController: Registered key for $id');
    }
  }

  /// Removes a widget from the registry.
  void unregisterKey(Object id) {
    _registeredKeys.remove(id);
    if (defaultConfig.debugMode) {
      debugPrint('ScrollToController: Unregistered key for $id');
    }
  }

  /// Scrolls to a registered widget by its ID.
  Future<void> scrollToKey(Object keyId, {ScrollToConfig? config}) async {
    final effectiveConfig = config ?? defaultConfig;

    final key = _registeredKeys[keyId];

    if (key == null) {
      if (effectiveConfig.debugMode) {
        debugPrint('ScrollToController: Key $keyId not registered');
      }
      return;
    }

    if (key.currentContext == null) {
      if (effectiveConfig.debugMode) {
        debugPrint('ScrollToController: Widget with key $keyId not mounted');
      }
      return;
    }
    await _scrollToContext(key.currentContext!, effectiveConfig);
  }

  /// Scrolls to a widget using its BuildContext directly.
  Future<void> scrollToContext(
    BuildContext context, {
    ScrollToConfig? config,
  }) async {
    final effectiveConfig = config ?? defaultConfig;
    await _scrollToContext(context, effectiveConfig);
  }

  /// Scrolls to a specific pixel offset.
  Future<void> scrollToOffset(double offset, {ScrollToConfig? config}) async {
    final effectiveConfig = config ?? defaultConfig;

    if (_isScrolling) {
      if (effectiveConfig.debugMode) {
        debugPrint('ScrollToController: Already scrolling, ignoring request');
      }
      return;
    }

    _isScrolling = true;
    effectiveConfig.onScrollStart?.call();
    notifyListeners();

    try {
      await _scrollController.animateTo(
        offset,
        duration: effectiveConfig.duration,
        curve: effectiveConfig.effectiveCurve,
      );
    } finally {
      _isScrolling = false;
      effectiveConfig.onScrollComplete?.call();
      notifyListeners();
    }
  }

  /// Scrolls to the top of the scrollable area.
  Future<void> scrollToTop({ScrollToConfig? config}) async {
    await scrollToOffset(0, config: config);
  }

  /// Scrolls to the bottom of the scrollable area.
  Future<void> scrollToBottom({ScrollToConfig? config}) async {
    await scrollToOffset(
      _scrollController.position.maxScrollExtent,
      config: config,
    );
  }

  Future<void> _scrollToContext(
    BuildContext context,
    ScrollToConfig config,
  ) async {
    if (_isScrolling) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Already scrolling, ignoring request');
      }
      return;
    }

    _debounceTimer?.cancel();

    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      if (config.debugMode) {
        debugPrint(
          'ScrollToController: RenderObject not found or not attached',
        );
      }
      return;
    }

    RenderAbstractViewport? scrollableRenderObject;

    try {
      final scrollContext = _scrollController.position.context.storageContext;
      var current = scrollContext.findRenderObject();

      while (current != null) {
        if (current is RenderAbstractViewport) {
          scrollableRenderObject = current;
          break;
        }
        current = current.parent;
      }
    } on Object catch (e) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Method 1 failed: $e');
      }
    }

    if (scrollableRenderObject == null) {
      try {
        var current = renderObject.parent;
        while (current != null) {
          if (current is RenderAbstractViewport) {
            scrollableRenderObject = current;
            break;
          }
          current = current.parent;
        }
      } on Object catch (e) {
        if (config.debugMode) {
          debugPrint('ScrollToController: Method 2 failed: $e');
        }
      }
    }

    if (scrollableRenderObject == null) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Using simple scroll calculation');
      }

      final targetOffset = _calculateSimpleTargetOffset(renderObject, config);
      if (targetOffset != null) {
        _isScrolling = true;
        config.onScrollStart?.call();
        notifyListeners();

        try {
          await _scrollController.animateTo(
            targetOffset,
            duration: config.duration,
            curve: config.effectiveCurve,
          );
        } finally {
          _isScrolling = false;
          config.onScrollComplete?.call();
          notifyListeners();
        }
      }
      return;
    }

    final targetOffset = _calculateTargetOffset(
      renderObject,
      scrollableRenderObject,
      config,
    );

    if (targetOffset == null) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Could not calculate target offset');
      }
      return;
    }

    _isScrolling = true;
    config.onScrollStart?.call();
    notifyListeners();

    try {
      await _scrollController.animateTo(
        targetOffset,
        duration: config.duration,
        curve: config.effectiveCurve,
      );
    } finally {
      _isScrolling = false;
      config.onScrollComplete?.call();
      notifyListeners();
    }
  }

  double? _calculateTargetOffset(
    RenderObject targetRenderObject,
    RenderAbstractViewport scrollableRenderObject,
    ScrollToConfig config,
  ) {
    try {
      final targetBox = targetRenderObject as RenderBox;

      final targetOffset = scrollableRenderObject.getOffsetToReveal(
        targetBox,
        config.alignment,
      );

      final adjustedOffset =
          targetOffset.offset - config.paddingTop + config.offset;

      return adjustedOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );
    } on Object catch (e) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Error calculating offset: $e');
      }

      return _calculateFallbackOffset(targetRenderObject, config);
    }
  }

  double? _calculateFallbackOffset(
    RenderObject targetRenderObject,
    ScrollToConfig config,
  ) {
    try {
      final targetBox = targetRenderObject as RenderBox;

      final targetGlobalOffset = targetBox.localToGlobal(Offset.zero);

      final scrollableContext =
          _scrollController.position.context.storageContext;
      final scrollableBox = scrollableContext.findRenderObject() as RenderBox?;

      if (scrollableBox == null) return null;

      final scrollableGlobalOffset = scrollableBox.localToGlobal(Offset.zero);

      final relativeTop = targetGlobalOffset.dy - scrollableGlobalOffset.dy;

      final currentOffset = _scrollController.offset;
      final viewportHeight = scrollableBox.size.height;
      final targetHeight = targetBox.size.height;

      final alignmentOffset =
          (viewportHeight - targetHeight) * config.alignment;
      final desiredOffset = currentOffset + relativeTop - alignmentOffset;

      final finalOffset = desiredOffset - config.paddingTop + config.offset;

      return finalOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );
    } on Object catch (e) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Fallback calculation failed: $e');
      }
      return null;
    }
  }

  double? _calculateSimpleTargetOffset(
    RenderObject targetRenderObject,
    ScrollToConfig config,
  ) {
    try {
      final targetBox = targetRenderObject as RenderBox;

      final targetGlobalOffset = targetBox.localToGlobal(Offset.zero);

      final scrollableContext =
          _scrollController.position.context.storageContext;
      final scrollableBox = scrollableContext.findRenderObject() as RenderBox?;

      if (scrollableBox == null) {
        if (config.debugMode) {
          debugPrint('ScrollToController: Could not find scrollable box');
        }
        return null;
      }

      final scrollableGlobalOffset = scrollableBox.localToGlobal(Offset.zero);

      final relativeTop = targetGlobalOffset.dy - scrollableGlobalOffset.dy;

      final currentScrollOffset = _scrollController.offset;
      final viewportHeight = _scrollController.position.viewportDimension;
      final targetHeight = targetBox.size.height;

      final alignmentOffset =
          (viewportHeight - targetHeight) * config.alignment;

      var targetScrollOffset =
          currentScrollOffset + relativeTop - alignmentOffset;

      targetScrollOffset -= config.paddingTop;
      targetScrollOffset += config.offset;

      final clampedOffset = targetScrollOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );

      if (config.debugMode) {
        debugPrint(
          'ScrollToController: Simple calculation - target: $clampedOffset, '
          'current: $currentScrollOffset',
        );
      }

      return clampedOffset;
    } on Object catch (e) {
      if (config.debugMode) {
        debugPrint('ScrollToController: Simple calculation failed: $e');
      }
      return null;
    }
  }

  /// Scrolls to a widget with a delay to avoid rapid firing.
  void scrollToKeyDebounced(
    Object keyId, {
    ScrollToConfig? config,
    Duration debounceDelay = const Duration(milliseconds: 100),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDelay, () {
      scrollToKey(keyId, config: config);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
