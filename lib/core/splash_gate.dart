import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  final _loaderKey = GlobalKey<_BrandedLoaderState>();
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // wait 2s, then move to Home
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _navigated) return;

      // 1) Stop any animations before routing away
      _loaderKey.currentState?.stop();
      print("TIMER");

      // 2) Defer navigation to the next microtask/frame to avoid racing paints
      scheduleMicrotask(() {
        print("TIMER STOPPED");
        if (!mounted || _navigated) return;
        _navigated = true;
        context.pushReplacement('/');
        // context.go('/'); // replace with your home route
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BrandedLoader(),
      ), // a small widget showing your logo + bar
    );
  }
}

class BrandedLoader extends StatefulWidget {
  const BrandedLoader({super.key});

  @override
  State<BrandedLoader> createState() => _BrandedLoaderState();
}

class _BrandedLoaderState extends State<BrandedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  void stop() {
    if (mounted && _ac.isAnimating) {
      _ac.stop();
    }
  }

  @override
  void dispose() {
    if (_ac.isAnimating) _ac.stop();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(
      enabled: ModalRoute.of(context)?.isCurrent ?? true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your logo (kept original colors; no tint)
          // Change path if needed.
          SvgPicture.asset(
            'assets/illustrations/ttit_logo.svg',
            width: 72,
            height: 72,
            // no colorFilter, keeps original logo colors
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 18),

          // Pulsing brand dot + progress bar
          AnimatedBuilder(
            animation: _ac,
            builder: (context, _) {
              final t = _ac.value; // 0..1..0
              final barW = 160.0;
              final progress = (0.15 + 0.85 * t) * barW;

              return Column(
                children: [
                  // pulsing dot
                  Transform.scale(
                    scale: 0.96 + 0.04 * (1 - (t - 0.5).abs() * 2),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: primary_color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // progress bar
                  Container(
                    width: barW,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7ECFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: progress,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [primary_color, primary_color_light],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
