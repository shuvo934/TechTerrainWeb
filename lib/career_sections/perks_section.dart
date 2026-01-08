import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/components/measure_size.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class PerksSection extends StatefulWidget {
  const PerksSection({super.key});

  @override
  State<PerksSection> createState() => _PerksSectionState();
}

class _PerksSectionState extends State<PerksSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

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

  final _visKey = UniqueKey();
  bool _shown = false;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  final Map<int, double> _heights = {};
  double? _equalHeight;

  @override
  void dispose() {
    _disposed = true;
    _ac.dispose();
    _visDebounce?.cancel();
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

  void _onMeasured(int index, double h) {
    if (h <= 0) return;
    if (_heights[index] == h) return;
    _heights[index] = h;
    final maxH = _heights.values.fold<double>(0, (m, x) => x > m ? x : m);
    if (maxH > 0 && _equalHeight != maxH) {
      setState(() => _equalHeight = maxH);
    }
  }

  // Stagger helpers
  ({Animation<double> fade, Animation<Offset> slide, Animation<double> scale})
  _animsFor(int i, int total) {
    final start = 0.10 + (i * (0.65 / total));
    final end = (start + 0.55).clamp(0.0, 1.0);
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
        begin: .985,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutBack)).animate(curve),
    );
  }

  // ---- Data ----
  final _perks = const <_PerkItem>[
    // _PerkItem(
    //   icon: Icons.schedule_rounded,
    //   title: 'Hybrid & Flexible Hours',
    //   desc:
    //       'Own your time: hybrid setup, flexible starts, and autonomy to do deep work.',
    // ),
    _PerkItem(
      icon: Icons.groups_rounded,
      title: 'Collaborative Culture',
      desc:
          'Weekly design/dev syncs, open reviews, and mentorship baked into projects.',
    ),
    _PerkItem(
      icon: Icons.laptop_mac_rounded,
      title: 'Great Hardware',
      desc:
          'Fast laptops, extra monitors, and the tooling you need to move quickly.',
    ),
    _PerkItem(
      icon: Icons.card_giftcard_rounded,
      title: 'Dual Festival Bonuses',
      desc:
          'Two festival bonuses a year to celebrate together with your family.',
    ),
    _PerkItem(
      icon: Icons.restaurant_menu_rounded,
      title: 'Meals, Coffee & Snacks',
      desc:
          'Daily refreshments to keep you focused—coffee, snacks, and quick bites.',
    ),
    _PerkItem(
      icon: Icons.trending_up_rounded,
      title: 'Annual Salary Review',
      desc:
          'Structured reviews aligned to impact, ownership, and growth trajectory.',
    ),
    _PerkItem(
      icon: Icons.mosque_rounded,
      title: 'Muslim Prayer Zone',
      desc: 'Dedicated, peaceful space for Salah—because wellbeing matters.',
    ),
    _PerkItem(
      icon: Icons.flight_takeoff_rounded,
      title: 'Annual Pleasure Tour',
      desc: 'A team getaway to recharge, bond, and celebrate what we shipped.',
    ),
    _PerkItem(
      icon: Icons.health_and_safety_rounded,
      title: 'Health & Leaves',
      desc:
          'Paid leaves, sick days, and health-first policies for you and your family.',
    ),
    _PerkItem(
      icon: Icons.rocket_launch_rounded,
      title: 'Ownership & Impact',
      desc:
          'Small teams, big responsibility—ship features that truly move the needle.',
    ),
  ];

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
                  // responsive columns
                  final w = c.maxWidth;
                  final cols =
                      w >= 1100
                          ? 3
                          : (w >= 680 ? 2 : 1); // desktop 3, tablet 2, mobile 1
                  final gap = cfg.gap;
                  final cardWidth =
                      (w - gap * (cols - 1)) / cols; // exact fit in a Wrap row

                  final title = FadeTransition(
                    opacity: _fadeTitle,
                    child: SlideTransition(
                      position: _slideTitle,
                      child: Text(
                        'PERKS & BENEFITS',
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

                      // Cards grid
                      Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (int i = 0; i < _perks.length; i++)
                            SizedBox(
                              width: cardWidth,
                              child: MeasureSize(
                                onChange: (sz) => _onMeasured(i, sz.height),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: _equalHeight ?? 0,
                                  ),
                                  child: _AnimatedPerkCard(
                                    item: _perks[i],
                                    isMobile: cfg.isMobile,
                                    anims: _animsFor(i, _perks.length),
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

class _PerkItem {
  final IconData icon;
  final String title;
  final String desc;
  const _PerkItem({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class _AnimatedPerkCard extends StatelessWidget {
  final _PerkItem item;
  final bool isMobile;
  final ({
    Animation<double> fade,
    Animation<Offset> slide,
    Animation<double> scale,
  })
  anims;

  const _AnimatedPerkCard({
    required this.item,
    required this.isMobile,
    required this.anims,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: anims.fade,
      child: SlideTransition(
        position: anims.slide,
        child: ScaleTransition(
          scale: anims.scale,
          child: _PerkCard(item: item, isMobile: isMobile),
        ),
      ),
    );
  }
}

class _PerkCard extends StatefulWidget {
  final _PerkItem item;
  final bool isMobile;
  const _PerkCard({required this.item, required this.isMobile});

  @override
  State<_PerkCard> createState() => _PerkCardState();
}

class _PerkCardState extends State<_PerkCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lift =
        _hover ? const Offset(0, -4) : Offset.zero; // subtle brand tint
    final border =
        _hover ? primary_color.withValues(alpha: .25) : const Color(0x11000000);
    final shadow =
        _hover
            ? const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ]
            : const <BoxShadow>[];

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(lift.dx, lift.dy),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.2),
          boxShadow: shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon in pill
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primary_color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.item.icon, size: 30, color: primary_color),
            ),
            const SizedBox(height: 12),

            Text(
              widget.item.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: widget.isMobile ? 15 : 18,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              widget.item.desc,
              style: GoogleFonts.beVietnamPro(
                fontSize: widget.isMobile ? 13 : 15,
                height: 1.55,
                color: Colors.black.withValues(alpha: .8),
              ),
            ),

            const SizedBox(height: 14),
            // gradient underline that grows on hover
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: _hover ? 54 : 28,
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
