import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/measure_size.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ExcellenceSection extends StatefulWidget {
  const ExcellenceSection({super.key});

  @override
  State<ExcellenceSection> createState() => _ExcellenceSectionState();
}

class _ExcellenceSectionState extends State<ExcellenceSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  // Title entrance
  late final Animation<double> _fadeTitle = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.00, .35, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideTitle = Tween<Offset>(
    begin: const Offset(0, .10),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.00, .35, curve: Curves.easeOut),
    ),
  );

  // Staggered card entrances
  ({Animation<double> fade, Animation<Offset> slide, Animation<double> scale})
  _cardAnims(int i) {
    // 0,1,2 → spread across the timeline
    final start = .15 + i * .12;
    final end = (start + .65).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _ac,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return (
      fade: curve,
      slide: Tween<Offset>(
        begin: const Offset(0, .06),
        end: Offset.zero,
      ).animate(curve),
      scale: Tween<double>(
        begin: 0.985,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)).animate(curve),
    );
  }

  // Counter animations (drive value from controller)
  late final Animation<double> _countProjects = Tween<double>(
    begin: 0,
    end: 100,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.18, .85, curve: Curves.easeOutCubic),
    ),
  );
  late final Animation<double> _countIndustries = Tween<double>(
    begin: 0,
    end: 25,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.24, .90, curve: Curves.easeOutCubic),
    ),
  );
  late final Animation<double> _countImpact = Tween<double>(
    begin: 0,
    end: 2.5,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.30, .95, curve: Curves.easeOutCubic),
    ),
  );

  final _visKey = UniqueKey();
  bool _shown = false;
  // double _parallaxY = 0;

  final _heights = <int, double>{};
  double? _equalH;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  void _measure(int i, double h) {
    if (_heights[i] == h) return;
    _heights[i] = h;
    final mx = _heights.values.fold<double>(0, (m, e) => e > m ? e : m);
    if (mx > 0 && mx != _equalH) {
      _safeSetState(() {
        _equalH = mx;
      });
    }
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

  void _safeSetState(VoidCallback fn) {
    if (!_alive) return;
    setState(fn);
  }

  Timer? _visDebounce;
  void _onVisibility(VisibilityInfo info) {
    if (!_alive) return;
    _visDebounce?.cancel();
    _visDebounce = Timer(const Duration(milliseconds: 60), () {
      final v = info.visibleFraction;
      if (v >= 0.20 && !_shown) {
        _shown = true;
        _safeForward(from: 0.0); // replay on re-enter
      } else if (v <= 0.10 && _shown) {
        _shown = false;
        _safeReverse(); // fade out when leaving
      }
    });

    // if (v > 0 && v <= 1 && info.size.height > 0) {
    //   final center = info.visibleBounds.top + info.visibleBounds.height / 2;
    //   final rel = ((center / info.size.height) - .5).clamp(-.8, .8);
    //   _safeSetState(() => _parallaxY = rel * 22); // gentle depth
    // }
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
      child: SectionShell(
        builder: (cfg) {
          final isStacked =
              cfg.isMobile || cfg.isTablet; // row for desktop, column otherwise
          final gap = cfg.gap;

          // Cards (data)
          final cards = [
            _StatModel(
              title: 'Successful Projects',
              description:
                  'With over 100 successfully completed projects, Tech Terrain IT Ltd. has a proven track record of delivering high-quality software solutions to diverse clients.',
              icon: Icons.rocket_launch_rounded,
              valueAnim: _countProjects,
              format: (v) => '${v.clamp(0, 100).toInt()}+',
              stripe: const LinearGradient(
                colors: [primary_color, primary_color_light],
              ),
            ),
            _StatModel(
              title: 'Industries Served',
              description:
                  'Serving clients across various industries, we have garnered praise for our commitment to excellence and customer satisfaction.',
              icon: Icons.apartment_rounded,
              valueAnim: _countIndustries,
              format: (v) => '${v.clamp(0, 25).toInt()}+',
              stripe: const LinearGradient(
                colors: [secondary_color, primary_color],
              ),
            ),
            _StatModel(
              title: 'Positive Impact',
              description:
                  'Our solutions have positively impacted businesses by enhancing their operations and driving growth.',
              icon: Icons.trending_up_rounded,
              valueAnim: _countImpact,
              format: (v) => '${v.clamp(0, 2.5).toStringAsFixed(1)}x',
              stripe: const LinearGradient(
                colors: [primary_color_light, primary_color],
              ),
            ),
          ];

          Widget buildCard(int i, _StatModel m) {
            final a = _cardAnims(i);
            return FadeTransition(
              opacity: a.fade,
              child: SlideTransition(
                position: a.slide,
                child: ScaleTransition(
                  scale: a.scale,
                  child: _StatCard(model: m, isDesktop: !isStacked),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'DRIVEN BY EXCELLENCE',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h2,
                      fontWeight: FontWeight.w600,
                      height: 1.06,
                      color: primary_color,
                    ),
                  ),
                ),
              ),
              SizedBox(height: cfg.isMobile ? 15 : 26),

              if (isStacked) ...[
                // Column for mobile/tablet
                for (int i = 0; i < cards.length; i++) ...[
                  buildCard(i, cards[i]),
                  if (i < cards.length - 1) SizedBox(height: gap),
                ],
              ] else ...[
                // Row for desktop
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MeasureSize(
                        onChange: (s) => _measure(0, s.height),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: _equalH ?? 0),
                          child: buildCard(0, cards[0]),
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: MeasureSize(
                        onChange: (s) => _measure(1, s.height),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: _equalH ?? 0),
                          child: buildCard(1, cards[1]),
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: MeasureSize(
                        onChange: (s) => _measure(2, s.height),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: _equalH ?? 0),
                          child: buildCard(2, cards[2]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ---------------- Models & Widgets ----------------

class _StatModel {
  final String title;
  final String description;
  final IconData icon;
  final Animation<double> valueAnim;
  final String Function(double) format;
  final LinearGradient stripe;

  const _StatModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.valueAnim,
    required this.format,
    required this.stripe,
  });
}

class _StatCard extends StatefulWidget {
  final _StatModel model;
  final bool isDesktop;
  const _StatCard({required this.model, required this.isDesktop});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF204EB8);

    final bg =
        _hover && widget.isDesktop ? Colors.white : const Color(0xFFF6F8FF);
    final border =
        _hover && widget.isDesktop
            ? brandBlue.withValues(alpha: .22)
            : const Color(0x11000000);

    final padding = EdgeInsets.fromLTRB(20, widget.isDesktop ? 20 : 18, 20, 20);
    final titleSize = widget.isDesktop ? 18.0 : 16.0;
    final valueSize = widget.isDesktop ? 42.0 : 36.0;
    final bodySize = widget.isDesktop ? 15.0 : 14.0;

    final card = RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
            bottom: Radius.circular(22),
          ),
          border: Border.all(color: border),
          boxShadow:
              _hover && widget.isDesktop
                  ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                  : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // gradient stripe
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: widget.model.stripe,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: brandBlue.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.model.icon, color: brandBlue, size: 26),
                  ),
                  const SizedBox(width: 14),
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated number
                        RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: widget.model.valueAnim,
                            builder: (context, _) {
                              final valueText = widget.model.format(
                                widget.model.valueAnim.value,
                              );
                              return Text(
                                valueText,
                                style: GoogleFonts.poppins(
                                  fontSize: valueSize,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                  color: brandBlue,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.model.title,
                          style: GoogleFonts.poppins(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: .85),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.model.description,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: bodySize,
                            height: 1.55,
                            color: Colors.black.withValues(alpha: .8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.isDesktop) return card;

    // Hover effect only on desktop
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: card,
    );
  }
}
