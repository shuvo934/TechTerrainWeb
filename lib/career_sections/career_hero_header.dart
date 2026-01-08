import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/components/shiny_button.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class CareerHeroHeader extends StatefulWidget {
  final VoidCallback onViewRoles;
  const CareerHeroHeader({super.key, required this.onViewRoles});

  @override
  State<CareerHeroHeader> createState() => _CareerHeroHeaderState();
}

class _CareerHeroHeaderState extends State<CareerHeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  // Title
  late final Animation<double> _fadeTitle = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.00, .45, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideTitle = Tween(
    begin: const Offset(0, .10),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.00, .45, curve: Curves.easeOut),
    ),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: .985,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.20, .95, curve: Curves.easeOutBack),
    ),
  );

  final _visKey = UniqueKey();
  bool _shown = false; // current logical state (visible/invisible)

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  void _safeForward({double? from}) {
    if (!_alive) return;
    if (from != null) {
      _ac.forward(from: from);
    } else {
      _ac.forward();
    }
  }

  void _safeReverse() {
    if (!_alive) return;
    _ac.reverse();
  }

  // void _safeSetState(VoidCallback fn) {
  //   if (!_alive) return;
  //   setState(fn);
  // }

  Timer? _visDebounce;
  void _onVisibility(VisibilityInfo info) {
    if (!_alive) return;
    _visDebounce?.cancel();
    _visDebounce = Timer(const Duration(milliseconds: 60), () {
      final v = info.visibleFraction;
      // Enter threshold → play forward once
      if (v >= 0.30 && !_shown) {
        _shown = true;
        _safeForward(from: 0.0);
      }
      // Exit threshold → reverse to hide
      else if (v <= 0.15 && _shown) {
        // to hide sooner/later, tweak the thresholds (e.g., .55 / .3). --0.25
        _shown = false;
        _safeReverse(); // smooth fade/slide/scale out
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _visDebounce?.cancel();
    _ac.dispose();
    VisibilityDetectorController.instance.forget(_visKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: AnimatedBuilder(
        animation: _ac,
        builder:
            (context, child) => IgnorePointer(
              ignoring: _ac.value < 0.05, // disable hits when nearly hidden
              child: child,
            ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 72),
          child: SectionShell(
            builder: (cfg) {
              return FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'BUILD WHAT’S NEXT WITH US',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: cfg.bh1,
                            height: 1.06,
                            fontWeight: FontWeight.w700,
                            color: primary_color,
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          'Grow fast. Ship faster. Make real-world impact.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: cfg.isMobile ? 16 : 20,
                            height: 1.6,
                            color: Colors.black.withValues(alpha: .82),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ShinyButton(
                              'View Open Roles',
                              onPressed: widget.onViewRoles,
                              // onPressed: widget.onViewRoles,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
