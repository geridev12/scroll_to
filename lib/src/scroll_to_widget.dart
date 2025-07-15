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
