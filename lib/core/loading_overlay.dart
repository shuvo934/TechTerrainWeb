import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_terrain_web/core/ttit_logo_loader.dart';

class LoadingController extends ChangeNotifier {
  static final LoadingController i = LoadingController._();
  LoadingController._();

  bool _visible = false;
  bool get visible => _visible;

  bool _busy = false;
  bool _firstHomeShown = false;
  Timer? _timer;

  // Show the overlay for [forDuration]. If null, stays until hide().
  void show([Duration? forDuration]) {
    _timer?.cancel();
    final wasVisible = _visible;
    _visible = true;
    if (!wasVisible) {
      notifyListeners();
    }
    if (forDuration != null) {
      _timer = Timer(forDuration, hide);
    }
  }

  /// Convenience: show for 2 seconds.
  void flash() => show(const Duration(seconds: 2));

  void hide() {
    if (_visible) {
      _visible = false;
      notifyListeners();
    }
    _timer?.cancel();
    _timer = null;
  }

  // Show a first-run splash on Home only once per app session.
  Future<void> flashFirstHome({
    Duration duration = const Duration(seconds: 1),
    Duration postNavCushion = const Duration(milliseconds: 100),
  }) async {
    if (_firstHomeShown || _busy) return;
    _firstHomeShown = true;
    _busy = true;
    try {
      show();
      // print("first show");
      await Future.delayed(duration);
      await Future.delayed(postNavCushion);
    } finally {
      // print("first hide");
      hide();
      _busy = false;
    }
  }

  /// Show loader, wait [duration], then navigate to [path] and hide.
  Future<void> flashThenGo(
    BuildContext context,
    String path, {
    Duration duration = const Duration(seconds: 1),
    Duration postNavCushion = const Duration(milliseconds: 100),
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      show(); // show loader now
      await Future.delayed(duration); // wait 2s
      if (!context.mounted) return;
      context.go(path);
      // navigate after loader finishes
      await Future.delayed(postNavCushion); // tiny cushion
    } finally {
      hide();
      _busy = false;
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ctrl = LoadingController.i;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              child,
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child:
                      ctrl.visible
                          ? const _BlockingScrim(
                            key: ValueKey('loader-visible'),
                          )
                          : const SizedBox.shrink(
                            key: ValueKey('loader-hidden'),
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BlockingScrim extends StatelessWidget {
  const _BlockingScrim({super.key});

  @override
  Widget build(BuildContext context) {
    // Blocks taps while visible
    return AbsorbPointer(
      absorbing: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFF),
        ), // clean white splash
        child: Center(
          child: const TtitLogoLoader(
            logoAsset: 'assets/illustrations/ttit_logo_word_remove.svg',
            size: 140, // outer diameter
            ringWidth: 8, // thickness of the ring
            ringGap: 22,
          ),

          // Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     // Your logo (kept original colors; no tint)
          //     // Change path if needed.
          //     _SafeLogo(path: 'assets/illustrations/ttit_logo.svg', size: 72),
          //
          //     const SizedBox(height: 18),
          //
          //     // Pulsing brand dot + progress bar
          //     AnimatedBuilder(
          //       animation: _ac,
          //       builder: (context, _) {
          //         final t = _ac.value; // 0..1..0
          //         final barW = 160.0;
          //         final progress = (0.15 + 0.85 * t) * barW;
          //
          //         return Column(
          //           children: [
          //             // pulsing dot
          //             Transform.scale(
          //               scale: 0.96 + 0.04 * (1 - (t - 0.5).abs() * 2),
          //               child: Container(
          //                 width: 12,
          //                 height: 12,
          //                 decoration: const BoxDecoration(
          //                   color: primary_color,
          //                   shape: BoxShape.circle,
          //                 ),
          //               ),
          //             ),
          //             const SizedBox(height: 10),
          //             // progress bar
          //             Container(
          //               width: barW,
          //               height: 6,
          //               decoration: BoxDecoration(
          //                 color: const Color(0xFFE7ECFF),
          //                 borderRadius: BorderRadius.circular(999),
          //               ),
          //               alignment: Alignment.centerLeft,
          //               child: Container(
          //                 width: progress,
          //                 height: 6,
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(999),
          //                   gradient: const LinearGradient(
          //                     colors: [primary_color, primary_color_light],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         );
          //       },
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}

// class _SafeLogo extends StatelessWidget {
//   final String path;
//   final double size;
//   const _SafeLogo({required this.path, required this.size});
//
//   @override
//   Widget build(BuildContext context) {
//     return SvgPicture.asset(
//       path,
//       width: size,
//       height: size,
//       // no colorFilter, keeps original logo colors
//       fit: BoxFit.contain,
//     );
//   }
// }
