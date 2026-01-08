import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/gradient_border.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection>
    with SingleTickerProviderStateMixin {
  // Entrance animations
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
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
  late final Animation<double> _fadeSlider = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.18, .95, curve: Curves.easeOut),
  );

  final _visKey = UniqueKey();
  bool _shown = false;
  bool _autoplay = true; // pause
  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  final cs.CarouselSliderController _controller = cs.CarouselSliderController();
  int _current = 0;

  // Replace with your real client data
  final _items = const <_Testimonial>[
    _Testimonial(
      quote:
          'Tech Terrain IT transformed our operations with a scalable ERP and secure web apps. Delivery was on time and support is outstanding.',
      name: 'Shamim Ahmed',
      role: 'Head of Operations',
      company: 'Envoy Group',
      avatarAsset: null,
    ),
    _Testimonial(
      quote:
          'Their Rehab HIS modernized patient intake and reporting for our centers. The team truly understands HealthTech.',
      name: 'Dr. Nusrat Jahan',
      role: 'Clinical Lead',
      company: 'CRP',
      avatarAsset: null,
    ),
    _Testimonial(
      quote:
          'From mobile apps to integrations, they delivered quality with a proactive mindset. Highly recommended.',
      name: 'Farhan Mahmud',
      role: 'CTO',
      company: 'Signet Group',
      avatarAsset: null, // no image? we’ll render initials
    ),
    _Testimonial(
      quote:
          'Great partnership on GovTech—robust data pipelines, user-friendly dashboards, and strong security practices.',
      name: 'Tahmina Akter',
      role: 'Program Manager',
      company: 'a2i',
      avatarAsset: null,
    ),
  ];

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
        _safeForward(from: 0);
        _safeSetState(() => _autoplay = true);
      } else if (v <= 0.15 && _shown) {
        _shown = false;
        _safeReverse();
        _safeSetState(() => _autoplay = false);
      }
    });
  }

  final bool _hoverFinal = false;

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
          // how many cards visible at once
          final itemsPerView = cfg.isMobile ? 1 : (cfg.isTablet ? 1 : 1);
          final viewportFraction = 1.0 / itemsPerView;

          // sizing
          final sliderHeight =
              cfg.isMobile
                  ? 260.0
                  : 280.0; // stable height avoids layout issues
          final cardPadding =
              cfg.isMobile
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.all(18);
          final itemPad = EdgeInsets.symmetric(
            horizontal: cfg.isMobile ? 6 : 10,
          );

          // Slider
          final slider = FadeTransition(
            opacity: _fadeSlider,
            child: cs.CarouselSlider.builder(
              key: ValueKey('${_autoplay}_$itemsPerView'),
              carouselController: _controller,
              itemCount: _items.length,
              itemBuilder: (context, index, realIdx) {
                final t = _items[index % _items.length];
                return Padding(
                  padding: itemPad,
                  child: _TestimonialCard(
                    data: t,
                    brandBlue: primary_color,
                    lightBlue: primary_color_light,
                    padding: cardPadding,
                    isDesktop: !cfg.isMobile && !cfg.isTablet,
                  ),
                );
              },
              options: cs.CarouselOptions(
                viewportFraction: viewportFraction, // 1/N visible
                disableCenter: true,
                height: sliderHeight,
                padEnds: false,
                enableInfiniteScroll: true,
                autoPlay: _autoplay, // swipe on mobile; autoplay tablet/desktop
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 600),
                autoPlayCurve: Curves.easeOut,
                pauseAutoPlayOnTouch: true,
                pauseAutoPlayOnManualNavigate: true,
                enlargeCenterPage: false,
                onPageChanged:
                    (i, _) => setState(() => _current = i % _items.length),
              ),
            ),
          );

          final radius = 18.0;
          final borderW = 5.0;

          final gradient = const LinearGradient(
            colors: [primary_color, secondary_color, primary_color_light],
          );

          Widget roundArrow(AxisDirection dir) => _RoundArrow(
            direction: dir,
            onTap:
                () =>
                    dir == AxisDirection.left
                        ? _controller.previousPage(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOut,
                        )
                        : _controller.nextPage(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOut,
                        ),
          );

          final quoteIcon = Positioned(
            top: 10,
            right: 12,
            child: Icon(
              Icons.format_quote_rounded,
              size: 60,
              color: primary_color_light.withValues(alpha: .15),
            ),
          );

          Widget withButton = Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              children: [
                roundArrow(AxisDirection.left),
                const SizedBox(width: 12),
                Expanded(child: slider),
                const SizedBox(width: 12),
                roundArrow(AxisDirection.right),
              ],
            ),
          );

          Widget withOutButton = slider;

          final card = GradientBorder(
            borderWidth: borderW, // 👈 5px
            borderRadius: BorderRadius.circular(radius),
            gradient: gradient,
            child: RepaintBoundary(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius - borderW),
                  boxShadow:
                      _hoverFinal && cfg.isDesktop
                          ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ]
                          : const [],
                ),
                child: Stack(
                  children: [
                    quoteIcon,
                    cfg.isMobile ? withOutButton : withButton,
                  ],
                ),
              ),
            ),
          );

          final testimonial = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'CLIENT TESTIMONIALS',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h2,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                      height: 1.06,
                    ),
                  ),
                ),
              ),
              SizedBox(height: cfg.isMobile ? 15 : 26),

              card,

              // (optional) indicators
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (i) => _dot(i == _current, primary_color),
                ),
              ),
            ],
          );
          if (!cfg.isDesktop) return testimonial;

          return testimonial;
        },
      ),
    );
  }

  Widget _dot(bool active, Color brandBlue) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
    width: active ? 20 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? brandBlue : const Color(0x22000000),
      borderRadius: BorderRadius.circular(999),
    ),
  );
}

// ====== Models & UI ======
class _Testimonial {
  final String quote;
  final String name;
  final String role;
  final String company;
  final String? avatarAsset;
  const _Testimonial({
    required this.quote,
    required this.name,
    required this.role,
    required this.company,
    this.avatarAsset,
  });
}

class _TestimonialCard extends StatefulWidget {
  final _Testimonial data;
  final Color brandBlue;
  final Color lightBlue;
  final EdgeInsets padding;
  final bool isDesktop;

  const _TestimonialCard({
    required this.data,
    required this.brandBlue,
    required this.lightBlue,
    required this.padding,
    required this.isDesktop,
  });

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  @override
  Widget build(BuildContext context) {
    final card = Center(
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // center the row content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '“${widget.data.quote}”',
              softWrap: true,
              maxLines: null,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: widget.isDesktop ? 18 : 15,
                height: 1.55,
                color: Colors.black.withValues(alpha: .9), // <- withOpacity
              ),
            ),
            const SizedBox(height: 36),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AvatarCircle(
                  asset: widget.data.avatarAsset,
                  brandBlue: widget.brandBlue,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.name,
                      style: GoogleFonts.poppins(
                        fontSize: widget.isDesktop ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: widget.brandBlue,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.data.role} • ${widget.data.company}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: .65),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!widget.isDesktop) return card;

    return card;
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? asset;
  final Color brandBlue;
  const _AvatarCircle({required this.asset, required this.brandBlue});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;

    Widget inner;
    if (asset == null || asset!.isEmpty) {
      // initials placeholder from name first letters (simple circle)
      inner = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: brandBlue.withValues(alpha: .10),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person_rounded, color: brandBlue, size: 24),
      );
    } else if (asset!.toLowerCase().endsWith('.svg')) {
      inner = ClipOval(
        child: SvgPicture.asset(
          asset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      inner = ClipOval(
        child: Image.asset(
          asset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: brandBlue.withValues(alpha: .22)),
      ),
      child: inner,
    );
  }
}

class _RoundArrow extends StatefulWidget {
  final AxisDirection direction;
  final VoidCallback onTap;
  const _RoundArrow({required this.direction, required this.onTap});

  @override
  State<_RoundArrow> createState() => _RoundArrowState();
}

class _RoundArrowState extends State<_RoundArrow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isLeft = widget.direction == AxisDirection.left;
    final icon =
        isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
    final size = MediaQuery.of(context).size.width < 700 ? 36.0 : 42.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _hover ? const Color(0xFF204EB8) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x22000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: _hover ? Colors.white : const Color(0xFF204EB8),
            ),
          ),
        ),
      ),
    );
  }
}
