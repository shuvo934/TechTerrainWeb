import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LeadershipSection extends StatefulWidget {
  const LeadershipSection({super.key});

  @override
  State<LeadershipSection> createState() => _LeadershipSectionState();
}

class _LeadershipSectionState extends State<LeadershipSection>
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

  // cards
  late final Animation<double> _fadeCards = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .95, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideCards = Tween<Offset>(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.15, .95, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _scaleCards = Tween<double>(
        begin: 0.985,
        end: 1.0,
      )
      .chain(CurveTween(curve: const Interval(.15, .95, curve: Curves.easeOut)))
      .animate(_ac);

  final team = const [
    _Leader(
      name: 'Anisul Haq Bhuiya',
      title: 'Chairman',
      avatar: 'assets/images/anisul.png', // place your file here
    ),
    _Leader(
      name: 'Atikur Rahman',
      title: 'Managing Director & CTO',
      avatar: 'assets/images/selim.png', // place your file here
    ),
  ];

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
              final title = FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'LEADERSHIP',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h2,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                      height: 1.06,
                    ),
                  ),
                ),
              );

              // Widget card(_Leader data) => FadeTransition(
              //   opacity: _fadeCards,
              //   child: SlideTransition(
              //     position: _slideCards,
              //     child: ScaleTransition(
              //       scale: _scaleCards,
              //       child: Transform.translate(
              //         offset: Offset(0, _parallaxY),
              //         child: _LeaderCard(data: data, isMobile: cfg.isMobile),
              //       ),
              //     ),
              //   ),
              // );

              final leaderA = FadeTransition(
                opacity: _fadeCards,
                child: SlideTransition(
                  position: _slideCards,
                  child: ScaleTransition(
                    scale: _scaleCards,
                    child: _LeaderTile(
                      data: team.first,
                      isMobile: cfg.isMobile,
                    ),
                  ),
                ),
              );

              final leaderB = FadeTransition(
                opacity: _fadeCards,
                child: SlideTransition(
                  position: _slideCards,
                  child: ScaleTransition(
                    scale: _scaleCards,
                    child: _LeaderTile(data: team.last, isMobile: cfg.isMobile),
                  ),
                ),
              );

              if (cfg.isMobile) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 22),
                      Center(child: leaderA),
                      const SizedBox(height: 25),
                      Center(child: leaderB),
                    ],
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leaderA),
                        const SizedBox(width: 40),
                        Expanded(child: leaderB),
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

class _Leader {
  final String name;
  final String title;
  final String avatar;
  const _Leader({
    required this.name,
    required this.title,
    required this.avatar,
  });
}

class _LeaderTile extends StatefulWidget {
  final _Leader data;
  final bool isMobile;
  const _LeaderTile({required this.data, required this.isMobile});

  @override
  State<_LeaderTile> createState() => _LeaderTileState();
}

class _LeaderTileState extends State<_LeaderTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final photoW = widget.isMobile ? 280.0 : 340.0;
    final photoH = widget.isMobile ? 360.0 : 420.0;
    final infoW = photoW;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: SizedBox(
        width: photoW,
        // Stack height: photo + floating info + its overlap
        height: photoH + 76,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: photoW,
              height: photoH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow:
                    _hover
                        ? const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 24,
                            offset: Offset(0, 14),
                          ),
                        ]
                        : const [],
              ),
              child: _PhotoCard(imagePath: widget.data.avatar, radius: 18),
            ),
            Positioned(
              bottom: 0, //-12
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: infoW,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x11000000)),
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.data.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: widget.isMobile ? 20 : 28,
                        color: primary_color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.data.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: widget.isMobile ? 14 : 16,
                        color: Colors.black.withValues(alpha: .90),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // child: AnimatedContainer(
          //   duration: const Duration(milliseconds: 160),
          //   curve: Curves.easeOut,
          //   transform: Matrix4.identity()..translate(0.0, _hover ? -3.0 : 0.0),
          //   child: GradientBorder(
          //     borderWidth: 5,
          //     borderRadius: BorderRadius.circular(radius),
          //     gradient: const LinearGradient(
          //       colors: [primary_color, primary_color_light],
          //     ),
          //     child: AnimatedContainer(
          //       duration: const Duration(milliseconds: 160),
          //       curve: Curves.easeOut,
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(radius - 5),
          //         boxShadow:
          //             _hover
          //                 ? const [
          //                   BoxShadow(
          //                     color: Color(0x14000000),
          //                     blurRadius: 16,
          //                     offset: Offset(0, 8),
          //                   ),
          //                 ]
          //                 : const [],
          //       ),
          //       padding: const EdgeInsets.all(16),
          //       child: Column(
          //         children: [
          //           _Avatar(
          //             avatar: widget.data.avatar,
          //             size: widget.isMobile ? 140 : 160,
          //           ),
          //           const SizedBox(height: 14),
          //           Text(
          //             widget.data.name,
          //             textAlign: TextAlign.center,
          //             style: GoogleFonts.poppins(
          //               fontWeight: FontWeight.w800,
          //               fontSize: widget.isMobile ? 16 : 18,
          //               color: primary_color,
          //             ),
          //           ),
          //           const SizedBox(height: 4),
          //           Text(
          //             widget.data.title,
          //             textAlign: TextAlign.center,
          //             style: GoogleFonts.beVietnamPro(
          //               fontSize: widget.isMobile ? 14 : 15,
          //               height: 1.35,
          //               color: Colors.black.withValues(alpha: .75),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String imagePath;
  final double radius;
  const _PhotoCard({required this.imagePath, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final isSvg = imagePath.toLowerCase().endsWith('.svg');

    // Gradient border framing the big photo
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary_color, primary_color_light],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius - 5),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                isSvg
                    ? SvgPicture.asset(imagePath, fit: BoxFit.cover)
                    : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
          ),
        ),
      ),
    );
  }
}
