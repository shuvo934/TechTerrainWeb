import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class WorkingScreen extends StatefulWidget {
  const WorkingScreen({super.key});
  static const String id = 'working_screen';

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

class _WorkingScreenState extends State<WorkingScreen>
    with SingleTickerProviderStateMixin {
  final _sc = ScrollController();

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

  final _visKey = UniqueKey();
  bool _shown = false; // current logical state (visible/invisible)
  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) _sc.jumpTo(0); // start at top
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _sc.dispose();
    _ac.dispose();
    VisibilityDetectorController.instance.forget(_visKey);
    super.dispose();
  }

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

  void _onVisibility(VisibilityInfo info) {
    if (!_alive) return;
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _sc,
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/illustrations/working_back.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              VisibilityDetector(
                key: _visKey,
                onVisibilityChanged: _onVisibility,
                child: AnimatedBuilder(
                  animation: _ac,
                  builder:
                      (context, child) => IgnorePointer(
                        ignoring:
                            _ac.value < 0.05, // disable hits when nearly hidden
                        child: child,
                      ),
                  child: SectionShell(
                    builder: (cfg) {
                      final title = FadeTransition(
                        opacity: _fadeTitle,
                        child: SlideTransition(
                          position: _slideTitle,
                          child: Center(
                            child: Text(
                              'We are working on it. Please Standby',
                              style: GoogleFonts.poppins(
                                fontSize: cfg.bh1,
                                height: 1.06,
                                fontWeight: FontWeight.w600,
                                color: primary_color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );

                      if (cfg.isMobile) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 200.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [title],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 250.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [title],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
