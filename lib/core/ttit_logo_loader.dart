import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

// A spinner ring with a rotating sweep/gradient and a gap, wrapped around a logo.
class TtitLogoLoader extends StatelessWidget {
  const TtitLogoLoader({
    super.key,
    this.logoAsset = 'assets/illustrations/ttit_logo.svg',
    this.size = 140,
    this.ringWidth = 8,
    this.ringGap = 12, // space between ring and logo
    this.colors = const [primary_color, secondary_color, primary_color_light],
  });

  final String logoAsset;
  final double size; // outer size (diameter of the ring box)
  final double ringWidth; // stroke width of the ring
  final double ringGap; // gap between ring and logo box
  final List<Color> colors; // gradient colors (your 3 brand colors)

  @override
  Widget build(BuildContext context) {
    final innerLogoBox = size - ringWidth * 2 - ringGap * 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _CircularGradientRing(
            diameter: size,
            stroke: ringWidth,
            colors: colors,
          ),
          // Keep original colors of the SVG (no colorFilter)
          SizedBox(
            width: innerLogoBox,
            height: innerLogoBox * .72, // keep your logo aspect (roughly)
            child: FittedBox(
              fit: BoxFit.contain,
              child: SvgPicture.asset(logoAsset),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full circle stroke painted with a SweepGradient.
/// Last part of the gradient is transparent to form a "gap",
/// and the gradient rotates to create motion.
class _CircularGradientRing extends StatefulWidget {
  const _CircularGradientRing({
    required this.diameter,
    required this.stroke,
    required this.colors,
  });

  final double diameter;
  final double stroke;
  final List<Color> colors;

  @override
  State<_CircularGradientRing> createState() => _CircularGradientRingState();
}

class _CircularGradientRingState extends State<_CircularGradientRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, _) {
          final angle = _spin.value * math.pi * 2;

          return CustomPaint(
            size: Size(widget.diameter, widget.diameter),
            painter: _RingPainter(
              stroke: widget.stroke,
              angle: angle, // rotate the gradient
              colors: widget.colors,
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.stroke,
    required this.angle,
    required this.colors,
  });

  final double stroke;
  final double angle;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    // We want a colorful arc with a trailing gap.
    // We add a transparent tail to the sweep gradient so a portion is invisible.
    final sweep = SweepGradient(
      startAngle: 0.0,
      endAngle: math.pi * 2,
      // colors: [blue, light blue, yellow, transparent..]
      colors: [...colors, Colors.transparent, Colors.transparent],
      // stops tuned so ~80-85% is visible, rest is a nice gap
      stops: const [0.0, 0.5, 0.80, 0.94, 1.0],
      transform: GradientRotation(angle),
      center: Alignment.center,
    );

    paint.shader = sweep.createShader(rect);

    final inset = stroke / 2;
    final arcRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.stroke != stroke || old.angle != angle || old.colors != colors;
}
