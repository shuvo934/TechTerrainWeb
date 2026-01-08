import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ContactFollow extends StatefulWidget {
  const ContactFollow({super.key});

  @override
  State<ContactFollow> createState() => _ContactFollowState();
}

class _ContactFollowState extends State<ContactFollow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
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
  late final Animation<double> _fadeContent = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .95, curve: Curves.easeOut),
  );

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

  Timer? _visDebounce;
  void _onVisibility(VisibilityInfo info) {
    if (!_alive) return;
    _visDebounce?.cancel();
    _visDebounce = Timer(const Duration(milliseconds: 60), () {
      final v = info.visibleFraction;
      if (v >= 0.30 && !_shown) {
        _shown = true;
        _safeForward(from: 0);
      } else if (v <= 0.15 && _shown) {
        _shown = false;
        _safeReverse();
      }
    });
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: ResponsiveBuilder(
        builder: (context, sizing) {
          final isMobile = sizing.deviceScreenType == DeviceScreenType.mobile;
          final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;

          final pad =
              isMobile
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 32)
                  : isTablet
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 48)
                  : const EdgeInsets.symmetric(horizontal: 24, vertical: 70);

          final maxW =
              isMobile
                  ? 680.0
                  : isTablet
                  ? 980.0
                  : 1300.0;

          final h2 =
              isMobile
                  ? 25.0
                  : isTablet
                  ? 32.0
                  : 40.0;

          final followTitle = FadeTransition(
            opacity: _fadeTitle,
            child: SlideTransition(
              position: _slideTitle,
              child: Text(
                'FOLLOW US',
                style: GoogleFonts.poppins(
                  fontSize: h2,
                  fontWeight: FontWeight.w600,
                  color: primary_color,
                ),
              ),
            ),
          );

          Widget followChip = FadeTransition(
            opacity: _fadeContent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialChip.material(
                  icon: Icons.facebook_rounded,
                  tooltip: 'Facebook',
                  onTap: () => _launch('https://www.facebook.com/TerrainSoft'),
                  size:
                      isMobile
                          ? 46
                          : isTablet
                          ? 46
                          : 50,
                ),
                const SizedBox(width: 10),
                _SocialChip.svg(
                  asset: 'assets/images/linkedin.svg',
                  tooltip: 'LinkedIn',
                  onTap:
                      () => _launch(
                        'https://www.linkedin.com/company/terrainsoft',
                      ),
                  size:
                      isMobile
                          ? 46
                          : isTablet
                          ? 46
                          : 50,
                ),
              ],
            ),
          );
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Padding(
                padding: pad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: followTitle),
                    SizedBox(height: isMobile ? 15 : 26),
                    Center(child: followChip),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SocialChip extends StatefulWidget {
  final Widget Function(Color color, double iconSize) iconBuilder;
  final VoidCallback onTap;
  final String tooltip;
  final double size; // outer circle size

  const _SocialChip._({
    required this.iconBuilder,
    required this.onTap,
    required this.tooltip,
    this.size = 40,
  });

  // Material icon version
  factory _SocialChip.material({
    required IconData icon,
    required VoidCallback onTap,
    String tooltip = '',
    double size = 40,
  }) {
    return _SocialChip._(
      onTap: onTap,
      tooltip: tooltip,
      size: size,
      iconBuilder:
          (color, iconSize) => Icon(icon, color: color, size: iconSize * 0.58),
    );
  }

  factory _SocialChip.svg({
    required String asset,
    required VoidCallback onTap,
    String tooltip = '',
    double size = 40,
  }) {
    return _SocialChip._(
      onTap: onTap,
      tooltip: tooltip,
      size: size,
      iconBuilder:
          (color, iconSize) => SvgPicture.asset(
            asset,
            width: iconSize * 0.60,
            height: iconSize * 0.60,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
    );
  }

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final fg = _hover ? Colors.white : primary_color;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _hover ? primary_color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x22000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: widget.iconBuilder(fg, widget.size)),
          ),
        ),
      ),
    );
  }
}
