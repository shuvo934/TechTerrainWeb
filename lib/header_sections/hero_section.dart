import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/components/shiny_button.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import '../components/fade_in_svg_asset.dart';

class HeroSection extends StatefulWidget {
  const HeroSection();

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  // late final AnimationController _controller;
  // late final Animation<double> _fade;
  // late final Animation<Offset> _slide;
  // bool _armed = false; // becomes true when the section is mostly off-screen
  // final _visKey = UniqueKey();

  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
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

  // Subtitle
  late final Animation<double> _fadeSub = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.12, .65, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideSub = Tween(
    begin: const Offset(0, .08),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.12, .65, curve: Curves.easeOut),
    ),
  );

  // CTA
  late final Animation<double> _fadeCTA = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.28, .95, curve: Curves.easeOutBack),
  );
  late final Animation<double> _scaleCTA = Tween(begin: .98, end: 1.0).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.28, .95, curve: Curves.easeOutBack),
    ),
  );

  // Illustration
  late final Animation<double> _fadeIllu = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .75, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideIllu = Tween(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.15, .75, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _scaleIllu = Tween(
    begin: .985,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.15, .75, curve: Curves.easeOut),
    ),
  );

  // Visibility + parallax
  final _visKey = UniqueKey();
  bool _shown = false; // current logical state (visible/invisible)
  // double _parallaxY = 0.0; // scroll-linked Y offset

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
        _safeReverse(); // smooth fade/slide/scale out
      }
    });

    // Parallax while at least partially visible
    // if (v > 0 && v <= 1 && info.size.height > 0) {
    //   final center = info.visibleBounds.top + info.visibleBounds.height / 2;
    //   final rel = ((center / info.size.height) - .5).clamp(-.8, .8);
    //   _safeSetState(() => _parallaxY = rel * 36); // tweak magnitude if you like
    // }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ac,
          builder:
              (context, child) => IgnorePointer(
                ignoring: _ac.value < 0.05, // disable hits when nearly hidden
                child: child,
              ),
          child: SectionShell(
            builder: (cfg) {
              final title = FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'Tech Terrain IT Ltd',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.bh1,
                      height: 1.06,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                ),
              );

              final second_title = FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left:
                          cfg.isMobile
                              ? 2.0
                              : cfg.isTablet
                              ? 2.0
                              : 4.0,
                    ),
                    child: Text(
                      'Trusted Tech Trooper',
                      style: GoogleFonts.poppins(
                        fontSize: cfg.h1_1,
                        height: 1.06,
                        fontWeight: FontWeight.w500,
                        color: secondary_color.withValues(alpha: .8),
                      ),
                    ),
                  ),
                ),
              );

              final sub = FadeTransition(
                opacity: _fadeSub,
                child: SlideTransition(
                  position: _slideSub,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      'We build secure, modern enterprise systems for healthcare, ERP, and beyond. '
                      'Our products serve millions of users with performance and reliability.',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: cfg.body,
                        color: Colors.black.withValues(alpha: .8),
                      ),
                    ),
                  ),
                ),
              );

              final cta = FadeTransition(
                opacity: _fadeCTA,
                child: ScaleTransition(
                  scale: _scaleCTA,
                  child: ShinyButton(
                    'Contact Us',
                    onPressed: () async {
                      LoadingController.i.flashThenGo(context, '/contact');
                    },
                  ),
                ),
              );

              final illu = FadeTransition(
                opacity: _fadeIllu,
                child: SlideTransition(
                  position: _slideIllu,
                  child: ScaleTransition(
                    scale: _scaleIllu,
                    child: AspectRatio(
                      aspectRatio: cfg.isMobile ? 4 / 3 : 5 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          cfg.isMobile ? 20 : 28,
                        ),
                        child: SvgPicture.asset(
                          'assets/illustrations/programmer_working.svg',
                          fit: BoxFit.contain,
                          // duration: const Duration(
                          //   milliseconds: 1500,
                          // ), // tweak if you like
                          // curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                  ),
                ),
              );

              if (cfg.isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 2),
                    second_title,
                    const SizedBox(height: 12),
                    sub,
                    const SizedBox(height: 20),
                    cta,
                    const SizedBox(height: 20),
                    illu,
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            title,
                            const SizedBox(height: 5),
                            second_title,
                            const SizedBox(height: 25),
                            sub,
                            const SizedBox(height: 26),
                            cta,
                          ],
                        ),
                      ),
                      const SizedBox(width: 60),
                      Expanded(flex: 6, child: illu),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ConstrainedBox(
// constraints: const BoxConstraints(maxWidth: 1200),
// child: Padding(
// padding: const EdgeInsets.symmetric(
// horizontal: 24.0,
// vertical: 140,
// ),
// child: AnimatedBuilder(
// animation: _ac,
// builder:
// (context, child) => IgnorePointer(
// ignoring:
// _ac.value < 0.05, // disable hits when nearly hidden
// child: child,
// ),
// child: Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Expanded(
// flex: 5,
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// FadeTransition(
// opacity: _fadeTitle,
// child: SlideTransition(
// position: _slideTitle,
// child: Text(
// 'Tech Terrain IT Ltd',
// style: GoogleFonts.poppins(
// fontSize: 48,
// height: 1.1,
// fontWeight: FontWeight.w600,
// color: primary_color,
// ),
// ),
// ),
// ),
// const SizedBox(height: 5),
// FadeTransition(
// opacity: _fadeTitle,
// child: SlideTransition(
// position: _slideTitle,
// child: Padding(
// padding: const EdgeInsets.only(left: 4.0),
// child: Text(
// 'Trusted Tech Trooper',
// style: GoogleFonts.poppins(
// fontSize: 30,
// height: 1.1,
// fontWeight: FontWeight.w500,
// color: secondary_color.withValues(alpha: .8),
// ),
// ),
// ),
// ),
// ),
// const SizedBox(height: 25),
// FadeTransition(
// opacity: _fadeSub,
// child: SlideTransition(
// position: _slideSub,
// child: Padding(
// padding: const EdgeInsets.only(left: 4.0),
// child: Transform.translate(
// offset: Offset(0, _parallaxY * .35),
// child: Text(
// 'We build secure, modern enterprise systems for healthcare, ERP, and beyond. '
// 'Our products serve millions of users with performance and reliability.',
// style: GoogleFonts.beVietnamPro(
// fontSize: 16,
// color: Colors.black.withValues(alpha: .8),
// ),
// ),
// ),
// ),
// ),
// ),
// const SizedBox(height: 26),
// FadeTransition(
// opacity: _fadeCTA,
// child: ScaleTransition(
// scale: _scaleCTA,
// child: ShinyButton('Contact Us'),
// ),
// ),
// ],
// ),
// ),
// const SizedBox(width: 60),
// Expanded(
// flex: 7,
// child: FadeTransition(
// opacity: _fadeIllu,
// child: SlideTransition(
// position: _slideIllu,
// child: ScaleTransition(
// scale: _scaleIllu,
// child: Transform.translate(
// offset: Offset(0, _parallaxY),
// child: AspectRatio(
// aspectRatio: 5 / 4,
// child: ClipRRect(
// borderRadius: BorderRadius.circular(28),
// child: FadeInSvgAsset(
// 'assets/illustrations/programmer_working.svg',
// fit: BoxFit.contain,
// duration: const Duration(
// milliseconds: 1500,
// ), // tweak if you like
// curve: Curves.easeOutCubic,
// ),
// ),
// ),
// ),
// ),
// ),
// ),
// ),
// ],
// ),
// ),
// ),
// ),
