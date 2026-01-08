import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/components/shiny_button.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({
    super.key,
    this.illustrationAsset = 'assets/illustrations/team.svg',
  });

  final String illustrationAsset;

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
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

  // Paragraph
  late final Animation<double> _fadeBody = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.12, .70, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideBody = Tween<Offset>(
    begin: const Offset(0, .08),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.12, .70, curve: Curves.easeOut),
    ),
  );

  // Chips / badges
  late final Animation<double> _fadeChips = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.30, .90, curve: Curves.easeOut),
  );
  late final Animation<double> _scaleChips = Tween<double>(
        begin: 0.98,
        end: 1.0,
      )
      .chain(
        CurveTween(curve: const Interval(.30, .90, curve: Curves.easeOutBack)),
      )
      .animate(_ac);

  // Illustration
  late final Animation<double> _fadeIllu = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .75, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideIllu = Tween<Offset>(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.15, .75, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _scaleIllu = Tween<double>(
        begin: 0.985,
        end: 1.0,
      )
      .chain(CurveTween(curve: const Interval(.15, .75, curve: Curves.easeOut)))
      .animate(_ac);

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

  final _visKey = UniqueKey();
  bool _shown = false;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  @override
  void dispose() {
    _visDebounce?.cancel();
    _disposed = true;
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

      if (v >= 0.30 && !_shown) {
        _shown = true;
        _safeForward(from: 0.0);
      } else if (v <= 0.15 && _shown) {
        _shown = false;
        _safeReverse();
      }

      // if (v > 0 && v <= 1 && info.size.height > 0) {
      //   final center = info.visibleBounds.top + info.visibleBounds.height / 2;
      //   final rel = ((center / info.size.height) - .5).clamp(-.8, .8);
      //   _safeSetState(() => _parallaxY = rel * 28); // slightly softer than hero
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use your brand if available (e.g., primary_color). This is a safe default:
    // const headingColor = Color(0xFF204EB8);

    const aboutText =
        'Tech Terrain IT Ltd. is a trusted software company founded in 2010, delivering '
        'HealthTech, ERP, and GovTech solutions that empower businesses and institutions. '
        'From revolutionizing rehabilitation care with Rehab HIS to building enterprise-grade '
        'ERP & HRM systems for leading industries, we specialize in creating scalable, '
        'customized digital solutions.\n\n'
        '👉 Multi-time BASIS National ICT Award Winner & APICTA International Nominee';

    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: Center(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ac,
            builder:
                (context, child) =>
                    IgnorePointer(ignoring: _ac.value < 0.05, child: child),
            child: SectionShell(
              builder: (cfg) {
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
                            widget.illustrationAsset,
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

                final title = FadeTransition(
                  opacity: _fadeTitle,
                  child: SlideTransition(
                    position: _slideTitle,
                    child: Text(
                      'WHO WE ARE',
                      style: GoogleFonts.poppins(
                        fontSize: cfg.h2,
                        fontWeight: FontWeight.w600,
                        color: primary_color,
                        height: 1.06,
                      ),
                    ),
                  ),
                );

                final bodyText = FadeTransition(
                  opacity: _fadeBody,
                  child: SlideTransition(
                    position: _slideBody,
                    child: Text(
                      aboutText,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: cfg.body,
                        color: Colors.black.withValues(alpha: .8),
                      ),
                    ),
                  ),
                );

                final chips = FadeTransition(
                  opacity: _fadeChips,
                  child: ScaleTransition(
                    scale: _scaleChips,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _TagChip(
                          icon: Icons.health_and_safety_rounded,
                          label: 'HealthTech',
                        ),
                        _TagChip(
                          icon: Icons.stacked_bar_chart_rounded,
                          label: 'ERP & HRM',
                        ),
                        _TagChip(
                          icon: Icons.account_balance_rounded,
                          label: 'GovTech',
                        ),
                        _AwardChip(label: 'BASIS National ICT Winner'),
                        _AwardChip(label: 'APICTA Nominee'),
                        _TagChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Founded 2010',
                        ),
                      ],
                    ),
                  ),
                );

                final cta = FadeTransition(
                  opacity: _fadeCTA,
                  child: ScaleTransition(
                    scale: _scaleCTA,
                    child: ShinyButton(
                      'Learn More',
                      onPressed: () async {
                        LoadingController.i.flashThenGo(context, '/about');
                      },
                    ),
                  ),
                );

                if (cfg.isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      illu,
                      const SizedBox(height: 25),
                      title,
                      const SizedBox(height: 12),
                      bodyText,
                      SizedBox(height: 12),
                      chips,
                      const SizedBox(height: 20),
                      cta,
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: illu),
                      const SizedBox(width: 60),

                      // Content
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            title,
                            const SizedBox(height: 25),
                            bodyText,
                            const SizedBox(height: 20),
                            chips,
                            const SizedBox(height: 26),
                            cta,
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ small UI helpers ------------------

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TagChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF204EB8).withValues(alpha: .06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF204EB8).withValues(alpha: .25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF204EB8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AwardChip extends StatelessWidget {
  final String label;
  const _AwardChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC33).withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCC33).withValues(alpha: .6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 16,
            color: Color(0xFFFFB300),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ConstrainedBox(
// constraints: const BoxConstraints(maxWidth: 1200),
// child: Padding(
// padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 140),
// child: AnimatedBuilder(
// animation: _ac,
// builder:
// (context, child) =>
// IgnorePointer(ignoring: _ac.value < 0.05, child: child),
// child: Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// // Illustration (left for variety)
// Expanded(
// flex: 6,
// child: FadeTransition(
// opacity: _fadeIllu,
// child: SlideTransition(
// position: _slideIllu,
// child: ScaleTransition(
// scale: _scaleIllu,
// child: Transform.translate(
// offset: Offset(0, _parallaxY),
// child: AspectRatio(
// aspectRatio: 4 / 3,
// child: ClipRRect(
// borderRadius: BorderRadius.circular(24),
// child: FadeInSvgAsset(
// widget.illustrationAsset,
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
// const SizedBox(width: 60),
//
// // Content
// Expanded(
// flex: 6,
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// FadeTransition(
// opacity: _fadeTitle,
// child: SlideTransition(
// position: _slideTitle,
// child: Text(
// 'WHO WE ARE',
// style: GoogleFonts.poppins(
// fontSize: 46,
// fontWeight: FontWeight.w600,
// color: primary_color,
// height: 1.1,
// ),
// ),
// ),
// ),
// const SizedBox(height: 25),
// FadeTransition(
// opacity: _fadeBody,
// child: SlideTransition(
// position: _slideBody,
// child: Transform.translate(
// offset: Offset(0, _parallaxY * .35),
// child: Text(
// aboutText,
// style: GoogleFonts.beVietnamPro(
// fontSize: 16,
// // height: 1.6,
// color: Colors.black.withValues(alpha: .8),
// ),
// ),
// ),
// ),
// ),
// const SizedBox(height: 20),
// FadeTransition(
// opacity: _fadeChips,
// child: ScaleTransition(
// scale: _scaleChips,
// child: Wrap(
// spacing: 10,
// runSpacing: 10,
// children: const [
// _TagChip(
// icon: Icons.health_and_safety_rounded,
// label: 'HealthTech',
// ),
// _TagChip(
// icon: Icons.stacked_bar_chart_rounded,
// label: 'ERP & HRM',
// ),
// _TagChip(
// icon: Icons.account_balance_rounded,
// label: 'GovTech',
// ),
// _AwardChip(label: 'BASIS National ICT Winner'),
// _AwardChip(label: 'APICTA Nominee'),
// _TagChip(
// icon: Icons.calendar_today_rounded,
// label: 'Founded 2010',
// ),
// ],
// ),
// ),
// ),
// const SizedBox(height: 26),
// FadeTransition(
// opacity: _fadeCTA,
// child: ScaleTransition(
// scale: _scaleCTA,
// child: ShinyButton('Learn More'),
// ),
// ),
// // Optional CTA: reuse your _ShinyCTA or a clean FilledButton
// // FilledButton.icon(
// //   onPressed: () {},
// //   style: FilledButton.styleFrom(
// //     padding: const EdgeInsets.symmetric(
// //       horizontal: 20,
// //       vertical: 14,
// //     ),
// //     shape: const StadiumBorder(),
// //   ),
// //   icon: const Icon(Icons.info_outline_rounded),
// //   label: const Text('Learn more about us'),
// // ),
// ],
// ),
// ),
// ],
// ),
// ),
// ),
// ),
