import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:scroll_to/scroll_to.dart';

/// Utility class for converting animation types to Flutter curves.
final class ScrollEasing {
  const ScrollEasing._();

  /// Returns the appropriate Flutter curve for a given animation type.
  static Curve getCurve(ScrollAnimationType type) {
    switch (type) {
      case ScrollAnimationType.linear:
        return Curves.linear;
      case ScrollAnimationType.easeIn:
        return Curves.easeIn;
      case ScrollAnimationType.easeOut:
        return Curves.easeOut;
      case ScrollAnimationType.easeInOut:
        return Curves.easeInOut;
      case ScrollAnimationType.bounce:
        return Curves.bounceOut;
      case ScrollAnimationType.spring:
        return Curves.elasticOut;
      case ScrollAnimationType.fastOutSlowIn:
        return Curves.fastOutSlowIn;
      case ScrollAnimationType.slowOutFastIn:
        return Curves.slowMiddle;
      case ScrollAnimationType.elastic:
        return Curves.elasticInOut;
      case ScrollAnimationType.back:
        return Curves.easeInBack;
      case ScrollAnimationType.cubic:
        return const Cubic(0.25, 0.1, 0.25, 1);
    }
  }

  /// Creates a custom cubic bezier curve.
  static Curve cubic(double x1, double y1, double x2, double y2) {
    return Cubic(x1, y1, x2, y2);
  }

  /// Creates a spring animation curve with physics parameters.
  static Curve spring({
    double mass = 1.0,
    double stiffness = 100.0,
    double damping = 10.0,
  }) {
    return SpringCurve(mass: mass, stiffness: stiffness, damping: damping);
  }
}

/// A curve that simulates spring physics.
class SpringCurve extends Curve {
  /// Creates a spring curve with the given physics parameters.
  const SpringCurve({
    this.mass = 1.0,
    this.stiffness = 100.0,
    this.damping = 10.0,
  });

  /// Mass of the spring system.
  final double mass;

  /// How stiff the spring is.
  final double stiffness;

  /// How much the spring resists motion.
  final double damping;

  @override
  double transform(double t) {
    // Clamp t to valid range [0.0, 1.0] to handle edge cases
    return transformInternal(t.clamp(0, 1));
  }

  @override
  double transformInternal(double t) {
    final w = math.sqrt(stiffness / mass);
    final c = damping / (2.0 * math.sqrt(mass * stiffness));

    if (c < 1.0) {
      final wd = w * math.sqrt(1.0 - c * c);
      const a = 1;
      final b = c * w / wd;
      return 1.0 -
          (a * math.cos(wd * t) + b * math.sin(wd * t)) * math.exp(-c * w * t);
    } else if (c == 1.0) {
      return 1.0 - (1.0 + w * t) * math.exp(-w * t);
    } else {
      final r1 = -w * (c + math.sqrt(c * c - 1.0));
      final r2 = -w * (c - math.sqrt(c * c - 1.0));
      final a = -1.0 / (r2 - r1);
      final b = 1.0 / (r2 - r1);
      return 1.0 - a * math.exp(r1 * t) - b * math.exp(r2 * t);
    }
  }
}
