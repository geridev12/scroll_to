/// Different animation styles for scroll operations.
enum ScrollAnimationType {
  /// Constant speed throughout the animation.
  linear,

  /// Starts slow and speeds up.
  easeIn,

  /// Starts fast and slows down.
  easeOut,

  /// Slow start, fast middle, slow end.
  easeInOut,

  /// Bounces at the end like a rubber ball.
  bounce,

  /// Natural spring physics with slight overshoot.
  spring,

  /// Material Design's recommended curve.
  fastOutSlowIn,

  /// Inverse of Material Design curve.
  slowOutFastIn,

  /// Elastic effect with pronounced overshoot.
  elastic,

  /// Slight backward motion before moving forward.
  back,

  /// Custom cubic bezier curve.
  cubic,
}
