import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tech_terrain_web/components/measure_size.dart';
import 'package:web/web.dart' as web; // typed DOM (HTMLIFrameElement, etc.)
import 'dart:ui_web'
    as ui_web
    show platformViewRegistry; // platformViewRegistry for web

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/gradient_border.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ContactFindUs extends StatefulWidget {
  const ContactFindUs({super.key});

  @override
  State<ContactFindUs> createState() => _ContactFindUsState();
}

class _ContactFindUsState extends State<ContactFindUs>
    with SingleTickerProviderStateMixin {
  // Animations
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

  static const _address =
      'House #12, Road #17/A, Block #E,\nBanani, Dhaka-1213\nBangladesh';
  static const _mapsDeepLink = 'https://maps.app.goo.gl/cR5eshAkf7imjeVL8';

  final _visKey = UniqueKey();
  bool _shown = false;
  double? _leftHeight;

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
      child: SectionShell(
        builder: (cfg) {
          final isStacked = cfg.isMobile || cfg.isTablet;
          final gap = cfg.gap;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'FIND US',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h2,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                ),
              ),
              SizedBox(height: cfg.isMobile ? 15 : 26),

              FadeTransition(
                opacity: _fadeContent,
                child:
                    isStacked
                        ? Column(
                          children: [
                            _LeftInfoBlock(
                              onCall: () => _launch('tel:+8801404030556'),
                              onMail:
                                  () =>
                                      _launch('mailto:info@techterrain-it.com'),
                              onFacebook:
                                  () => _launch(
                                    'https://www.facebook.com/TerrainSoft',
                                  ),
                              onLinkedIn:
                                  () => _launch(
                                    'https://www.linkedin.com/company/terrainsoft',
                                  ),
                              address: _address,
                              isMobTab: isStacked,
                            ),
                            SizedBox(height: gap),

                            _RightMapBlock(
                              onMap: () => _launch(_mapsDeepLink),
                              mapsEmbedAddress: _address,
                              isMobTab: isStacked,
                              desiredHeight: _leftHeight,
                              lat: 23.79250270838201,
                              lng: 90.4071726816135,
                            ),
                          ],
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MeasureSize(
                                onChange:
                                    (s) =>
                                        setState(() => _leftHeight = s.height),
                                child: _LeftInfoBlock(
                                  onCall: () => _launch('tel:+8801404030556'),
                                  onMail:
                                      () => _launch(
                                        'mailto:info@techterrain-it.com',
                                      ),
                                  onFacebook:
                                      () => _launch(
                                        'https://www.facebook.com/TerrainSoft',
                                      ),
                                  onLinkedIn:
                                      () => _launch(
                                        'https://www.linkedin.com/company/terrainsoft',
                                      ),
                                  address: _address,
                                  isMobTab: isStacked,
                                ),
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: _RightMapBlock(
                                onMap: () => _launch(_mapsDeepLink),
                                mapsEmbedAddress: _address,
                                isMobTab: isStacked,
                                desiredHeight: _leftHeight,
                                lat: 23.79250270838201,
                                lng: 90.4071726816135,
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------- LEFT: Info + Map ----------

class _LeftInfoBlock extends StatefulWidget {
  final VoidCallback onCall, onMail, onFacebook, onLinkedIn;
  final String address;
  final bool isMobTab;

  const _LeftInfoBlock({
    required this.onCall,
    required this.onMail,
    required this.onFacebook,
    required this.onLinkedIn,
    required this.address,
    required this.isMobTab,
  });

  @override
  State<_LeftInfoBlock> createState() => _LeftInfoBlockState();
}

class _LeftInfoBlockState extends State<_LeftInfoBlock> {
  double? _widgetHeight;
  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.beVietnamPro(color: Colors.black87);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MeasureSize(
                onChange: (s) => setState(() => _widgetHeight = s.height),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x11000000)),
                  ),
                  child: _RowIconText(
                    icon: Icons.place_rounded,
                    title: 'Address',
                    child: SelectableText(widget.address, style: valueStyle),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: _widgetHeight,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x11000000)),
                ),
                child: _RowIconText(
                  icon: Icons.call_rounded,
                  title: 'Phone',
                  child:
                      widget.isMobTab
                          ? _LinkButton(
                            label: '+880 140 403 0556',
                            onTap: widget.onCall,
                          )
                          : SelectableText(
                            '+880 140 403 0556',
                            style: valueStyle,
                          ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Container(
                height: _widgetHeight,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x11000000)),
                ),
                child: _RowIconText(
                  icon: Icons.email_rounded,
                  title: 'Email',
                  child:
                      widget.isMobTab
                          ? _LinkButton(
                            label: 'info@techterrain-it.com',
                            onTap: widget.onMail,
                          )
                          : SelectableText(
                            'info@techterrain-it.com',
                            style: valueStyle,
                          ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: _widgetHeight,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x11000000)),
                ),
                child: _RowIconText(
                  icon: Icons.access_time_rounded,
                  title: 'Opening Hours',
                  child: Text(
                    'SAT – THU \n• 10:00 am – 06:30 pm',
                    style: valueStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RowIconText extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? child;

  const _RowIconText({required this.icon, required this.title, this.child});

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary_color, size: 25),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              SizedBox(height: 3),
              if (child != null) child!,
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LinkButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: primary_color,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: primary_color,
          ),
        ),
      ),
    );
  }
}

class _RightMapBlock extends StatelessWidget {
  final VoidCallback onMap;
  final String mapsEmbedAddress;
  final bool isMobTab;
  final double? desiredHeight;
  final double? lat;
  final double? lng;

  const _RightMapBlock({
    required this.onMap,
    required this.mapsEmbedAddress,
    required this.isMobTab,
    required this.desiredHeight,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return _MapCard(
      address: mapsEmbedAddress,
      onOpenMaps: onMap,
      desiredHeight: desiredHeight,
      lat: lat,
      lng: lng,
    );
  }
}

class _MapCard extends StatelessWidget {
  final String address;
  final VoidCallback onOpenMaps;
  final double? desiredHeight;
  final double? lat;
  final double? lng;

  const _MapCard({
    required this.address,
    required this.onOpenMaps,
    this.desiredHeight,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    const borderW = 5.0; // your GradientBorder width
    const buttonH = 48.0;

    final gradient = const LinearGradient(
      colors: [Color(0xFFF8FAFF), Color(0xFFF8FAFF)], //primary_color_light
    );

    final mapViewportHeight =
        (desiredHeight != null)
            ? (desiredHeight! - buttonH - (borderW * 2)).clamp(180.0, 10000.0)
            : 260.0;

    final mapWidget =
        kIsWeb
            ? _WebMapEmbed(
              address: address,
              lat: lat,
              lng: lng,
            ) // iframe embed on web
            : _MapPlaceholder(
              onOpen: onOpenMaps,
            ); // big call-to-action on other platforms

    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: GradientBorder(
        borderWidth: borderW,
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: mapViewportHeight,
                child: mapWidget,
              ), // sensible height
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: onOpenMaps,
                  child: SizedBox(
                    height: buttonH,
                    child: Center(
                      child: Text(
                        'Open in Google Maps',
                        style: GoogleFonts.beVietnamPro(
                          color: primary_color,
                          fontWeight: FontWeight.w500,
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
    );
  }
}

class _WebMapEmbed extends StatefulWidget {
  final String address;
  final double? lat;
  final double? lng;

  const _WebMapEmbed({required this.address, this.lat, this.lng});

  @override
  State<_WebMapEmbed> createState() => _WebMapEmbedState();
}

class _WebMapEmbedState extends State<_WebMapEmbed> {
  late final String _viewType =
      'ttit-map-${widget.address.hashCode}-${widget.lat}-${widget.lng}';
  @override
  void initState() {
    super.initState();
    final src =
        (widget.lat != null && widget.lng != null)
            ? 'https://www.google.com/maps?q=${widget.lat},${widget.lng}&z=17&output=embed&hl=en'
            : 'https://www.google.com/maps?q=${Uri.encodeComponent(widget.address)}&z=17&output=embed&hl=en';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe =
          web.HTMLIFrameElement()
            ..src = src
            ..style.border = '0'
            ..style.width = '100%'
            ..style.height = '100%'
            ..loading = 'lazy'
            ..allow = 'fullscreen';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

class _MapPlaceholder extends StatelessWidget {
  final VoidCallback onOpen;
  const _MapPlaceholder({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Container(
        color: const Color(0xFFF6F8FF),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_rounded, size: 42, color: primary_color),
            SizedBox(height: 8),
            Text(
              'Tap to open Google Maps',
              style: TextStyle(color: primary_color),
            ),
          ],
        ),
      ),
    );
  }
}
