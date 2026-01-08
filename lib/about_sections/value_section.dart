import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/measure_size.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class ValueSection extends StatefulWidget {
  const ValueSection({super.key});

  @override
  State<ValueSection> createState() => _ValueSectionState();
}

class _ValueSectionState extends State<ValueSection>
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
  late final Animation<Offset> _slideTitle = Tween<Offset>(
    begin: const Offset(0, .10),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.00, .45, curve: Curves.easeOut),
    ),
  );

  final Map<int, double> _cardHeights = {};
  double? _equalHeight;
  void _onMeasured(int index, double h) {
    if (h <= 0) return;
    if (_cardHeights[index] == h) return;
    _cardHeights[index] = h;
    final maxH = _cardHeights.values.fold<double>(0, (m, v) => v > m ? v : m);
    if (_equalHeight != maxH) setState(() => _equalHeight = maxH);
  }

  final _items = const <_ValueItem>[
    _ValueItem(
      icon: Icons.lightbulb_rounded,
      title: 'Innovation',
      desc:
          'We experiment, iterate, and deliver solutions that move clients ahead of the curve.',
    ),
    _ValueItem(
      icon: Icons.verified_rounded,
      title: 'Quality',
      desc:
          'From code reviews to QA pipelines—reliability and polish at every step.',
    ),
    _ValueItem(
      icon: Icons.lock_rounded,
      title: 'Security',
      desc:
          'Privacy-first design with secure architectures and compliant practices.',
    ),
    _ValueItem(
      icon: Icons.favorite_rounded,
      title: 'Empathy',
      desc:
          'We listen deeply and design around real people, real jobs, real contexts.',
    ),
    _ValueItem(
      icon: Icons.handshake_rounded,
      title: 'Integrity',
      desc:
          'Transparent communication, honest timelines, and accountability you can trust.',
    ),
    _ValueItem(
      icon: Icons.public_rounded,
      title: 'Impact',
      desc:
          'We measure outcomes, not outputs—technology that changes organizations.',
    ),
    _ValueItem(
      icon: Icons.verified_user_rounded,
      title: 'Trust',
      desc:
          'Long-term partnerships built on reliability, clarity, and consistent delivery.',
    ),
    _ValueItem(
      icon: Icons.workspace_premium_rounded,
      title: 'Excellence',
      desc:
          'Raising the bar—craft, performance, and UX that feel enterprise-grade.',
    ),
    _ValueItem(
      icon: Icons.groups_rounded,
      title: 'Collaboration',
      desc:
          'Working as one team with our clients—open communication, shared goals, better outcomes.',
    ),
  ];

  ({Animation<double> fade, Animation<Offset> slide, Animation<double> scale})
  _animsFor(int i, int total) {
    final start = 0.12 + (i * (0.55 / total));
    final end = (start + 0.50).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _ac,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return (
      fade: curve,
      slide: Tween<Offset>(
        begin: const Offset(0, .08),
        end: Offset.zero,
      ).animate(curve),
      scale: Tween<double>(
        begin: .985,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)).animate(curve),
    );
  }

  final _visKey = UniqueKey();
  bool _shown = false;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  @override
  void dispose() {
    _disposed = true;
    _visDebounce?.cancel();
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

  Timer? _visDebounce;
  void _onVisibility(VisibilityInfo info) {
    if (!_alive) return;
    _visDebounce?.cancel();
    _visDebounce = Timer(const Duration(milliseconds: 60), () {
      final v = info.visibleFraction;

      if (v >= 0.25 && !_shown) {
        _shown = true;
        _safeForward(from: 0.0);
      } else if (v <= 0.10 && _shown) {
        _shown = false;
        _safeReverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: Center(
        child: AnimatedBuilder(
          animation: _ac,
          builder:
              (context, child) =>
                  IgnorePointer(ignoring: _ac.value < 0.05, child: child),
          child: SectionShell(
            builder: (cfg) {
              return LayoutBuilder(
                builder: (context, c) {
                  final cols = cfg.isMobile ? 1 : (cfg.isTablet ? 2 : 3);
                  final gap = cfg.gap;
                  final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
                  final useEqual = cols > 1;

                  final title = FadeTransition(
                    opacity: _fadeTitle,
                    child: SlideTransition(
                      position: _slideTitle,
                      child: Text(
                        'CORE VALUES',
                        style: GoogleFonts.poppins(
                          fontSize: cfg.h2,
                          fontWeight: FontWeight.w600,
                          color: primary_color,
                          height: 1.06,
                        ),
                      ),
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      title,
                      SizedBox(height: cfg.isMobile ? 16 : 20),

                      // Grid
                      Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (int i = 0; i < _items.length; i++)
                            SizedBox(
                              width: cardW,
                              child: MeasureSize(
                                onChange: (sz) => _onMeasured(i, sz.height),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    // apply the tallest value as minHeight
                                    minHeight:
                                        useEqual ? (_equalHeight ?? 0) : 0,
                                  ),
                                  child: _AnimatedValueCard(
                                    item: _items[i],
                                    animations: _animsFor(i, _items.length),
                                    isMobile: cfg.isMobile,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ValueItem {
  final IconData icon;
  final String title;
  final String desc;
  const _ValueItem({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class _AnimatedValueCard extends StatelessWidget {
  final _ValueItem item;
  final ({
    Animation<double> fade,
    Animation<Offset> slide,
    Animation<double> scale,
  })
  animations;
  final bool isMobile;

  const _AnimatedValueCard({
    required this.item,
    required this.animations,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animations.fade,
      child: SlideTransition(
        position: animations.slide,
        child: ScaleTransition(
          scale: animations.scale,
          child: _ValueCard(item: item, isMobile: isMobile),
        ),
      ),
    );
  }
}

class _ValueCard extends StatefulWidget {
  final _ValueItem item;
  final bool isMobile;
  const _ValueCard({required this.item, required this.isMobile});

  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lift = _hover ? const Offset(0, -4) : Offset.zero;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(lift.dx, lift.dy),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _hover
                    ? primary_color.withValues(alpha: .25)
                    : const Color(0x11000000),
            width: 1.2,
          ),
          boxShadow:
              _hover
                  ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ]
                  : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon chip
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: primary_color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.item.icon,
                size: 32,
                color: primary_color_light,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              widget.item.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: widget.isMobile ? 15 : 18,
                color: const Color(0xFF0B1F58),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              widget.item.desc,
              style: GoogleFonts.beVietnamPro(
                fontSize: widget.isMobile ? 13 : 15,
                height: 1.55,
                color: Colors.black.withValues(alpha: .80),
              ),
            ),

            const SizedBox(height: 14),
            // Gradient underline accent
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: _hover ? 56 : 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary_color, primary_color_light],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
