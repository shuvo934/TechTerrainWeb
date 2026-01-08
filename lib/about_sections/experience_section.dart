import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/components/gradient_border.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _fadeTitle = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.00, .40, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideTitle = Tween(
    begin: const Offset(0, .10),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.00, .40, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _fadeGrid = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.18, .95, curve: Curves.easeOut),
  );

  final _visKey = UniqueKey();
  bool _shown = false;
  double _parallaxY = 0.0;
  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  @override
  void dispose() {
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

  void _safeSetState(VoidCallback fn) {
    if (!_alive) return;
    setState(fn);
  }

  void _onVis(VisibilityInfo info) {
    final v = info.visibleFraction;
    if (v >= 0.25 && !_shown) {
      _shown = true;
      _safeForward(from: 0.0);
    } else if (v <= 0.10 && _shown) {
      _shown = false;
      _safeReverse();
    }

    if (v > 0 && v <= 1 && info.size.height > 0) {
      final center = info.visibleBounds.top + info.visibleBounds.height / 2;
      final rel = ((center / info.size.height) - .5).clamp(-.8, .8);
      _safeSetState(() => _parallaxY = rel * 28); // slightly softer than hero
    }
  }

  final List<_CertItem> _items = const [
    _CertItem(
      asset: 'assets/experience/crp.png',
      title: 'Experience Certificate',
      org: 'CRP',
      year: 2015,
    ),
    _CertItem(
      asset: 'assets/experience/envoy.png',
      title: 'Experience Certificate',
      org: 'Envoy',
      year: 2013,
    ),
    _CertItem(
      asset: 'assets/experience/mondol.jpg',
      title: 'Experience Certificate',
      org: 'Mondol',
      year: 2015,
    ),
    _CertItem(
      asset: 'assets/experience/osman.jpg',
      title: 'Experience Certificate',
      org: 'Osman',
      year: 2015,
    ),
    _CertItem(
      asset: 'assets/experience/elite.jpg',
      title: 'Experience Certificate',
      org: 'Elite Force',
      year: 2016,
    ),
    _CertItem(
      asset: 'assets/experience/progress.png',
      title: 'Experience Certificate',
      org: 'Progress Group',
      year: 2018,
    ),
  ];

  void _openLightbox(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder:
          (_, __, ___) => _Lightbox(items: _items, initialIndex: index),
      transitionBuilder: (_, anim, __, child) {
        final t = Curves.easeOut.transform(anim.value);
        return Opacity(opacity: t, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVis,
      child: SectionShell(
        builder: (cfg) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeTitle,
                child: Transform.translate(
                  offset: Offset(0, _parallaxY * .3),
                  child: SlideTransition(
                    position: _slideTitle,
                    child: Text(
                      'EXPERIENCE CERTIFICATES',
                      style: GoogleFonts.poppins(
                        fontSize: cfg.h2,
                        fontWeight: FontWeight.w600,
                        color: primary_color,
                        height: 1.06,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Grid
              FadeTransition(
                opacity: _fadeGrid,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    int cols;
                    if (w >= 1200) {
                      cols = 4;
                    } else if (w >= 950) {
                      cols = 3;
                    } else if (w >= 620) {
                      cols = 2;
                    } else {
                      cols = 1;
                    }
                    final gap = cfg.gap;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        childAspectRatio: 4 / 3, // neat thumb ratio
                      ),
                      itemBuilder:
                          (context, i) => _CertCard(
                            item: _items[i],
                            onTap: () => _openLightbox(i),
                          ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CertItem {
  final String asset;
  final String title;
  final String org;
  final int year;
  const _CertItem({
    required this.asset,
    required this.title,
    required this.org,
    required this.year,
  });
}

class _CertCard extends StatefulWidget {
  final _CertItem item;
  final VoidCallback onTap;
  const _CertCard({required this.item, required this.onTap});

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    const radius = 14.0;

    final overlay = AnimatedOpacity(
      opacity: _hover ? 1 : 0,
      duration: const Duration(milliseconds: 160),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x66000000),
          borderRadius: BorderRadius.circular(radius - 4),
        ),
        child: const Center(
          child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 38),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: GradientBorder(
          borderWidth: 5,
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            colors: [primary_color, primary_color_light],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 5),
            child: Stack(
              children: [
                // media
                Positioned.fill(
                  child: Hero(
                    tag: widget.item.asset,
                    child: Image.asset(
                      widget.item.asset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                // overlay on hover
                Positioned.fill(child: overlay),
                // caption bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: .54),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Chip('${widget.item.org} • ${widget.item.year}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

/// Full-screen viewer with swipe, zoom, arrows & ESC.
class _Lightbox extends StatefulWidget {
  final List<_CertItem> items;
  final int initialIndex;
  const _Lightbox({required this.items, required this.initialIndex});

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _pc = PageController(
    initialPage: widget.initialIndex,
  );
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _prev() {
    if (_index > 0) {
      _pc.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  void _next() {
    if (_index < widget.items.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // pages
            Positioned.fill(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: widget.items.length,
                itemBuilder: (context, i) {
                  final it = widget.items[i];
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Hero(
                        tag: it.asset,
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Image.asset(it.asset, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // close
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Close',
              ),
            ),

            // arrows (desktop/tablet)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: _RoundArrow(
                direction: AxisDirection.left,
                onTap: _prev,
                enabled: _index > 0,
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: _RoundArrow(
                direction: AxisDirection.right,
                onTap: _next,
                enabled: _index < widget.items.length - 1,
              ),
            ),

            // caption
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.items[_index].title} • '
                    '${widget.items[_index].org} • '
                    '${widget.items[_index].year}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundArrow extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onTap;
  final bool enabled;
  const _RoundArrow({
    required this.direction,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = direction == AxisDirection.left;
    return Center(
      child: Opacity(
        opacity: enabled ? 1 : .35,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
