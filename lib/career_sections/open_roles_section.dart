import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum _EmailOption { defaultApp, gmail, outlook, copy }

class OpenRolesSection extends StatefulWidget {
  const OpenRolesSection({super.key});

  @override
  State<OpenRolesSection> createState() => _OpenRolesSectionState();
}

class _OpenRolesSectionState extends State<OpenRolesSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  // late final Animation<double> _fadeTitle = CurvedAnimation(
  //   parent: _ac,
  //   curve: const Interval(.00, .45, curve: Curves.easeOut),
  // );
  // late final Animation<Offset> _slideTitle = Tween<Offset>(
  //   begin: const Offset(0, .10),
  //   end: Offset.zero,
  // ).animate(
  //   CurvedAnimation(
  //     parent: _ac,
  //     curve: const Interval(.00, .45, curve: Curves.easeOut),
  //   ),
  // );

  Animation<double> _stagger(
    int i,
    int n, {
    double bandStart = .06, // where the whole stagger band begins
    double bandEnd = .92, // where the band ends
    double span = .25, // length of each item’s animation window
  }) {
    // guard
    if (n <= 1) {
      return CurvedAnimation(
        parent: _ac,
        curve: Interval(bandStart, bandEnd, curve: Curves.easeOut),
      );
    }
    final usable = (bandEnd - bandStart - span).clamp(0.0, 0.94);
    final gap = n > 1 ? (usable / (n - 1)) : 0.0;
    final s = (bandStart + i * gap).clamp(0.0, 0.999);
    final e = (s + span).clamp(s + 0.0001, 1.0); // ensure end > start
    return CurvedAnimation(
      parent: _ac,
      curve: Interval(s, e, curve: Curves.easeOut),
    );
  }

  final _visKey = UniqueKey();
  bool _shown = false;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  String _team = 'All';
  String _loc = 'All';
  String _q = '';

  final _roles = <_Role>[
    // _Role('Flutter Engineer', 'Mobile', 'Dhaka', 'Full-time', [
    //   'Flutter',
    //   'Dart',
    //   'REST',
    //   'Animations',
    // ]),
    // _Role('Backend Engineer', 'Platform', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'Database', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'ASP', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'HTML', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'Android', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'IOS', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'CSS', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Backend Engineer', 'KOTLIN', 'Dhaka', 'Full-time', [
    //   'Node',
    //   'Postgres',
    //   'Microservices',
    //   'Docker',
    // ]),
    // _Role('Frontend Engineer', 'Web', 'Remote', 'Contract', [
    //   'React',
    //   'Next.js',
    //   'UX',
    // ]),
    // _Role('Product Designer', 'Design', 'Dhaka', 'Full-time', [
    //   'Figma',
    //   'Design systems',
    //   'Proto',
    // ]),
  ];

  @override
  void dispose() {
    _disposed = true;
    _ac.dispose();
    _visDebounce?.cancel();
    VisibilityDetectorController.instance.forget(_visKey);
    super.dispose();
  }

  void _deferSet(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
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

  // Future<void> _sendOpenEmail() async {
  //   final to = 'info@techterrain-it.com';
  //   final subject = 'Open application';
  //   final body =
  //       'Hi Tech Terrain IT Team,\n\n'
  //       'I’m interested in future opportunities. Please find my CV attached.\n\n'
  //       'Regards,\n';
  //
  //   String enc(String s) => Uri.encodeComponent(s);
  //
  //   // 1) Try the user's default mail app via mailto:
  //   final mailto = Uri.parse(
  //     'mailto:$to?subject=${enc(subject)}&body=${enc(body)}',
  //   );
  //
  //   final okMail = await launchUrl(
  //     mailto,
  //     mode: LaunchMode.externalApplication, // chooser on mobile/desktop
  //   );
  //   if (okMail) {
  //     _toast('Opening your email app…');
  //     return;
  //   }
  //
  //   // 2) Fallback: Gmail web compose
  //   final gmail = Uri.parse(
  //     'https://mail.google.com/mail/?view=cm&fs=1'
  //     '&to=${enc(to)}&su=${enc(subject)}&body=${enc(body)}',
  //   );
  //   if (await launchUrl(gmail, mode: LaunchMode.platformDefault)) {
  //     _toast('Opening Gmail…');
  //     return;
  //   }
  //
  //   // 3) Fallback: Outlook web compose
  //   final outlook = Uri.parse(
  //     'https://outlook.office.com/mail/deeplink/compose'
  //     '?to=${enc(to)}&subject=${enc(subject)}&body=${enc(body)}',
  //   );
  //   if (await launchUrl(outlook, mode: LaunchMode.platformDefault)) {
  //     _toast('Opening Outlook…');
  //     return;
  //   }
  //
  //   // 4) Final fallback: copy + show dialog
  //   await Clipboard.setData(ClipboardData(text: to));
  //   if (!mounted) return;
  //   showDialog(
  //     context: context,
  //     builder:
  //         (_) => AlertDialog(
  //           title: const Text('No email app found'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'We couldn’t open an email app. The address has been copied:',
  //               ),
  //               const SizedBox(height: 8),
  //               SelectableText(
  //                 to,
  //                 style: const TextStyle(fontWeight: FontWeight.w700),
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  Future<_EmailOption?> _chooseEmailProvider(BuildContext context) {
    return showDialog<_EmailOption>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Send email via', style: GoogleFonts.beVietnamPro()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_rounded,
                    color: primary_color,
                  ),
                  title: const Text('Mail app (default)'),
                  subtitle: const Text('Open your installed email client'),
                  onTap:
                      () => Navigator.of(context).pop(_EmailOption.defaultApp),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Gmail (web)'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.gmail),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.alternate_email_rounded,
                    color: Color(0xFF0F6CBD),
                  ),
                  title: const Text('Outlook (web)'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.outlook),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy email address'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.copy),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  String _enc(String s) => Uri.encodeComponent(s);

  Uri _mailtoUri(String to, String subject, String body) =>
      Uri.parse('mailto:$to?subject=${_enc(subject)}&body=${_enc(body)}');

  Uri _gmailUri(String to, String subject, String body) => Uri.parse(
    'https://mail.google.com/mail/?view=cm&fs=1&to=${_enc(to)}&su=${_enc(subject)}&body=${_enc(body)}',
  );

  Uri _outlookUri(String to, String subject, String body) => Uri.parse(
    'https://outlook.office.com/mail/deeplink/compose?to=${_enc(to)}&subject=${_enc(subject)}&body=${_enc(body)}',
  );

  Future<bool> _tryLaunch(Uri uri, {LaunchMode? mode}) async {
    try {
      return await launchUrl(uri, mode: mode ?? LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendOpenEmail() async {
    final to = 'info@techterrain-it.com';
    final subject = 'Open application';
    final body =
        'Hi Tech Terrain IT Team,\n\n'
        'I’m interested in future opportunities. Please find my CV attached.\n\n'
        'Regards,\n';

    final choice = await _chooseEmailProvider(context);
    if (choice == null) return;

    switch (choice) {
      case _EmailOption.defaultApp:
        {
          // On mobile/desktop, prefer external app; on web, platform default.
          final mode =
              kIsWeb
                  ? LaunchMode.platformDefault
                  : LaunchMode.externalApplication;
          final ok = await _tryLaunch(
            _mailtoUri(to, subject, body),
            mode: mode,
          );
          if (!ok && mounted) {
            _toast("Couldn't open your mail app. Try Gmail or Outlook.");
          } else {
            _toast('Opening your email app…');
          }
          break;
        }
      case _EmailOption.gmail:
        {
          final ok = await _tryLaunch(_gmailUri(to, subject, body));
          if (!ok && mounted) {
            _toast("Couldn't open Gmail.");
          } else {
            _toast('Opening Gmail…');
          }
          break;
        }

      case _EmailOption.outlook:
        {
          final ok = await _tryLaunch(_outlookUri(to, subject, body));
          if (!ok && mounted) {
            _toast("Couldn't open Outlook.");
          } else {
            _toast('Opening Outlook…');
          }
          break;
        }

      case _EmailOption.copy:
        {
          await Clipboard.setData(ClipboardData(text: to));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address copied. Paste it in your mail app.'),
            ),
          );
          break;
        }
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Iterable<_Role> get _filtered {
    return _roles.where((r) {
      final teamOk = _team == 'All' || r.team == _team;
      final locOk = _loc == 'All' || r.location == _loc;
      final qOk =
          _q.isEmpty ||
          r.title.toLowerCase().contains(_q) ||
          r.team.toLowerCase().contains(_q);
      return teamOk && locOk && qOk;
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
              final gap = cfg.gap;

              final teams = [
                'All',
                ...{for (final r in _roles) r.team},
              ];
              final locs = [
                'All',
                ...{for (final r in _roles) r.location},
              ];

              final title = Text(
                'OPEN ROLES',
                style: GoogleFonts.poppins(
                  fontSize: cfg.h2,
                  fontWeight: FontWeight.w600,
                  color: primary_color,
                  height: 1.06,
                ),
              );
              final items = _filtered.toList(growable: false);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  SizedBox(height: cfg.isMobile ? 16 : 20),

                  // Filters
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FilterChipRow(
                        label: 'Team',
                        items: teams,
                        selected: _team,
                        isMobile: cfg.isMobile,
                        onChanged:
                            (v) => _deferSet(() {
                              _team = v;
                              _ac.forward(from: 0);
                            }),
                      ),
                      _FilterChipRow(
                        label: 'Location',
                        items: locs,
                        selected: _loc,
                        isMobile: cfg.isMobile,
                        onChanged:
                            (v) => _deferSet(() {
                              _loc = v;
                              _ac.forward(from: 0);
                            }),
                      ),
                      SizedBox(
                        width: cfg.isMobile ? 220 : 320,
                        child: TextField(
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w600,
                            fontSize: cfg.isMobile ? 15 : 17,
                          ),
                          onChanged:
                              (s) => _deferSet(() {
                                _q = s.trim().toLowerCase();
                                _ac.forward(from: 0);
                              }),

                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.beVietnamPro(),
                            hintText: 'Search roles (e.g., Oracle Developer)',
                            hintStyle: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w400,
                              fontSize: cfg.isMobile ? 15 : 17,
                            ),
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF6F8FF),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0x11000000),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0x11000000),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: primary_color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Role cards
                  Column(
                    children: [
                      for (int i = 0; i < items.length; i++)
                        FadeTransition(
                          opacity: _stagger(i, items.length),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, .10),
                              end: Offset.zero,
                            ).animate(_stagger(i, items.length)),
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: i == items.length - 1 ? 0 : gap,
                              ),
                              child: _RoleCard(role: items[i]),
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (items.isEmpty)
                    Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primary_color.withValues(alpha: .25),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        child: Builder(
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.work_outline_rounded,
                                  size: 36,
                                  color: primary_color,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No open roles to show',
                                  style: GoogleFonts.poppins(
                                    fontSize: cfg.isMobile ? 15 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: primary_color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No roles to display as there are no active openings ot nothing matches your search. '
                                  'If you are open to hire, feel free to email us your CV.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: cfg.isMobile ? 12 : 14,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: _sendOpenEmail,
                                      style: FilledButton.styleFrom(
                                        shape: const StadiumBorder(),
                                      ),
                                      icon: const Icon(Icons.email_rounded),
                                      label: Text(
                                        'Email your CV',
                                        style: GoogleFonts.beVietnamPro(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selected;
  final bool isMobile;
  final ValueChanged<String> onChanged;
  const _FilterChipRow({
    required this.label,
    required this.items,
    required this.selected,
    required this.isMobile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 15 : 17,
          ),
        ),
        for (final it in items)
          ChoiceChip(
            label: Text(
              it,
              style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 13 : 15,
              ),
            ),
            selected: selected == it,
            onSelected: (_) => onChanged(it),
            selectedColor: primary_color.withValues(alpha: .10),
            labelStyle: TextStyle(
              color: selected == it ? primary_color : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            side: const BorderSide(color: Color(0x11000000)),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }
}

class _Role {
  final String title;
  final String team;
  final String location;
  final String type;
  final List<String> tags;
  const _Role(this.title, this.team, this.location, this.type, this.tags);
}

class _RoleCard extends StatefulWidget {
  final _Role role;
  const _RoleCard({required this.role});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hover = false;

  Future<_EmailOption?> _chooseEmailProvider(BuildContext context) {
    return showDialog<_EmailOption>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Send your CV in email via',
              style: GoogleFonts.beVietnamPro(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_rounded,
                    color: primary_color,
                  ),
                  title: const Text('Mail app (default)'),
                  subtitle: const Text('Open your installed email client'),
                  onTap:
                      () => Navigator.of(context).pop(_EmailOption.defaultApp),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Gmail (web)'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.gmail),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.alternate_email_rounded,
                    color: Color(0xFF0F6CBD),
                  ),
                  title: const Text('Outlook (web)'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.outlook),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy email address'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.copy),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  String enc(String s) => Uri.encodeComponent(s);

  Uri _mailtoUri(String to, String subject) =>
      Uri.parse('mailto:$to?subject=${enc(subject)}');

  Uri _gmailUri(String to, String subject) => Uri.parse(
    'https://mail.google.com/mail/?view=cm&fs=1&to=${enc(to)}&su=${enc(subject)}',
  );

  Uri _outlookUri(String to, String subject) => Uri.parse(
    'https://outlook.office.com/mail/deeplink/compose?to=${enc(to)}&subject=${enc(subject)}',
  );

  Future<bool> _tryLaunch(Uri uri, {LaunchMode? mode}) async {
    try {
      return await launchUrl(uri, mode: mode ?? LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendEmail() async {
    final to = 'info@techterrain-it.com';
    final subject = 'Application – ${widget.role.title}';

    final choice = await _chooseEmailProvider(context);
    if (choice == null) return;

    switch (choice) {
      case _EmailOption.defaultApp:
        {
          // On mobile/desktop, prefer external app; on web, platform default.
          final mode =
              kIsWeb
                  ? LaunchMode.platformDefault
                  : LaunchMode.externalApplication;
          final ok = await _tryLaunch(_mailtoUri(to, subject), mode: mode);
          if (!ok && mounted) {
            _toast("Couldn't open your mail app. Try Gmail or Outlook.");
          } else {
            _toast('Opening your email app…');
          }
          break;
        }
      case _EmailOption.gmail:
        {
          final ok = await _tryLaunch(_gmailUri(to, subject));
          if (!ok && mounted) {
            _toast("Couldn't open Gmail.");
          } else {
            _toast('Opening Gmail…');
          }
          break;
        }

      case _EmailOption.outlook:
        {
          final ok = await _tryLaunch(_outlookUri(to, subject));
          if (!ok && mounted) {
            _toast("Couldn't open Outlook.");
          } else {
            _toast('Opening Outlook…');
          }
          break;
        }

      case _EmailOption.copy:
        {
          await Clipboard.setData(ClipboardData(text: to));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Address copied. Paste it in your mail app & set your mail subject as Role title',
              ),
            ),
          );
          break;
        }
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final lift =
        _hover ? const Offset(0, -4) : Offset.zero; // subtle brand tint
    final border =
        _hover ? primary_color.withValues(alpha: .25) : const Color(0x11000000);
    final shadow =
        _hover
            ? const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ]
            : const <BoxShadow>[];

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(lift.dx, lift.dy),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.2),
          boxShadow: shadow,
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final isNarrow = c.maxWidth < 680;
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.role.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isNarrow ? 16 : 20,
                    color: primary_color,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _Pill(
                      icon: Icons.badge_rounded,
                      text: widget.role.team,
                      isNarrow: isNarrow,
                    ),
                    _Pill(
                      icon: Icons.place_rounded,
                      text: widget.role.location,
                      isNarrow: isNarrow,
                    ),
                    _Pill(
                      icon: Icons.schedule_rounded,
                      text: widget.role.type,
                      isNarrow: isNarrow,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      widget.role.tags.map((t) => _Tag(t, isNarrow)).toList(),
                ),
              ],
            );

            final applyBtn = FilledButton.icon(
              onPressed: _sendEmail,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.send_rounded),
              label: Text(
                'Apply',
                style: GoogleFonts.beVietnamPro(fontSize: isNarrow ? 12 : 15),
              ),
            );

            return isNarrow
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    left,
                    const SizedBox(height: 12),
                    Row(children: [const Spacer(), applyBtn]),
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 16),
                    Center(child: applyBtn),
                  ],
                );
          },
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isNarrow;
  const _Pill({required this.icon, required this.text, required this.isNarrow});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        border: Border.all(color: const Color(0x11000000)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary_color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600,
              fontSize: isNarrow ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool isNarrow;
  const _Tag(this.text, this.isNarrow);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: primary_color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.beVietnamPro(
          color: primary_color,
          fontWeight: FontWeight.w700,
          fontSize: isNarrow ? 10 : 12,
        ),
      ),
    );
  }
}
