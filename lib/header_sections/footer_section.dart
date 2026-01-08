// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:responsive_builder/responsive_builder.dart';
//
// class FooterSection extends StatefulWidget {
//   const FooterSection({super.key});
//
//   @override
//   State<FooterSection> createState() => _FooterSectionState();
// }
//
// class _FooterSectionState extends State<FooterSection> {
//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, sizing) {
//         final isMobile = sizing.deviceScreenType == DeviceScreenType.mobile;
//         final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;
//         final isDesktop =
//             sizing.deviceScreenType == DeviceScreenType.desktop ||
//             sizing.deviceScreenType ==
//                 DeviceScreenType.watch; // treat watch as desktop fallback
//
//         final maxW =
//             isMobile
//                 ? 680.0
//                 : isTablet
//                 ? 980.0
//                 : 1300.0;
//
//         return Center(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: maxW),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(
//                     left: isDesktop ? 24 : 15,
//                     top: 26,
//                     bottom: 24,
//                   ),
//                   child: Row(
//                     children: [
//                       SvgPicture.asset(
//                         'assets/illustrations/ttit_logo.svg',
//                         width: isDesktop ? 40 : 30,
//                       ),
//                       const SizedBox(width: 12),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 5),
//                         child: Text(
//                           '© 2025 Tech Terrain IT Ltd. All rights reserved.',
//                           style: GoogleFonts.beVietnamPro(
//                             fontWeight: FontWeight.w300,
//                             fontSize: isDesktop ? 14 : 11,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart'; // for LoadingController
import 'package:flutter/foundation.dart' show kIsWeb;

enum _EmailOption { defaultApp, gmail, outlook, copy }

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  static const _address =
      'House #12, Road #17/A, Block #E,\nBanani, Dhaka-1213\nBangladesh';
  static const _phone = '+880 140 403 0556';
  static const _email = 'info@techterrain-it.com';
  static const _hours = 'SAT – THU • 10:00 am – 06:30 pm';
  static const _maps = 'https://maps.app.goo.gl/cR5eshAkf7imjeVL8';

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  Future<_EmailOption?> _chooseEmailProvider(BuildContext context) {
    return showDialog<_EmailOption>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Send your message via',
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

  String _enc(String s) => Uri.encodeComponent(s);

  Uri _mailtoUri(String to) => Uri.parse('mailto:$to');

  Uri _gmailUri(String to) =>
      Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=${_enc(to)}');

  Uri _outlookUri(String to) => Uri.parse(
    'https://outlook.office.com/mail/deeplink/compose?to=${_enc(to)}',
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
          final ok = await _tryLaunch(_mailtoUri(to), mode: mode);
          if (!ok && mounted) {
            _toast("Couldn't open your mail app. Try Gmail or Outlook.");
          } else {
            _toast('Opening your email app…');
          }
          break;
        }
      case _EmailOption.gmail:
        {
          final ok = await _tryLaunch(_gmailUri(to));
          if (!ok && mounted) {
            _toast("Couldn't open Gmail.");
          } else {
            _toast('Opening Gmail…');
          }
          break;
        }

      case _EmailOption.outlook:
        {
          final ok = await _tryLaunch(_outlookUri(to));
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
                'Address copied. Paste it in your mail app & send us your message',
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

  // Future<void> _mailto(BuildContext context, String to) async {
  //   final ok = await launchUrl(
  //     Uri.parse('mailto:$to'),
  //     mode: LaunchMode.platformDefault,
  //   );
  //   if (!ok && context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Could not open your mail app.')),
  //     );
  //   }
  // }

  Future<void> _tel(BuildContext context, String tel) async {
    final ok = await launchUrl(
      Uri.parse('tel:$tel'),
      mode: LaunchMode.platformDefault,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calling is not supported on this device.'),
        ),
      );
    }
  }

  Future<void> _go(BuildContext context, String path) async {
    // nice loader before navigation
    await LoadingController.i.flashThenGo(context, path);
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    // Dark, subtle gradient background for the whole footer.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1738), Color(0xFF0B1230)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ResponsiveBuilder(
        builder: (context, sizing) {
          final isMobile = sizing.deviceScreenType == DeviceScreenType.mobile;
          final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;
          // final isDesktop =
          //     sizing.deviceScreenType == DeviceScreenType.desktop ||
          //     sizing.deviceScreenType ==
          //         DeviceScreenType.watch; // treat watch as desktop fallback

          final pad =
              isMobile
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
                  : isTablet
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 24, vertical: 24);

          final maxW =
              isMobile
                  ? 680.0
                  : isTablet
                  ? 980.0
                  : 1300.0;

          final gap =
              isMobile
                  ? 12.0
                  : isTablet
                  ? 14.0
                  : 16.0;

          final isStacked = isMobile || isTablet;
          final hPad = EdgeInsets.symmetric(vertical: isStacked ? 28 : 40);

          final linkStyle = GoogleFonts.beVietnamPro(
            color: Colors.white.withValues(alpha: .88),
            fontWeight: FontWeight.w600,
          );
          final smallStyle = GoogleFonts.beVietnamPro(
            color: Colors.white.withValues(alpha: .72),
            height: 1.6,
          );
          final headingStyle = GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: .2,
          );

          final brand = _BrandColumn(
            smallStyle: smallStyle,
            onContact: () => _go(context, '/contact'),
          );

          final company = _LinkColumn(
            title: 'Company',
            headingStyle: headingStyle,
            children: [
              _FooterLink('Home', () => _go(context, '/'), style: linkStyle),
              _FooterLink(
                'About',
                () => _go(context, '/about'),
                style: linkStyle,
              ),
              _FooterLink(
                'Services',
                () => _go(context, '/services'),
                style: linkStyle,
              ),
              _FooterLink(
                'Career',
                () => _go(context, '/career'),
                style: linkStyle,
              ),
              _FooterLink(
                'Contact',
                () => _go(context, '/contact'),
                style: linkStyle,
              ),
            ],
          );

          final resources = _LinkColumn(
            title: 'Resources',
            headingStyle: headingStyle,
            children: [
              _FooterLink(
                'Partners',
                () => _go(context, '/'),
                style: linkStyle,
                anchor: 'partners',
              ),
              _FooterLink(
                'Testimonials',
                () => _go(context, '/'),
                style: linkStyle,
                anchor: 'testimonials',
              ),
              _FooterLink(
                'Google Play Store',
                () => _launch(
                  'https://play.google.com/store/apps/dev?id=6787836782227703519',
                ),
                style: linkStyle,
              ),
              _FooterLink(
                'Privacy Policy (soon)',
                () {},
                style: linkStyle.copyWith(color: Colors.white54),
              ),
              _FooterLink(
                'Terms of Service (soon)',
                () {},
                style: linkStyle.copyWith(color: Colors.white54),
              ),
            ],
          );

          final contact = _ContactColumn(
            headingStyle: headingStyle,
            smallStyle: smallStyle,
            address: FooterSection._address,
            phone: FooterSection._phone,
            email: FooterSection._email,
            hours: FooterSection._hours,
            onMail: () => _sendEmail(),
            onTel:
                () => _tel(context, FooterSection._phone.replaceAll(' ', '')),
            onMap: () => _launch(FooterSection._maps),
            isDesktop: !isStacked,
          );

          final social = _SocialRow(
            onFacebook: () => _launch('https://www.facebook.com/TerrainSoft'),
            onLinkedIn:
                () => _launch('https://www.linkedin.com/company/terrainsoft'),
          );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Padding(
                padding: pad,
                child: Padding(
                  padding: hPad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isStacked) ...[
                        brand,
                        SizedBox(height: gap),
                        social,
                        SizedBox(height: gap),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [company, SizedBox(width: gap), resources],
                        ),

                        SizedBox(height: gap),
                        contact,
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 4 columns on desktop
                            Expanded(flex: 4, child: brand),
                            SizedBox(width: gap),
                            Expanded(flex: 3, child: company),
                            SizedBox(width: gap),
                            Expanded(flex: 3, child: resources),
                            SizedBox(width: gap),
                            Expanded(flex: 4, child: contact),
                          ],
                        ),
                        SizedBox(height: gap * 1.2),
                        social,
                      ],

                      SizedBox(height: gap),
                      const Divider(color: Color(0x1FFFFFFF), height: 1),

                      // Bottom bar
                      Padding(
                        padding: EdgeInsets.only(top: isStacked ? 14 : 18),
                        child: _BottomBar(
                          year: year,
                          onHome: () => _go(context, '/'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------ pieces ------------------

class _BrandColumn extends StatelessWidget {
  final TextStyle smallStyle;
  final VoidCallback onContact;
  const _BrandColumn({required this.smallStyle, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wordmark or logo
        Row(
          children: [
            SvgPicture.asset(
              'assets/illustrations/ttit_logo_word_remove.svg',
              height: 34,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Transforming businesses with HealthTech, ERP, and GovTech—since 2010.',
          style: smallStyle,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onContact,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: const StadiumBorder(),
            backgroundColor: Colors.white.withValues(alpha: .08),
          ),
          icon: const Icon(Icons.mail_outline_rounded, size: 18),
          label: const Text('Let’s talk'),
        ),
      ],
    );
  }
}

class _LinkColumn extends StatelessWidget {
  final String title;
  final TextStyle headingStyle;
  final List<Widget> children;
  const _LinkColumn({
    required this.title,
    required this.headingStyle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: headingStyle),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle style;
  final String? anchor; // optional anchor name on home
  const _FooterLink(this.text, this.onTap, {required this.style, this.anchor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(text, style: style),
      ),
    );
  }
}

class _ContactColumn extends StatelessWidget {
  final TextStyle headingStyle;
  final TextStyle smallStyle;
  final String address, phone, email, hours;
  final VoidCallback onMail, onTel, onMap;
  final bool isDesktop;

  const _ContactColumn({
    required this.headingStyle,
    required this.smallStyle,
    required this.address,
    required this.phone,
    required this.email,
    required this.hours,
    required this.onMail,
    required this.onTel,
    required this.onMap,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final label = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );

    Widget row(IconData icon, String title, Widget child, {Widget? trailing}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: label),
                  const SizedBox(height: 3),
                  child,
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONTACT', style: headingStyle),
        const SizedBox(height: 10),
        row(
          Icons.place_rounded,
          'Address',
          SelectableText(address, style: smallStyle),
          trailing: _MiniLink('Map', onMap),
        ),
        row(
          Icons.call_rounded,
          'Phone',
          SelectableText(phone, style: smallStyle),
          trailing: !isDesktop ? _MiniLink('Call', onTel) : null,
        ),
        row(
          Icons.email_rounded,
          'Email',
          SelectableText(email, style: smallStyle),
          trailing: _MiniLink('Write', onMail),
        ),
        row(Icons.access_time_rounded, 'Hours', Text(hours, style: smallStyle)),
      ],
    );
  }
}

class _MiniLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _MiniLink(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: secondary_color,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: secondary_color,
          ),
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final VoidCallback onFacebook, onLinkedIn;
  const _SocialRow({required this.onFacebook, required this.onLinkedIn});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _CircleIcon(
          tooltip: 'Facebook',
          onTap: onFacebook,
          child: const Icon(
            Icons.facebook_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        _CircleIcon(
          tooltip: 'LinkedIn',
          onTap: onLinkedIn,
          // your app already has an SVG at assets/images/linkedin.svg
          child: SvgPicture.asset(
            'assets/images/linkedin.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _CircleIcon extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final String tooltip;
  const _CircleIcon({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_CircleIcon> createState() => _CircleIconState();
}

class _CircleIconState extends State<_CircleIcon> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _hover
                      ? Colors.white.withValues(alpha: .18)
                      : Colors.white.withValues(alpha: .10),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int year;
  final VoidCallback onHome;
  const _BottomBar({required this.year, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.beVietnamPro(
      color: Colors.white.withValues(alpha: .70),
      fontSize: 13,
    );
    return Row(
      children: [
        InkWell(
          onTap: onHome,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text('© $year Tech Terrain IT Ltd.', style: style),
          ),
        ),
        const Spacer(),
        Text('All rights reserved', style: style),
      ],
    );
  }
}
