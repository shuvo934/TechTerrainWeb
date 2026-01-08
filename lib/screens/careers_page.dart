import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tech_terrain_web/career_sections/career_hero_header.dart';
import 'package:tech_terrain_web/career_sections/open_roles_section.dart';
import 'package:tech_terrain_web/career_sections/perks_section.dart';
import 'package:tech_terrain_web/header_sections/footer_section.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
// import 'package:web/web.dart' as web;

class CareersPage extends StatefulWidget {
  const CareersPage({super.key});

  @override
  State<CareersPage> createState() => _CareersPageState();
}

class _CareersPageState extends State<CareersPage> {
  final _scroll = ScrollController();
  final _rolesAnchor = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Ensure we start at the top when arriving here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _scrollToRoles() {
    final ctx = _rolesAnchor.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      alignment: .05,
    );
  }

  // bool get _isTouchWeb {
  //   if (!kIsWeb) return false;
  //   try {
  //     final hasTouch = (web.window.navigator.maxTouchPoints ?? 0) > 0;
  //     final coarse = web.window.matchMedia('(pointer: coarse)').matches;
  //     return hasTouch || coarse;
  //   } catch (_) {
  //     return false;
  //   }
  //   // final m1 = (web.window.navigator.maxTouchPoints ?? 0) > 0;
  //   // final m2 = web.window.matchMedia('(pointer: coarse)').matches;
  //   // return kIsWeb && (m1 || m2);
  // }
  //
  // bool get _enableSmoothScrollDesktop {
  //   if (!_isTouchWeb && kIsWeb) return true; // desktop web
  //   return false;
  // }
  //
  // ScrollPhysics get _platformPhysics {
  //   if (_enableSmoothScrollDesktop) return const NeverScrollableScrollPhysics();
  //   // native scrolling everywhere else
  //   switch (defaultTargetPlatform) {
  //     case TargetPlatform.iOS:
  //     case TargetPlatform.macOS:
  //       return const BouncingScrollPhysics(
  //         parent: AlwaysScrollableScrollPhysics(),
  //       );
  //     default:
  //       return const ClampingScrollPhysics();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: ResponsiveBuilder(
                  builder: (context, sizing) {
                    final isMobile =
                        sizing.deviceScreenType == DeviceScreenType.mobile;

                    return SvgPicture.asset(
                      isMobile
                          ? 'assets/illustrations/career_hero2.svg'
                          : 'assets/illustrations/career_hero2.svg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    );
                  },
                ),
              ),
              CareerHeroHeader(onViewRoles: _scrollToRoles),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFE5ECFA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              PerksSection(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5ECFA), Color(0xFFF8FAFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              OpenRolesSection(key: _rolesAnchor),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFE5ECFA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              _CareersFAQSection(),
            ],
          ),
          // const SizedBox(height: 48),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              FooterSection(),
            ],
          ),
        ],
      ),
    );
  }
}

// class _LifeAtTTITSection extends StatelessWidget {
//   const _LifeAtTTITSection();
//
//   @override
//   Widget build(BuildContext context) {
//     // Replace with your real assets
//     final images = const [
//       'assets/images/life1.jpg',
//       'assets/images/life2.jpg',
//       'assets/images/life3.jpg',
//       'assets/images/life4.jpg',
//       'assets/images/life5.jpg',
//       'assets/images/life6.jpg',
//     ];
//     return SectionShell(
//       builder: (cfg) {
//         final w = cfg.maxWidth;
//         final cols = w < 640 ? 2 : (w < 980 ? 3 : 4);
//         final gap = 10.0;
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Life at TTIT',
//               style: GoogleFonts.poppins(
//                 fontSize: cfg.h2,
//                 fontWeight: FontWeight.w700,
//                 color: primary_color,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: gap,
//               runSpacing: gap,
//               children: [
//                 for (final p in images)
//                   _HoverImageCard(
//                     path: p,
//                     width: (w - gap * (cols - 1)) / cols,
//                     height: 160,
//                   ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _HoverImageCard extends StatefulWidget {
//   final String path;
//   final double width;
//   final double height;
//   const _HoverImageCard({
//     required this.path,
//     required this.width,
//     required this.height,
//   });
//
//   @override
//   State<_HoverImageCard> createState() => _HoverImageCardState();
// }
//
// class _HoverImageCardState extends State<_HoverImageCard> {
//   bool _hover = false;
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         curve: Curves.easeOut,
//         width: widget.width,
//         height: widget.height,
//         clipBehavior: Clip.hardEdge,
//         decoration: BoxDecoration(
//           color: const Color(0xFFEFF2FF),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: const Color(0x11000000)),
//           boxShadow:
//               _hover
//                   ? const [
//                     BoxShadow(
//                       color: Color(0x14000000),
//                       blurRadius: 14,
//                       offset: Offset(0, 8),
//                     ),
//                   ]
//                   : const [],
//         ),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.asset(widget.path, fit: BoxFit.cover),
//             AnimatedScale(
//               duration: const Duration(milliseconds: 160),
//               scale: _hover ? 1.03 : 1.0,
//               child: const SizedBox.expand(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/* ----------------------------- FAQ ----------------------------- */

class _CareersFAQSection extends StatefulWidget {
  const _CareersFAQSection();

  @override
  State<_CareersFAQSection> createState() => _CareersFAQSectionState();
}

class _CareersFAQSectionState extends State<_CareersFAQSection> {
  final _faqs = const [
    (
      'How do I apply?',
      'Click “Apply” on a role or email your CV with the role in the subject line.',
    ),
    (
      'Is remote work possible?',
      'We are hybrid-first in Dhaka with some fully-remote roles. See each job card.',
    ),
    (
      'Do you offer internships?',
      'Yes—seasonal internships in engineering and design. Keep an eye on this page.',
    ),
    (
      'What does your process look like?',
      'Short intro call → technical/portfolio round → team chat → decision.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      builder:
          (cfg) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FAQ',
                style: GoogleFonts.poppins(
                  fontSize: cfg.h2,
                  fontWeight: FontWeight.w600,
                  color: primary_color,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 10),
              _Accordion(items: _faqs),
            ],
          ),
    );
  }
}

class _Accordion extends StatefulWidget {
  final List<(String, String)> items;
  const _Accordion({required this.items});

  @override
  State<_Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<_Accordion> {
  int _open = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: i == _open,
                onExpansionChanged:
                    (v) => setState(() => _open = v ? i : _open),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  widget.items[i].$1,
                  style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Text(
                    widget.items[i].$2,
                    style: GoogleFonts.beVietnamPro(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/* ---------------------- helpers: Measure ---------------------- */

class _Measure extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;
  const _Measure({required this.child, required this.onChange});
  @override
  State<_Measure> createState() => _MeasureState();
}

class _MeasureState extends State<_Measure> {
  final _key = GlobalKey();
  Size _old = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _key.currentContext;
      if (ctx == null) return;
      final sz = ctx.size ?? Size.zero;
      if ((sz.height - _old.height).abs() > 1 ||
          (sz.width - _old.width).abs() > 1) {
        _old = sz;
        widget.onChange(sz);
      }
    });
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
