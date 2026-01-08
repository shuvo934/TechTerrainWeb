import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PartnersSection extends StatefulWidget {
  const PartnersSection({super.key});

  @override
  State<PartnersSection> createState() => _PartnersSectionState();
}

class _PartnersSectionState extends State<PartnersSection>
    with SingleTickerProviderStateMixin {
  // --- animation on enter/exit (same style as other header_sections)
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
  late final Animation<double> _fadeCarousel = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .95, curve: Curves.easeOut),
  );

  final _visKey = UniqueKey();
  bool _shown = false;
  bool _autoplay = true;
  final CarouselSliderController _controller = CarouselSliderController();
  // int _current = 0;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  @override
  void dispose() {
    // _timer?.cancel();
    // _pc.dispose();
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
        _safeForward(from: 0);
        _safeSetState(() => _autoplay = true);
      } else if (v <= 0.10 && _shown) {
        _shown = false;
        _safeReverse();
        _safeSetState(
          () => _autoplay = false,
        ); // pause autoplay when off-screen
      }
    });
  }

  final List<String> _logos = const [
    // 'assets/partners/bd.png',
    'assets/partners/bd_modmr.png',
    'assets/partners/bd_ma.png',
    'assets/partners/a2i.png',
    'assets/partners/dae.png',
    'assets/partners/crp.png',
    'assets/partners/kanz_clinic.png',
    'assets/partners/techno_drugs.png',
    'assets/partners/cstar.png',
    'assets/partners/bpta.png',
    'assets/partners/btrf.png',
    'assets/partners/envoy.png',
    'assets/partners/carmel.png',
    'assets/partners/cnl.png',
    'assets/partners/givensee.png',
    'assets/partners/cnl_poly.png',
    'assets/partners/denison.png',
    'assets/partners/osman.png',
    'assets/partners/epeeist.png',
    'assets/partners/pinaki.png',
    'assets/partners/elite_force.png',
    'assets/partners/ornate.png',
    'assets/partners/sheltech.png',
    'assets/partners/siraj.png',
    'assets/partners/khandokar.png',
    'assets/partners/hapag.png',
    'assets/partners/mondol.png',
    'assets/partners/mars.png',
    'assets/partners/crossroard.png',
    'assets/partners/fashion_mart.png',
    'assets/partners/daily_sun.png',
    'assets/partners/progress.png',
    'assets/partners/alif_asset.png',
    'assets/partners/blf.png',
  ];

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: SectionShell(
        builder: (cfg) {
          // how many logos per "page"
          final itemsPerView = cfg.isMobile ? 1 : (cfg.isTablet ? 3 : 5);
          final viewportFraction = 1.0 / itemsPerView;

          final logoHeight =
              cfg.isMobile ? 80.0 : (cfg.isTablet ? 90.0 : 110.0);
          final sliderHeight = logoHeight + (cfg.isMobile ? 25.0 : 30.0);
          final itemPad = EdgeInsets.symmetric(
            horizontal: cfg.isMobile ? 6 : 10,
          );

          Widget roundArrow(AxisDirection dir) => _RoundArrow(
            direction: dir,
            onTap:
                () =>
                    dir == AxisDirection.left
                        ? _controller.previousPage(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOut,
                        )
                        : _controller.nextPage(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOut,
                        ),
          );

          final slider = FadeTransition(
            opacity: _fadeCarousel,
            child: CarouselSlider.builder(
              key: ValueKey(
                '${_autoplay}_$itemsPerView',
              ), // refresh when toggling/play or breakpoint
              carouselController: _controller,
              itemCount: _logos.length,
              itemBuilder: (context, index, realIdx) {
                final asset = _logos[index % _logos.length];
                return Padding(
                  padding: itemPad,
                  child: Center(child: _Logo(asset: asset, height: logoHeight)),
                );
              },
              options: CarouselOptions(
                height: sliderHeight,
                viewportFraction: viewportFraction, // 👈 1/N items visible
                disableCenter: true,
                padEnds: false, // so edges align nicely
                enableInfiniteScroll: true,
                autoPlay: _autoplay,
                autoPlayInterval: const Duration(seconds: 2),
                autoPlayAnimationDuration: const Duration(milliseconds: 500),
                autoPlayCurve: Curves.easeOut,
                pauseAutoPlayOnTouch: true,
                pauseAutoPlayOnManualNavigate: true,
                enlargeCenterPage: false,
                // onPageChanged:
                //     (i, _) => setState(() => _current = i % _logos.length),
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'OUR PARTNERS',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h2,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                      height: 1.06,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'Trusted Collaborations',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h1_1,
                      height: 1.06,
                      fontWeight: FontWeight.w300,
                      color: Colors.black.withValues(alpha: .8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: cfg.isMobile ? 15 : 26),

              if (cfg.isMobile) ...[
                slider,
              ] else ...[
                SizedBox(
                  height: sliderHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      roundArrow(AxisDirection.left),
                      const SizedBox(width: 12),
                      Expanded(child: slider),
                      const SizedBox(width: 12),
                      roundArrow(AxisDirection.right),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// class _ArrowButton extends StatefulWidget {
//   final AxisDirection direction;
//   final VoidCallback onTap;
//   const _ArrowButton({required this.direction, required this.onTap});
//
//   @override
//   State<_ArrowButton> createState() => _ArrowButtonState();
// }
//
// class _ArrowButtonState extends State<_ArrowButton> {
//   bool _hover = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final isLeft = widget.direction == AxisDirection.left;
//     final icon =
//         isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
//     final size = MediaQuery.of(context).size.width < 700 ? 36.0 : 42.0;
//
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: RepaintBoundary(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             curve: Curves.easeOut,
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               color: _hover ? primary_color : Colors.white,
//               borderRadius: BorderRadius.circular(999),
//               border: Border.all(color: const Color(0x22000000)),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Color(0x11000000),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Icon(icon, color: _hover ? Colors.white : primary_color),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _Logo extends StatelessWidget {
  final String asset;
  final double height;
  const _Logo({required this.asset, required this.height});

  @override
  Widget build(BuildContext context) {
    final isSvg = asset.toLowerCase().endsWith('.svg');
    final child =
        isSvg
            ? SvgPicture.asset(
              asset,
              height: height,
              fit: BoxFit.contain,
              clipBehavior: Clip.none,
            )
            : Image.asset(
              asset,
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            );
    return child; // no white card; big and clear
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
              color: _hover ? primary_color : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: primary_color_light),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: _hover ? Colors.white : primary_color),
          ),
        ),
      ),
    );
  }
}
