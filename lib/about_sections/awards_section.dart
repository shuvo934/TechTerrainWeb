import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class AwardsSection extends StatefulWidget {
  const AwardsSection({super.key});

  @override
  State<AwardsSection> createState() => _AwardsSectionState();
}

class _AwardsSectionState extends State<AwardsSection>
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
  late final Animation<double> _fadeGrid = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .95, curve: Curves.easeOut),
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

  final _visKey = UniqueKey();
  bool _shown = false;
  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  _AwardFilter _filter = _AwardFilter.all;

  final _items = <_AwardItem>[
    _AwardItem(
      kind: AwardKind.basis,
      year: 2018,
      title: 'BASIS National ICT Awards',
      imageAsset: 'assets/awards/2018_stage.jpg', // your file
      city: 'Dhaka',
      countryCode: 'BD',
      note: 'Champion (Digital Government)',
    ),
    _AwardItem(
      kind: AwardKind.basis,
      year: 2019,
      title: 'BASIS National ICT Awards',
      imageAsset: 'assets/awards/2019_runner.jpg',
      city: 'Dhaka',
      countryCode: 'BD',
      note: '1st Runner Up (Digital Government)',
    ),
    _AwardItem(
      kind: AwardKind.basis,
      year: 2020,
      title: 'BASIS National ICT Awards',
      imageAsset: 'assets/awards/2020_winner.png',
      city: 'Dhaka',
      countryCode: 'BD',
      note: 'Winner (Rehab HIS)',
    ),

    // APICTA — no photos, render “Nominee” badge cards
    _AwardItem(
      kind: AwardKind.apicta,
      year: 2018,
      title: 'APICTA NOMINEE',
      imageAsset: null, // 👈 no image
      city: 'Guangzhou',
      countryCode: 'CN',
      note: 'International Nominee – Digital Government',
    ),
    _AwardItem(
      kind: AwardKind.apicta,
      year: 2019,
      title: 'APICTA NOMINEE',
      imageAsset: null,
      city: 'Ha Long',
      countryCode: 'VN',
      note: 'International Nominee – HealthTech',
    ),
    _AwardItem(
      kind: AwardKind.apicta,
      year: 2020, // held 2020–21
      title: 'APICTA NOMINEE',
      imageAsset: null,
      city: 'Kuala Lumpur',
      countryCode: 'MY',
      note: 'International Nominee – Digital Government',
    ),
  ];

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
    final Iterable<_AwardItem> base = switch (_filter) {
      _AwardFilter.all => _items,
      _AwardFilter.basis => _items.where((e) => e.kind == AwardKind.basis),
      _AwardFilter.apicta => _items.where((e) => e.kind == AwardKind.apicta),
    };

    // make a modifiable copy, then sort (newest first)
    final List<_AwardItem> filtered =
        base.toList()..sort((a, b) => b.year.compareTo(a.year));

    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: SectionShell(
        builder: (cfg) {
          final gap = cfg.gap;
          final chip = FadeTransition(
            opacity: _fadeChips,
            child: ScaleTransition(
              scale: _scaleChips,
              child: _FilterChip(
                value: _filter,
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
          );

          // compute grid columns
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'AWARDS & RECOGNITION',
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
                    'Celebrating a decade of impact across Bangladesh and the Asia-Pacific.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: cfg.isMobile ? 15 : 16,
                      color: Colors.black.withValues(alpha: .85),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Filter chips
              chip,
              SizedBox(height: gap),

              // Grid
              LayoutBuilder(
                builder: (context, c) {
                  final maxW = c.maxWidth;
                  final cols = maxW < 640 ? 1 : (maxW < 980 ? 2 : 3);
                  final cardW = (maxW - (cols - 1) * gap) / cols;

                  return FadeTransition(
                    opacity: _fadeGrid,
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (int i = 0; i < filtered.length; i++)
                          SizedBox(
                            width: cardW,
                            child: _AwardCard(
                              item: filtered[i],
                              onTap: () => _openGallery(filtered, i),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openGallery(List<_AwardItem> items, int index) async {
    await showDialog(
      context: context,
      barrierColor: const Color(0xCC000000),
      builder: (_) => _GalleryOverlay(items: items, initialIndex: index),
    );
  }
}

// === Models ===

// enum AwardKind { basis, apicta }
//
// class _AwardItem {
//   final AwardKind kind;
//   final int year;
//   final String title;
//   final String subtitle;
//   final String location;
//   final String asset;
//
//   const _AwardItem({
//     required this.kind,
//     required this.year,
//     required this.title,
//     required this.subtitle,
//     required this.location,
//     required this.asset,
//   });
// }

enum AwardKind { basis, apicta }

class _AwardItem {
  final AwardKind kind;
  final int year;
  final String title; // e.g. “BASIS National ICT Awards”
  final String? imageAsset; // null => text-only / badge card
  final String city; // e.g. Guangzhou
  final String countryCode; // e.g. CN
  final String note; // short one-liner

  const _AwardItem({
    required this.kind,
    required this.year,
    required this.title,
    required this.imageAsset,
    required this.city,
    required this.countryCode,
    required this.note,
  });
}

// === Filter chips ===
enum _AwardFilter { all, basis, apicta }

class _FilterChip extends StatelessWidget {
  final _AwardFilter value;
  final ValueChanged<_AwardFilter> onChanged;
  const _FilterChip({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, _AwardFilter v) {
      final selected = value == v;
      return ChoiceChip(
        selected: selected,
        label: Text(label, style: GoogleFonts.beVietnamPro()),
        selectedColor: primary_color.withValues(alpha: .12),
        labelStyle: GoogleFonts.beVietnamPro(
          color: selected ? primary_color : Colors.black.withValues(alpha: .70),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (_) => onChanged(v),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? primary_color : const Color(0x22000000),
          ),
        ),
        backgroundColor: Colors.white,
      );
    }

    return Wrap(
      spacing: 10,
      children: [
        chip('All', _AwardFilter.all),
        chip('BASIS Awards', _AwardFilter.basis),
        chip('APICTA', _AwardFilter.apicta),
      ],
    );
  }
}

// === Award Card ===

class _AwardCard extends StatelessWidget {
  final _AwardItem item;
  final VoidCallback onTap;
  const _AwardCard({required this.item, required this.onTap});
  // const _AwardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageAsset != null;

    // Keep media area heights consistent so the grid looks neat
    const mediaH = 180.0;

    Widget media;
    if (hasImage) {
      media = ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: SizedBox(
          height: mediaH,
          width: double.infinity,
          child: Image.asset(item.imageAsset!, fit: BoxFit.cover),
        ),
      );
    } else {
      // Text/badge header for APICTA
      media = Container(
        height: mediaH,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          gradient: LinearGradient(
            colors: [primary_color, primary_color_light],
          ),
        ),
        child: _NomineeHeader(year: item.year, label: 'APICTA Nominee'),
      );
    }

    return GestureDetector(
      onTap: hasImage ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x11000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            media,
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff204EB8),
                          ),
                        ),
                      ),
                      _KindChip(kind: item.kind),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location line
                  Row(
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: Color(0x99000000),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_flagEmoji(item.countryCode)} ${item.city}, ${_countryName(item.countryCode)} • ${item.year}',
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.black.withValues(alpha: .72),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.note,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: .82),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Gradient “Nominee” header used when there’s no image
class _NomineeHeader extends StatelessWidget {
  final int year;
  final String label;
  const _NomineeHeader({required this.year, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // subtle circles
        Positioned(right: -20, top: -30, child: _softCircle(160)),
        Positioned(left: -30, bottom: -20, child: _softCircle(120)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$year',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _softCircle(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0x1AFFFFFF),
    ),
  );
}

class _KindChip extends StatelessWidget {
  final AwardKind kind;
  const _KindChip({required this.kind});
  @override
  Widget build(BuildContext context) {
    final isBasis = kind == AwardKind.basis;
    final bg = isBasis ? const Color(0x14FFCC33) : const Color(0x14204EB8);
    final fg = isBasis ? const Color(0xffA17600) : const Color(0xff204EB8);
    final text = isBasis ? 'BASIS' : 'APICTA';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: .22)),
      ),
      child: Text(
        text,
        style: GoogleFonts.beVietnamPro(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

String _flagEmoji(String cc) {
  // country code → regional indicator symbols
  final base = 0x1F1E6;
  final chars = cc.toUpperCase().codeUnits.map((c) => base + c - 65);
  return String.fromCharCodes(chars);
}

String _countryName(String cc) {
  switch (cc.toUpperCase()) {
    case 'CN':
      return 'China';
    case 'VN':
      return 'Vietnam';
    case 'MY':
      return 'Malaysia';
    case 'BD':
      return 'Bangladesh';
    default:
      return cc;
  }
}

// class _AwardCard extends StatefulWidget {
//   final _AwardItem item;
//   final VoidCallback onTap;
//   const _AwardCard({required this.item, required this.onTap});
//
//   @override
//   State<_AwardCard> createState() => _AwardCardState();
// }
//
// class _AwardCardState extends State<_AwardCard> {
//   bool _hover = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final radius = 16.0;
//
//     final tag = switch (widget.item.kind) {
//       AwardKind.basis => 'BASIS • ${widget.item.year}',
//       AwardKind.apicta => 'APICTA • ${widget.item.year}',
//     };
//
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: GradientBorder(
//           borderWidth: 5,
//           borderRadius: BorderRadius.circular(radius),
//           gradient: const LinearGradient(
//             colors: [primary_color, primary_color_light],
//           ),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 160),
//             curve: Curves.easeOut,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(radius - 5),
//               boxShadow:
//                   _hover
//                       ? const [
//                         BoxShadow(
//                           color: Color(0x14000000),
//                           blurRadius: 16,
//                           offset: Offset(0, 8),
//                         ),
//                       ]
//                       : const [],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image (kept ratio to avoid layout issues)
//                 ClipRRect(
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(radius - 5),
//                   ),
//                   child: AspectRatio(
//                     aspectRatio: 16 / 9,
//                     child: Image.asset(
//                       widget.item.asset,
//                       fit: BoxFit.cover,
//                       filterQuality: FilterQuality.high,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // tag
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: primary_color.withOpacity(.08),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Text(
//                           tag,
//                           style: const TextStyle(
//                             color: primary_color,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         widget.item.title,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                           height: 1.25,
//                           color: Colors.black.withOpacity(.92),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${widget.item.subtitle} • ${widget.item.location}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.black.withOpacity(.65),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// === Lightbox / Gallery ===
class _GalleryOverlay extends StatefulWidget {
  final List<_AwardItem> items;
  final int initialIndex;
  const _GalleryOverlay({required this.items, required this.initialIndex});

  @override
  State<_GalleryOverlay> createState() => _GalleryOverlayState();
}

class _GalleryOverlayState extends State<_GalleryOverlay> {
  late final PageController _pc = PageController(
    initialPage: widget.initialIndex,
  );
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_index];

    // int length = 0;
    // for (int i = 0; i < widget.items.length; i++) {
    //   bool hasImage = widget.items[i].imageAsset != null;
    //   if (hasImage) {
    //     length++;
    //   }
    // }

    Widget roundArrow(IconData icon, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: primary_color),
      ),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, c) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // image
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pc,
                        itemCount: widget.items.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder:
                            (_, i) => Container(
                              color: const Color(0xFF0A0A0A),
                              child: Center(
                                child: InteractiveViewer(
                                  minScale: 0.8,
                                  child: Image.asset(
                                    widget.items[i].imageAsset!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                      ),
                      // arrows (desktop/tablet)
                      // if (c.maxWidth > 600) ...[
                      //   Positioned(
                      //     left: 8,
                      //     top: 0,
                      //     bottom: 0,
                      //     child: Center(
                      //       child: roundArrow(
                      //         Icons.chevron_left_rounded,
                      //         () => _pc.previousPage(
                      //           duration: const Duration(milliseconds: 320),
                      //           curve: Curves.easeOut,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   Positioned(
                      //     right: 8,
                      //     top: 0,
                      //     bottom: 0,
                      //     child: Center(
                      //       child: roundArrow(
                      //         Icons.chevron_right_rounded,
                      //         () => _pc.nextPage(
                      //           duration: const Duration(milliseconds: 320),
                      //           curve: Curves.easeOut,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                      // close
                      Positioned(
                        right: 8,
                        top: 8,
                        child: roundArrow(
                          Icons.close_rounded,
                          () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ],
                  ),
                ),
                // caption
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.title} — ${item.year} • ${item.city}',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            color: Colors.black.withValues(alpha: .82),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
