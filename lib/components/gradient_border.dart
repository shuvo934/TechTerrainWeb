import 'package:flutter/material.dart';

class GradientBorder extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Gradient gradient;
  final Clip clip;

  const GradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 5,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    required this.gradient,
    this.clip = Clip.antiAlias, // keeps corners crisp
  });

  @override
  Widget build(BuildContext context) {
    // inner radius = outer radius - border width (clamped to 0)
    BorderRadius innerRadius = BorderRadius.only(
      topLeft: Radius.circular(
        (borderRadius.topLeft.x - borderWidth).clamp(0, borderRadius.topLeft.x),
      ),
      topRight: Radius.circular(
        (borderRadius.topRight.x - borderWidth).clamp(
          0,
          borderRadius.topRight.x,
        ),
      ),
      bottomLeft: Radius.circular(
        (borderRadius.bottomLeft.x - borderWidth).clamp(
          0,
          borderRadius.bottomLeft.x,
        ),
      ),
      bottomRight: Radius.circular(
        (borderRadius.bottomRight.x - borderWidth).clamp(
          0,
          borderRadius.bottomRight.x,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clip,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: innerRadius,
          clipBehavior: clip,
          child: child,
        ),
      ),
    );
  }
}
