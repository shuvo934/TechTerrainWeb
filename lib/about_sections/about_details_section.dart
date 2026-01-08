import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/fade_in_svg_asset.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AboutDetailsSection extends StatefulWidget {
  const AboutDetailsSection({super.key});

  @override
  State<AboutDetailsSection> createState() => _AboutDetailsSectionState();
}

class _AboutDetailsSectionState extends State<AboutDetailsSection>
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
    final aboutText =
        'Tech Terrain IT Ltd. is a Dhaka-based software company founded in 2010 with a vision to'
        ' transform businesses through innovation, automation, and tailored technology solutions. Over the past decade,'
        ' we’ve grown into a trusted technology partner for leading enterprises, government organizations, and global collaborators.';

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
                          'assets/illustrations/innovation_section.svg',
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
                    'Empowering Businesses with Innovative Software Solutions',
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

              final nextText = FadeTransition(
                opacity: _fadeBody,
                child: SlideTransition(
                  position: _slideBody,
                  child: Text(
                    'We specialize in:',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.body,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: .9),
                    ),
                  ),
                ),
              );

              final bullets = [
                _BulletModel(
                  icon: Icons.health_and_safety_rounded,
                  iconColor: primary_color_light,
                  title: 'HealthTech',
                  text:
                      'Our flagship solution, Rehab HIS, is powering the Centre for the Rehabilitation of the Paralyzed (CRP), serving 1.5M+ registered patients, enabling 8M+ successful appointments, and generating 45M+ invoices to date.',
                  chips: const [
                    _StatChipData('1.5M+ Patients'),
                    _StatChipData('8M+ Appointments'),
                    _StatChipData('45M+ Invoices'),
                  ],
                ),
                _BulletModel(
                  icon: Icons.stacked_bar_chart_rounded,
                  iconColor: primary_color,
                  title: 'Enterprise Applications',
                  text:
                      'Full-scale ERP, HRM, CRM, and Accounts Management Systems that empower pharmaceutical, garments, and manufacturing industries.',
                ),
                _BulletModel(
                  icon: Icons.auto_fix_high_rounded,
                  iconColor: secondary_color,
                  title: 'Custom Solutions',
                  text:
                      'From Food Manufacturing Software to specialized automation for SMEs, we deliver solutions built around your exact needs.',
                ),
                _BulletModel(
                  icon: Icons.public_rounded,
                  iconColor: primary_color_light,
                  title: 'GovTech & Climate Solutions',
                  text:
                      'Driving large-scale impact through digital transformation projects like Agro-Meteorological Information Systems Development (DAE, World Bank funded) and Building Climate Resilient Livelihoods (BCRL).',
                ),
              ];

              Widget buildCard(int i, _BulletModel m) {
                final a = _cardAnims(i);
                return FadeTransition(
                  opacity: a.fade,
                  child: SlideTransition(
                    position: a.slide,
                    child: ScaleTransition(
                      scale: a.scale,
                      child: _Bullet(model: m),
                    ),
                  ),
                );
              }

              if (cfg.isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 12),
                    bodyText,
                    const SizedBox(height: 25),
                    illu,
                    const SizedBox(height: 25),
                    nextText,
                    const SizedBox(height: 10),
                    // Bullets
                    for (int i = 0; i < bullets.length; i++) ...[
                      buildCard(i, bullets[i]),
                      if (i < bullets.length - 1) SizedBox(height: 12),
                    ],
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 25),
                    bodyText,
                    SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Content
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nextText,
                              const SizedBox(height: 16),
                              // Bullets
                              for (int i = 0; i < bullets.length; i++) ...[
                                buildCard(i, bullets[i]),
                                if (i < bullets.length - 1)
                                  SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                        Expanded(flex: 5, child: illu),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ------------------ Helpers ------------------

class _BulletModel {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;
  final List<_StatChipData> chips;

  const _BulletModel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
    this.chips = const [],
  });
}

class _Bullet extends StatelessWidget {
  final _BulletModel model;
  const _Bullet({required this.model});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon pill
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: model.iconColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(model.icon, color: model.iconColor, size: 26),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model.text,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: isMobile ? 12 : 14,
                    height: 1.55,
                    color: Colors.black.withValues(alpha: .82),
                  ),
                ),
                if (model.chips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        model.chips
                            .map((c) => _StatChip(label: c.label))
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChipData {
  final String label;
  const _StatChipData(this.label);
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary_color, primary_color_light],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
