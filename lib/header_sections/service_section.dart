import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/grid_spec.dart';
import 'package:tech_terrain_web/components/measure_size.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ServiceSection extends StatefulWidget {
  const ServiceSection({super.key});

  @override
  State<ServiceSection> createState() => _ServiceSectionState();
}

class _ServiceSectionState extends State<ServiceSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  final _visKey = UniqueKey();
  bool _shown = false;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  // track max height
  final Map<int, double> _cardHeights = {};
  double? _equalHeight;
  double? _lastWidth;

  final services = <_ServiceItem>[
    _ServiceItem(
      'HealthTech Solutions',
      Icons.health_and_safety_rounded,
      'Revolutionizing healthcare with Rehab HIS and digital health systems for rehabilitation centers, hospitals, and clinics. From patient assessments to billing — a complete digital ecosystem.',
    ),
    _ServiceItem(
      'ERP & Enterprise Applications',
      Icons.stacked_bar_chart_rounded,
      'Custom-built ERP, HRM, CRM, and Accounts Management Systems designed for efficiency, compliance, and scalability across industries like pharmaceuticals, garments, and manufacturing.',
    ),
    _ServiceItem(
      'GovTech & Climate Solutions',
      Icons.account_balance_rounded,
      'Driving digital transformation for public sector projects, including the Agro-Meteorological Information Systems (DAE, World Bank) and Building Climate Resilient Livelihoods (BCRL).',
    ),
    _ServiceItem(
      'Industry-Specific Solutions',
      Icons.apartment_rounded,
      'Tailored software for Food Manufacturing (Ispahani Foods), garments, SMEs, and beyond — helping businesses automate, scale, and compete.',
    ),
    _ServiceItem(
      'Custom Software Development',
      Icons.auto_fix_high_rounded,
      'From idea to execution, we design and develop bespoke applications, mobile apps, and automation systems to fit unique business needs.',
    ),
    _ServiceItem(
      'IT Training & Capacity Building',
      Icons.school_rounded,
      'As an industry partner of EDGE, we conduct advanced training programs on Cybersecurity, Mobile Apps, ERP (Oracle APEX), and IoT to empower the next generation of ICT professionals.',
    ),
  ];

  // Build per-item animations (staggered)
  ({Animation<double> fade, Animation<Offset> slide, Animation<double> scale})
  _animsFor(int i, int total) {
    // spread intervals across the timeline
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
        begin: 0.985,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)).animate(curve),
    );
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
      if (v >= 0.30 && !_shown) {
        _shown = true;
        _safeForward(from: 0.0);
      } else if (v <= 0.15 && _shown) {
        _shown = false;
        _safeReverse();
      }
    });
  }

  void _onMeasured(int index, double height) {
    if (_cardHeights[index] == height) return;
    _cardHeights[index] = height;
    final maxH = _cardHeights.values.fold<double>(0, (m, h) => h > m ? h : m);
    if (_equalHeight != maxH && maxH > 0) {
      _safeSetState(() => _equalHeight = maxH);
    }
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
    // Your actual services
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: SectionShell(
        builder: (cfg) {
          return LayoutBuilder(
            builder: (context, c) {
              if (_lastWidth != c.maxWidth) {
                _lastWidth = c.maxWidth;
                _cardHeights.clear();
                _equalHeight = null;
              }
              final spec = gridSpecByScreen(
                isMobile: cfg.isMobile,
                isTablet: cfg.isTablet,
                contentWidth: c.maxWidth, // actual width right here
                spacing: cfg.gap,
              );
              final useEqualHeight = spec.columns > 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section heading
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _ac,
                      curve: const Interval(.00, .40, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, .10),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _ac,
                          curve: const Interval(
                            .00,
                            .40,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: Text(
                        'OUR SERVICES',
                        style: GoogleFonts.poppins(
                          fontSize: cfg.h2,
                          fontWeight: FontWeight.w600,
                          color: primary_color,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height:
                        cfg.isMobile
                            ? 22.0
                            : cfg.isTablet
                            ? 24.0
                            : 26,
                  ),

                  // Cards
                  Wrap(
                    spacing: cfg.gap,
                    runSpacing: cfg.gap,
                    children: [
                      for (int i = 0; i < services.length; i++)
                        SizedBox(
                          width: spec.cardWidth,
                          child:
                              useEqualHeight
                                  ? MeasureSize(
                                    onChange: (sz) => _onMeasured(i, sz.height),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: _equalHeight ?? 0,
                                      ),
                                      child: _AnimatedServiceCard(
                                        item: services[i],
                                        brandBlue: primary_color,
                                        lightBlue: primary_color_light,
                                        animations: _animsFor(
                                          i,
                                          services.length,
                                        ),
                                        isMobile: cfg.isMobile,
                                      ),
                                    ),
                                  )
                                  : _AnimatedServiceCard(
                                    item: services[i],
                                    brandBlue: primary_color,
                                    lightBlue: primary_color_light,
                                    animations: _animsFor(i, services.length),
                                    isMobile: cfg.isMobile,
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
    );
  }
}

class _AnimatedServiceCard extends StatelessWidget {
  final _ServiceItem item;
  final Color brandBlue;
  final Color lightBlue;
  final ({
    Animation<double> fade,
    Animation<Offset> slide,
    Animation<double> scale,
  })
  animations;
  final bool isMobile;

  const _AnimatedServiceCard({
    required this.item,
    required this.brandBlue,
    required this.lightBlue,
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
          child: _ServiceCard(
            title: item.title,
            icon: item.icon,
            description: item.description,
            brandBlue: brandBlue,
            lightBlue: lightBlue,
            isMobile: isMobile,
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final IconData icon;
  final String description;
  const _ServiceItem(this.title, this.icon, this.description);
}

class _ServiceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color brandBlue;
  final Color lightBlue;
  final bool isMobile;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.brandBlue,
    required this.lightBlue,
    required this.isMobile,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hover ? widget.brandBlue : Colors.transparent;
    final bgColor =
        _hover ? Colors.white : Color(0xFFFFF4D6).withValues(alpha: .7);
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
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: shadow,
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with soft pill background
              Container(
                width: widget.isMobile ? 48.0 : 60.0,
                height: widget.isMobile ? 48.0 : 60.0,
                decoration: BoxDecoration(
                  color: widget.brandBlue.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: widget.isMobile ? 30.0 : 42.0,
                  color: widget.lightBlue,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                widget.title,
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w700,
                  fontSize: widget.isMobile ? 16 : 18,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                widget.description,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.black.withValues(alpha: .8),
                  fontSize: widget.isMobile ? 14 : 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 14),
              // subtle underline indicator that animates on hover
              RepaintBoundary(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 3,
                  width: _hover ? 56 : 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.brandBlue, widget.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*@override
Widget build(BuildContext context) {
  // Your actual services
  return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      if (_lastWidth != w) {
        _lastWidth = w;
        _cardHeights.clear();
        _equalHeight = null;
        // Let a frame pass to re-measure at the new width
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
      return VisibilityDetector(
        key: _visKey,
        onVisibilityChanged: _onVisibility,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section heading
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _ac,
                      curve: const Interval(.00, .40, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, .10),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _ac,
                          curve: const Interval(
                            .00,
                            .40,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: Transform.translate(
                        offset: Offset(0, _parallaxY * .3),
                        child: Text(
                          'OUR SERVICES',
                          style: GoogleFonts.poppins(
                            fontSize: 46,
                            fontWeight: FontWeight.w600,
                            color: primary_color,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Cards
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (int i = 0; i < services.length; i++)
                        MeasureSize(
                          onChange: (sz) => _onMeasured(i, sz.height),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: _equalHeight ?? 0,
                            ),
                            child: _AnimatedServiceCard(
                              item: services[i],
                              brandBlue: brandBlue,
                              lightBlue: lightBlue,
                              animations: _animsFor(i, services.length),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}*/
