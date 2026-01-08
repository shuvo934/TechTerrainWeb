import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Wrap your SingleChildScrollView with this to get smooth *wheel* scrolling.
/// Touch/trackpad keep native physics.
class UniversalSmoothScroll extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final double lineHeight; // pixels per wheel "line"
  final Duration baseDuration; // base anim duration per wheel tick
  final Curve curve; // easing curve

  const UniversalSmoothScroll({
    super.key,
    required this.controller,
    required this.child,
    this.lineHeight = 80.0,
    this.baseDuration = const Duration(milliseconds: 360),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<UniversalSmoothScroll> createState() => _UniversalSmoothScrollState();
}

class _UniversalSmoothScrollState extends State<UniversalSmoothScroll>
    with SingleTickerProviderStateMixin {
  // Unbounded: we'll set the controller value to the *scroll offset*
  late final AnimationController _ac = AnimationController.unbounded(
    vsync: this,
  );

  // Decide once: true = use smooth wheel; false = native.
  bool? _useSmooth;

  bool get _isDesktopWeb =>
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();

    // Start at the current scroll offset
    _ac.value = widget.controller.initialScrollOffset;

    // Each tick, drive the real ScrollController.
    _ac.addListener(() {
      if (!mounted || !widget.controller.hasClients) return;
      final pos = widget.controller.position;
      final max = pos.maxScrollExtent;
      final clamped = _ac.value.clamp(0.0, max);
      widget.controller.jumpTo(clamped);
    });
  }

  @override
  void dispose() {
    _ac.stop();
    _ac.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;

    // On first wheel event, decide whether to smooth (likely mouse) or keep native (trackpad).
    if (_useSmooth == null) {
      final preferSmooth = e.scrollDelta.dy.abs() >= 40; // heuristic
      _useSmooth = preferSmooth && _isDesktopWeb;
      if (_useSmooth != true) return; // keep native path
      setState(() {}); // rebuild physics
    }

    if (_useSmooth != true) return; // native path

    // Smooth wheel: compute next target offset
    final dy = e.scrollDelta.dy;
    final direction = dy.sign; // +1 down, -1 up
    final magnitude = dy.abs();

    // Scale delta to pixels
    final deltaPx =
        (magnitude / 120.0) * widget.lineHeight; // 120 is typical wheel step
    final pos = widget.controller.position;
    final max = pos.maxScrollExtent;

    final nextTarget = (widget.controller.offset + direction * deltaPx).clamp(
      0.0,
      max,
    );

    // Animate the unbounded controller value *from its current value* to the target.
    final ms =
        (widget.baseDuration.inMilliseconds *
                (0.85 + 0.15 * (magnitude / 120.0).clamp(0.7, 1.6)))
            .toInt();

    _ac
      ..stop()
      ..animateTo(
        nextTarget, // <-- target is an *offset*, not progress
        duration: Duration(milliseconds: ms),
        curve: widget.curve,
      );
  }

  // When we run our own wheel animation, we disable Scrollable’s own wheel handling.
  // Touch/trackpad drags remain native (they don't go through wheel signals).
  ScrollPhysics get _physics {
    if (_useSmooth == true) {
      return const NeverScrollableScrollPhysics();
    }
    // Native everywhere else
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
      default:
        return const ClampingScrollPhysics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: SingleChildScrollView(
        controller: widget.controller,
        physics: _physics,
        child: widget.child,
      ),
    );
  }
}
