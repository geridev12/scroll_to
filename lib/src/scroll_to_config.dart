import 'package:flutter/widgets.dart';
import 'package:scroll_to/src/scroll_animation_type.dart';
import 'package:scroll_to/src/scroll_easing.dart';

/// Creates scroll configuration with the given options.
final class ScrollToConfig {
  /// Constructs a new ScrollToConfig with default values.
  const ScrollToConfig({
    this.duration = const Duration(milliseconds: 800),
    this.animationType = ScrollAnimationType.easeInOut,
    this.curve,
    this.offset = 0.0,
    this.alignment = 0.0,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
    this.paddingLeft = 0.0,
    this.paddingRight = 0.0,
    this.onScrollStart,
    this.onScrollComplete,
    this.debugMode = false,
  });

  /// How long the scroll animation takes.
  final Duration duration;

  /// Style of animation to use.
  final ScrollAnimationType animationType;

  /// Custom curve (overrides animationType if provided).
  final Curve? curve;

  /// Extra distance to scroll past the target.
  final double offset;

  /// Where to position the target (0.0 = top, 1.0 = bottom).
  final double alignment;

  /// Space to add above the target.
  final double paddingTop;

  /// Space to add below the target.
  final double paddingBottom;

  /// Space to add left of the target.
  final double paddingLeft;

  /// Space to add right of the target.
  final double paddingRight;

  /// Called when scrolling starts.
  final VoidCallback? onScrollStart;

  /// Called when scrolling finishes.
  final VoidCallback? onScrollComplete;

  /// Whether to print debug messages.
  final bool debugMode;

  /// Gets the curve to use for animation.
  Curve get effectiveCurve => curve ?? ScrollEasing.getCurve(animationType);

  /// Total padding on top and bottom.
  double get totalVerticalPadding => paddingTop + paddingBottom;

  /// Total padding on left and right.
  double get totalHorizontalPadding => paddingLeft + paddingRight;

  /// Creates a copy with some values changed.
  ScrollToConfig copyWith({
    Duration? duration,
    ScrollAnimationType? animationType,
    Curve? curve,
    double? offset,
    double? alignment,
    double? paddingTop,
    double? paddingBottom,
    double? paddingLeft,
    double? paddingRight,
    VoidCallback? onScrollStart,
    VoidCallback? onScrollComplete,
    bool? debugMode,
  }) {
    return ScrollToConfig(
      duration: duration ?? this.duration,
      animationType: animationType ?? this.animationType,
      curve: curve ?? this.curve,
      offset: offset ?? this.offset,
      alignment: alignment ?? this.alignment,
      paddingTop: paddingTop ?? this.paddingTop,
      paddingBottom: paddingBottom ?? this.paddingBottom,
      paddingLeft: paddingLeft ?? this.paddingLeft,
      paddingRight: paddingRight ?? this.paddingRight,
      onScrollStart: onScrollStart ?? this.onScrollStart,
      onScrollComplete: onScrollComplete ?? this.onScrollComplete,
      debugMode: debugMode ?? this.debugMode,
    );
  }

  /// Quick scrolling preset (300ms).
  static const ScrollToConfig fast = ScrollToConfig(
    duration: Duration(milliseconds: 300),
    animationType: ScrollAnimationType.fastOutSlowIn,
  );

  /// Smooth scrolling preset (800ms).
  static const ScrollToConfig smooth = ScrollToConfig(
    paddingTop: -20,
    paddingBottom: -10,
    paddingLeft: -15,
    paddingRight: -5,
  );

  /// Bouncy scrolling preset (1200ms).
  static const ScrollToConfig bouncy = ScrollToConfig(
    duration: Duration(milliseconds: 1200),
    animationType: ScrollAnimationType.bounce,
  );

  /// Spring scrolling preset (1000ms).
  static const ScrollToConfig spring = ScrollToConfig(
    duration: Duration(milliseconds: 1000),
    animationType: ScrollAnimationType.spring,
  );
}
