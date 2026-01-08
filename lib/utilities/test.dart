// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:tech_terrain_web/components/gradient_border.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:tech_terrain_web/components/section_shell.dart';
// import 'package:tech_terrain_web/utilities/constants.dart';
//
// class OpenRolesSection extends StatefulWidget {
//   const OpenRolesSection({super.key});
//
//   @override
//   State<OpenRolesSection> createState() => _OpenRolesSectionState();
// }
//
// class _OpenRolesSectionState extends State<OpenRolesSection>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ac = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 700),
//   );
//
//   late final Animation<double> _fadeTitle = CurvedAnimation(
//     parent: _ac,
//     curve: const Interval(.00, .45, curve: Curves.easeOut),
//   );
//   late final Animation<Offset> _slideTitle = Tween<Offset>(
//     begin: const Offset(0, .10),
//     end: Offset.zero,
//   ).animate(
//     CurvedAnimation(
//       parent: _ac,
//       curve: const Interval(.00, .45, curve: Curves.easeOut),
//     ),
//   );
//
//   // SAFE stagger helper (no invalid start/end)
//   Animation<double> _stagger(
//     int i,
//     int n, {
//     double bandStart = .06,
//     double bandEnd = .92,
//     double span = .25,
//   }) {
//     if (n <= 1) {
//       return CurvedAnimation(
//         parent: _ac,
//         curve: Interval(bandStart, bandEnd, curve: Curves.easeOut),
//       );
//     }
//     final usable = (bandEnd - bandStart - span).clamp(0.0, 0.94);
//     final gap = n > 1 ? (usable / (n - 1)) : 0.0;
//     final s = (bandStart + i * gap).clamp(0.0, 0.999);
//     final e = (s + span).clamp(s + 0.0001, 1.0);
//     return CurvedAnimation(
//       parent: _ac,
//       curve: Interval(s, e, curve: Curves.easeOut),
//     );
//   }
//
//   final _visKey = UniqueKey();
//   bool _shown = false;
//   double _parallaxY = 0.0;
//
//   bool _disposed = false;
//   bool get _alive => mounted && !_disposed;
//
//   String _q = '';
//
//   final _roles = <_Role>[
//     _Role('Flutter Engineer', 'Mobile', 'Dhaka', 'Full-time', [
//       'Flutter',
//       'Dart',
//       'REST',
//       'Animations',
//     ]),
//     _Role('Backend Engineer', 'Platform', 'Dhaka', 'Full-time', [
//       'Node',
//       'Postgres',
//       'Microservices',
//       'Docker',
//     ]),
//     _Role('Backend Engineer', 'Database', 'Dhaka', 'Full-time', [
//       'Node',
//       'Postgres',
//       'Microservices',
//       'Docker',
//     ]),
//     _Role('Backend Engineer', 'ASP', 'Dhaka', 'Full-time', [
//       'ASP.NET',
//       'SQL Server',
//       'Microservices',
//       'Docker',
//     ]),
//     _Role('Backend Engineer', 'HTML', 'Dhaka', 'Full-time', [
//       'HTML',
//       'CSS',
//       'JS',
//       'Build Tools',
//     ]),
//     _Role('Backend Engineer', 'Android', 'Dhaka', 'Full-time', [
//       'Kotlin',
//       'Jetpack',
//       'REST',
//       'Play Store',
//     ]),
//     _Role('Backend Engineer', 'iOS', 'Dhaka', 'Full-time', [
//       'Swift',
//       'UIKit/SwiftUI',
//       'REST',
//       'App Store',
//     ]),
//     _Role('Backend Engineer', 'CSS', 'Dhaka', 'Full-time', [
//       'CSS',
//       'Sass',
//       'BEM',
//       'Performance',
//     ]),
//     _Role('Backend Engineer', 'KOTLIN', 'Dhaka', 'Full-time', [
//       'Kotlin',
//       'Coroutines',
//       'Ktor',
//       'Docker',
//     ]),
//     _Role('Frontend Engineer', 'Web', 'Remote', 'Contract', [
//       'React',
//       'Next.js',
//       'UX',
//     ]),
//     _Role('Product Designer', 'Design', 'Dhaka', 'Full-time', [
//       'Figma',
//       'Design systems',
//       'Prototyping',
//     ]),
//   ];
//
//   @override
//   void dispose() {
//     _disposed = true;
//     _ac.dispose();
//     VisibilityDetectorController.instance.forget(_visKey);
//     super.dispose();
//   }
//
//   void _safeForward({double? from}) {
//     if (!_alive) return;
//     if (from != null) {
//       _ac.forward(from: from);
//     } else {
//       _ac.forward();
//     }
//   }
//
//   void _safeReverse() {
//     if (!_alive) return;
//     _ac.reverse();
//   }
//
//   void _safeSetState(VoidCallback fn) {
//     if (!_alive) return;
//     setState(fn);
//   }
//
//   // Defer setState to avoid mouse tracker re-entrancy on web
//   void _deferSet(VoidCallback fn) {
//     if (!mounted) return;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       setState(fn);
//     });
//   }
//
//   void _onVisibility(VisibilityInfo info) {
//     if (!_alive) return;
//     final v = info.visibleFraction;
//
//     if (v >= 0.25 && !_shown) {
//       _shown = true;
//       _safeForward(from: 0.0);
//     } else if (v <= 0.10 && _shown) {
//       _shown = false;
//       _safeReverse();
//     }
//
//     if (v > 0 && v <= 1 && info.size.height > 0) {
//       final center = info.visibleBounds.top + info.visibleBounds.height / 2;
//       final rel = ((center / info.size.height) - .5).clamp(-.8, .8);
//       _safeSetState(() => _parallaxY = rel * 28);
//     }
//   }
//
//   Iterable<_Role> get _filtered {
//     final q = _q.trim().toLowerCase();
//     if (q.isEmpty) return _roles;
//     return _roles.where(
//       (r) =>
//           r.title.toLowerCase().contains(q) ||
//           r.team.toLowerCase().contains(q) ||
//           r.location.toLowerCase().contains(q) ||
//           r.tags.any((t) => t.toLowerCase().contains(q)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return VisibilityDetector(
//       key: _visKey,
//       onVisibilityChanged: _onVisibility,
//       child: Center(
//         child: AnimatedBuilder(
//           animation: _ac,
//           builder:
//               (context, child) =>
//                   IgnorePointer(ignoring: _ac.value < 0.05, child: child),
//           child: SectionShell(
//             builder: (cfg) {
//               final gap = cfg.gap;
//
//               final title = FadeTransition(
//                 opacity: _fadeTitle,
//                 child: SlideTransition(
//                   position: _slideTitle,
//                   child: Transform.translate(
//                     offset: Offset(0, _parallaxY * .3),
//                     child: Text(
//                       'OPEN ROLES',
//                       style: GoogleFonts.poppins(
//                         fontSize: cfg.h2,
//                         fontWeight: FontWeight.w600,
//                         color: primary_color,
//                         height: 1.06,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//
//               final items = _filtered.toList(growable: false);
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   title,
//                   SizedBox(height: cfg.isMobile ? 16 : 20),
//
//                   // 🔎 Single search field (no chips)
//                   SizedBox(
//                     width: cfg.isMobile ? 260 : 380,
//                     child: TextField(
//                       onChanged:
//                           (s) => _deferSet(() {
//                             _q = s;
//                             _ac.forward(from: 0);
//                           }),
//                       decoration: InputDecoration(
//                         hintText: 'Search roles (e.g., Flutter, React, Dhaka)',
//                         prefixIcon: const Icon(Icons.search_rounded),
//                         filled: true,
//                         fillColor: const Color(0xFFF6F8FF),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 12,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           borderSide: const BorderSide(
//                             color: Color(0x11000000),
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           borderSide: const BorderSide(
//                             color: Color(0x11000000),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           borderSide: const BorderSide(color: primary_color),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 14),
//
//                   // Cards with SAFE stagger
//                   Column(
//                     children: [
//                       for (int i = 0; i < items.length; i++)
//                         FadeTransition(
//                           opacity: _stagger(i, items.length),
//                           child: SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(0, .10),
//                               end: Offset.zero,
//                             ).animate(_stagger(i, items.length)),
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                 bottom: i == items.length - 1 ? 0 : gap,
//                               ),
//                               child: _RoleCard(role: items[i]),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//
//                   if (items.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 20.0),
//                       child: Text(
//                         'No roles match your search (for now).',
//                         style: GoogleFonts.beVietnamPro(color: Colors.black54),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _Role {
//   final String title;
//   final String team;
//   final String location;
//   final String type;
//   final List<String> tags;
//   const _Role(this.title, this.team, this.location, this.type, this.tags);
// }
//
// class _RoleCard extends StatelessWidget {
//   final _Role role;
//   const _RoleCard({required this.role});
//
//   @override
//   Widget build(BuildContext context) {
//     return GradientBorder(
//       borderWidth: 4,
//       borderRadius: BorderRadius.circular(16),
//       gradient: const LinearGradient(
//         colors: [primary_color, primary_color_light],
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: LayoutBuilder(
//           builder: (context, c) {
//             final isNarrow = c.maxWidth < 680;
//             final left = Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   role.title,
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 18,
//                     color: primary_color,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 6,
//                   children: [
//                     _Pill(icon: Icons.badge_rounded, text: role.team),
//                     _Pill(icon: Icons.place_rounded, text: role.location),
//                     _Pill(icon: Icons.schedule_rounded, text: role.type),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 6,
//                   runSpacing: 6,
//                   children: role.tags.map((t) => _Tag(t)).toList(),
//                 ),
//               ],
//             );
//
//             final applyBtn = FilledButton.icon(
//               onPressed: () async {
//                 final subject = Uri.encodeComponent(
//                   'Application – ${role.title}',
//                 );
//                 final uri = Uri.parse(
//                   'mailto:info@techterrain-it.com?subject=$subject',
//                 );
//                 await launchUrl(uri);
//               },
//               style: FilledButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 18,
//                   vertical: 14,
//                 ),
//                 shape: const StadiumBorder(),
//               ),
//               icon: const Icon(Icons.send_rounded),
//               label: const Text('Apply'),
//             );
//
//             return isNarrow
//                 ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     left,
//                     const SizedBox(height: 12),
//                     Row(children: [const Spacer(), applyBtn]),
//                   ],
//                 )
//                 : Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(child: left),
//                     const SizedBox(width: 16),
//                     applyBtn,
//                   ],
//                 );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class _Pill extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   const _Pill({required this.icon, required this.text});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF6F8FF),
//         border: Border.all(color: const Color(0x11000000)),
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: primary_color),
//           const SizedBox(width: 6),
//           Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
//
// class _Tag extends StatelessWidget {
//   final String text;
//   const _Tag(this.text);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: primary_color.withOpacity(.08),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: primary_color,
//           fontWeight: FontWeight.w700,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
// }
