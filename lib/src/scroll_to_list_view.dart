import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to/src/scroll_to_config.dart';
import 'package:scroll_to/src/scroll_to_controller.dart';
import 'package:scroll_to/src/scroll_to_widget.dart';

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
