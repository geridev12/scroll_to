import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_to/src/scroll_to_config.dart';
import 'package:scroll_to/src/scroll_to_controller.dart';

/// A widget that can be scrolled to using ScrollToController.
class ScrollToWidget extends StatefulWidget {
  /// Creates a widget that can be targeted for scrolling.
  const ScrollToWidget({
    required this.id,
    required this.controller,
    required this.child,
    this.config,
    this.autoRegister = true,
    super.key,
  });

  /// Unique identifier for this widget.
  final Object id;

  /// Controller to register with.
  final ScrollToController controller;

  /// The widget to wrap.
  final Widget child;

  /// Optional scroll settings for this widget.
  final ScrollToConfig? config;

  /// Whether to automatically register with the controller.
  final bool autoRegister;

  @override
  State<ScrollToWidget> createState() => _ScrollToWidgetState();
}

class _ScrollToWidgetState extends State<ScrollToWidget> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.autoRegister) {
      widget.controller.registerKey(widget.id, _key);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.registerKey(widget.id, _key);
        }
      });
    }
  }

  @override
  void didUpdateWidget(ScrollToWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoRegister) {
      if (oldWidget.controller != widget.controller ||
          oldWidget.id != widget.id) {
        oldWidget.controller.unregisterKey(oldWidget.id);
        widget.controller.registerKey(widget.id, _key);
      }
    }
  }

  @override
  void dispose() {
    if (widget.autoRegister) {
      widget.controller.unregisterKey(widget.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _key, child: widget.child);
  }
}

/// A ListView that automatically wraps items with ScrollToWidget.
class ScrollToListView extends StatelessWidget {
  /// Creates a list view where each item can be scrolled to.
  const ScrollToListView({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.config,
    this.keyBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.itemExtent,
    this.prototypeItem,
    super.key,
  });

  /// The scroll controller to use.
  final ScrollToController controller;

  /// Number of items in the list.
  final int itemCount;

  /// Function that builds each item.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Default scroll settings for all items.
  final ScrollToConfig? config;

  /// Function to generate unique IDs for items (defaults to index).
  final Object Function(int index)? keyBuilder;

  /// Direction to scroll (vertical or horizontal).
  final Axis scrollDirection;

  /// Whether to reverse the scroll direction.
  final bool reverse;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Physics for scrolling behavior.
  final ScrollPhysics? physics;

  /// Whether the list should be as small as possible.
  final bool shrinkWrap;

  /// How much content to keep in memory.
  final double? cacheExtent;

  /// Number of items for accessibility.
  final int? semanticChildCount;

  /// When dragging should start.
  final DragStartBehavior dragStartBehavior;

  /// How to clip the list contents.
  final Clip clipBehavior;

  /// Fixed height for each item (improves performance).
  final double? itemExtent;

  /// Sample item for consistent sizing.
  final Widget? prototypeItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller.scrollController,
      itemCount: itemCount,
      scrollDirection: scrollDirection,
      reverse: reverse,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      clipBehavior: clipBehavior,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      itemBuilder: (context, index) {
        final itemKey = keyBuilder?.call(index) ?? index;
        return ScrollToWidget(
          id: itemKey,
          controller: controller,
          config: config,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Mixin to add scroll-to functionality to existing widgets.
mixin ScrollToMixin<T extends StatefulWidget> on State<T> {
  ScrollToController? _scrollToController;
  final GlobalKey _scrollToKey = GlobalKey();

  /// Gets the scroll controller, creating one if needed.
  ScrollToController get scrollToController {
    return _scrollToController ??= ScrollToController();
  }

  /// Registers this widget for scroll operations.
  void registerForScrollTo(Object id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToController.registerKey(id, _scrollToKey);
    });
  }

  /// Removes this widget from scroll operations.
  void unregisterFromScrollTo(Object id) {
    scrollToController.unregisterKey(id);
  }

  /// Wraps a child widget to make it scrollable-to.
  Widget wrapWithScrollTo(Widget child) {
    return Container(key: _scrollToKey, child: child);
  }

  @override
  void dispose() {
    _scrollToController?.dispose();
    super.dispose();
  }
}
