import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/fade_in_svg_asset.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MissionVisionSection extends StatefulWidget {
  const MissionVisionSection({super.key});

  @override
  State<MissionVisionSection> createState() => _MissionVisionSectionState();
}

class _MissionVisionSectionState extends State<MissionVisionSection>
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

  // Mission card
  late final Animation<double> _fadeMission = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .75, curve: Curves.easeOut),
  );
  late final Animation<double> _scaleMission = Tween<double>(
        begin: 0.985,
        end: 1.0,
      )
      .chain(
        CurveTween(curve: const Interval(.15, .75, curve: Curves.easeOutBack)),
      )
      .animate(_ac);

  // Vision card
  late final Animation<double> _fadeVision = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.28, .95, curve: Curves.easeOut),
  );
  late final Animation<double> _scaleVision = Tween<double>(
        begin: 0.985,
        end: 1.0,
      )
      .chain(
        CurveTween(curve: const Interval(.28, .95, curve: Curves.easeOutBack)),
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

  @override
  Widget build(BuildContext context) {
    const missionText =
        'To empower organizations and communities with innovative digital solutions in '
        'HealthTech, ERP, and GovTech, driving efficiency, inclusivity, and sustainable growth.';

    const visionText =
        'To become a global leader in transformative and sustainable technology, making digital health, '
        'enterprise automation, and smart governance accessible and impactful for all.';

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
                final title = FadeTransition(
                  opacity: _fadeTitle,
                  child: SlideTransition(
                    position: _slideTitle,
                    child: Text(
                      'MISSION & VISION',
                      style: GoogleFonts.poppins(
                        fontSize: cfg.h2,
                        fontWeight: FontWeight.w600,
                        color: primary_color,
                        height: 1.06,
                      ),
                    ),
                  ),
                );

                final missionCard = FadeTransition(
                  opacity: _fadeMission,
                  child: ScaleTransition(
                    scale: _scaleMission,
                    child: _MVCard(
                      title: 'Our Mission',
                      titleColor: primary_color,
                      titleSize: cfg.h1_1,
                      stripeGradient: const LinearGradient(
                        colors: [primary_color, primary_color_light],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      iconBg: primary_color.withValues(alpha: .08),
                      iconColor: primary_color,
                      icon: 'assets/images/target.png',
                      text: missionText,
                      textSize: cfg.body,
                      isMobile: cfg.isMobile,
                      accentDot: secondary_color,
                    ),
                  ),
                );

                final visionCard = FadeTransition(
                  opacity: _fadeVision,
                  child: ScaleTransition(
                    scale: _scaleVision,
                    child: _MVCard(
                      title: 'Our Vision',
                      titleSize: cfg.h1_1,
                      titleColor: primary_color,
                      stripeGradient: const LinearGradient(
                        colors: [secondary_color, primary_color],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      iconBg: secondary_color.withValues(alpha: .14),
                      iconColor: const Color(0xFFF4A500),
                      icon: 'assets/images/vision.png',
                      text: visionText,
                      textSize: cfg.body,
                      isMobile: cfg.isMobile,
                      accentDot: primary_color_light,
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
                            'assets/illustrations/mission_vision.svg',
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
                      illu,
                      const SizedBox(height: 28),
                      title,
                      const SizedBox(height: 12),
                      missionCard,
                      SizedBox(height: 12),
                      visionCard,
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section heading
                            title,
                            const SizedBox(height: 26),
                            missionCard,
                            const SizedBox(height: 24),
                            visionCard,
                          ],
                        ),
                      ),
                      const SizedBox(width: 60),
                      Expanded(flex: 7, child: illu),
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

// ============== reusable card ==============
class _MVCard extends StatelessWidget {
  final String title;
  final double titleSize;
  final String text;
  final double textSize;
  final LinearGradient stripeGradient;
  final Color titleColor;
  final Color iconBg;
  final Color iconColor;
  final String icon;
  final Color accentDot;
  final bool isMobile;

  const _MVCard({
    required this.title,
    required this.titleSize,
    required this.text,
    required this.textSize,
    required this.stripeGradient,
    required this.titleColor,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.accentDot,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
          bottom: Radius.circular(22),
        ),
        border: Border.all(color: titleColor.withValues(alpha: .16)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // gradient stripe
          Container(
            height: 10,
            decoration: BoxDecoration(
              gradient: stripeGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // icon
                Container(
                  width: isMobile ? 34 : 44,
                  height: isMobile ? 34 : 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImageIcon(AssetImage(icon), color: iconColor),
                  ),
                ),
                const SizedBox(width: 14),
                // copy
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + accent dot
                      Text.rich(
                        TextSpan(
                          text: title,
                          style: GoogleFonts.poppins(
                            fontSize: titleSize,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          children: [
                            WidgetSpan(
                              alignment:
                                  PlaceholderAlignment
                                      .middle, // aligns with text
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: accentDot,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: textSize,
                          height: 1.6,
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
    );
  }
}

/*ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1200),
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
child: AnimatedBuilder(
animation: _ac,
builder:
(context, child) =>
IgnorePointer(ignoring: _ac.value < 0.05, child: child),
child: Row(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Expanded(
flex: 6,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Section heading
FadeTransition(
opacity: _fadeTitle,
child: SlideTransition(
position: _slideTitle,
child: Text(
'MISSION & VISION',
style: GoogleFonts.poppins(
fontSize: 46,
fontWeight: FontWeight.w600,
color: primary_color,
height: 1.1,
),
),
),
),
const SizedBox(height: 26),
FadeTransition(
opacity: _fadeMission,
child: ScaleTransition(
scale: _scaleMission,
child: Transform.translate(
offset: Offset(
0,
_parallaxY,
), // subtle scroll parallax
child: _MVCard(
title: 'Our Mission',
titleColor: primary_color,
stripeGradient: const LinearGradient(
colors: [primary_color, primary_color_light],
begin: Alignment.centerLeft,
end: Alignment.centerRight,
),
iconBg: primary_color.withValues(alpha: .08),
iconColor: primary_color,
icon: 'assets/images/target.png',
text: missionText,
accentDot: secondary_color,
),
),
),
),
const SizedBox(height: 24),
FadeTransition(
opacity: _fadeVision,
child: ScaleTransition(
scale: _scaleVision,
child: Transform.translate(
offset: Offset(
0,
-_parallaxY * .7,
), // opposite depth for variety
child: _MVCard(
title: 'Our Vision',
titleColor: primary_color,
stripeGradient: const LinearGradient(
colors: [secondary_color, primary_color],
begin: Alignment.centerLeft,
end: Alignment.centerRight,
),
iconBg: secondary_color.withValues(alpha: .14),
iconColor: const Color(0xFFF4A500),
icon: 'assets/images/vision.png',
text: visionText,
accentDot: primary_color_light,
),
),
),
),

// Cards row
// Column(
//   children: [
//     // Mission
//     Expanded(
//       child:
//     ),
//
//     // Vision
//     Expanded(
//       child:
//     ),
//   ],
// ),
],
),
),
const SizedBox(width: 60),
Expanded(
flex: 7,
child: FadeTransition(
opacity: _fadeIllu,
child: SlideTransition(
position: _slideIllu,
child: ScaleTransition(
scale: _scaleIllu,
child: Transform.translate(
offset: Offset(0, _parallaxY),
child: AspectRatio(
aspectRatio: 4 / 3,
child: ClipRRect(
borderRadius: BorderRadius.circular(24),
child: FadeInSvgAsset(
'assets/illustrations/mission_vision.svg',
fit: BoxFit.contain,
duration: const Duration(
milliseconds: 1500,
), // tweak if you like
curve: Curves.easeOutCubic,
),
),
),
),
),
),
),
),
],
),
),
),
),*/
