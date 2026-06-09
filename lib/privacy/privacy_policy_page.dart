import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum _EmailOption { defaultApp, gmail, outlook, copy }

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final _sc = ScrollController();

  // anchors for quick jump
  final _kIntro = GlobalKey();
  final _kInfoCollect = GlobalKey();
  final _kSensitive = GlobalKey();
  final _kLocation = GlobalKey();
  final _kCamera = GlobalKey();
  final _kUse = GlobalKey();
  final _kSharing = GlobalKey();
  final _kThirdParty = GlobalKey();
  final _kSecurity = GlobalKey();
  final _kRetention = GlobalKey();
  final _kDelete = GlobalKey();
  final _kRights = GlobalKey();
  final _kChildren = GlobalKey();
  final _kCookies = GlobalKey();
  final _kInternational = GlobalKey();
  final _kChanges = GlobalKey();
  final _kContact = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) _sc.jumpTo(0); // always open at top
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _jump(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
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

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: 34,
      height: 1.06,
      fontWeight: FontWeight.w700,
      color: primary_color,
    );

    final bodyStyle = GoogleFonts.beVietnamPro(
      fontSize: 16,
      height: 1.75,
      color: Colors.black.withValues(alpha: .82),
    );

    final h2 = GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF0F172A),
    );

    final card = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0x11000000)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 16,
          offset: Offset(0, 10),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        controller: _sc,
        child: Column(
          children: [
            // HERO HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 56),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8FAFF), Color(0xFFE5ECFA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SectionShell(
                // denseTop: true,
                builder:
                    (cfg) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy Policy', style: titleStyle),
                        const SizedBox(height: 10),
                        Text(
                          'Tech Terrain IT Ltd. respects the privacy of its users, clients, and authorized organizational users.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _Pill(
                              icon: Icons.calendar_month_rounded,
                              label: 'Last Updated: June 08, 2026',
                            ),
                            _Pill(
                              icon: Icons.verified_user_rounded,
                              label: 'Applies to TTIT apps & services',
                            ),
                          ],
                        ),
                      ],
                    ),
              ),
            ),

            // CONTENT
            SectionShell(
              builder: (cfg) {
                final isNarrow = cfg.isMobile || cfg.isTablet;

                final toc = Container(
                  decoration: card,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('On this page', style: h2),
                      const SizedBox(height: 10),
                      _TocLink('Introduction', () => _jump(_kIntro)),
                      _TocLink(
                        '1. Information We May Collect',
                        () => _jump(_kInfoCollect),
                      ),
                      _TocLink(
                        '2. Sensitive & Professional Data',
                        () => _jump(_kSensitive),
                      ),
                      _TocLink('3. Location Data', () => _jump(_kLocation)),
                      _TocLink(
                        '4. Camera, Storage, Files & Media',
                        () => _jump(_kCamera),
                      ),
                      _TocLink('5. How We Use Data', () => _jump(_kUse)),
                      _TocLink(
                        '6. Data Sharing & Disclosure',
                        () => _jump(_kSharing),
                      ),
                      _TocLink(
                        '7. Third-Party Services',
                        () => _jump(_kThirdParty),
                      ),
                      _TocLink('8. Data Security', () => _jump(_kSecurity)),
                      _TocLink('9. Data Retention', () => _jump(_kRetention)),
                      _TocLink(
                        '10. Data Correction & Deletion',
                        () => _jump(_kDelete),
                      ),
                      _TocLink(
                        '11. User Rights & Choices',
                        () => _jump(_kRights),
                      ),
                      _TocLink(
                        '12. Children’s Privacy',
                        () => _jump(_kChildren),
                      ),
                      _TocLink(
                        '13. Cookies & Web Technologies',
                        () => _jump(_kCookies),
                      ),
                      _TocLink(
                        '14. International Data Processing',
                        () => _jump(_kInternational),
                      ),
                      _TocLink(
                        '15. Changes to This Policy',
                        () => _jump(_kChanges),
                      ),
                      _TocLink('16. Contact Us', () => _jump(_kContact)),
                    ],
                  ),
                );

                final contentCard = Container(
                  decoration: card,
                  padding: const EdgeInsets.all(20),
                  child: DefaultTextStyle(
                    style: bodyStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(key: _kIntro, title: 'Introduction'),
                        Text(
                          'This Privacy Policy explains how Tech Terrain IT Ltd. accesses, collects, uses, stores, protects, and shares user data through its mobile applications, web applications, and software services.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'This policy applies to all applications and software services developed, operated, or maintained by Tech Terrain IT Ltd., including applications published on Google Play, App Store, or used by our clients and authorized users.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Some Tech Terrain IT Ltd. applications may collect different types of data depending on the app’s purpose, user role, organization, enabled features, and permissions granted by the user. Data collection and usage may vary from one application to another based on the functionality used.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kInfoCollect,
                          title: '1. Information We May Collect',
                        ),
                        Text(
                          'Depending on the application and its features, we may collect or process the following types of information:',
                        ),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'User name, email address, mobile number and user profile information',
                          'Login and authentication information',
                          'Device information (model, OS version, app version, device identifier)',
                          'IP address and technical logs',
                          'Usage data (features used, actions performed, access time, error logs)',
                          'Data entered by users into the application',
                          'Operational data needed to provide software services',
                          'Appointment, schedule, attendance, leave, approval, report, prescription, patient/customer/employee, transaction or operational data (depending on the app)',
                          'Files, images, or documents uploaded by authorized users (where applicable)',
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'We only collect data necessary to provide, operate, maintain, improve, and secure our applications and services.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kSensitive,
                          title: '2. Sensitive and Professional Data',
                        ),
                        Text(
                          'Some applications may be used in healthcare, HR, ERP, accounting, reporting, or administrative environments. Authorized users may enter or process sensitive, professional, or organization-specific data as required for app functionality.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kLocation,
                          title: '3. Location Data',
                        ),
                        Text(
                          'Not all Tech Terrain IT Ltd. applications collect or use location data. Some apps may request location access only when location-based features are required.',
                        ),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'Show the user’s current location on a map',
                          'Verify attendance, visit, movement, or workforce activities',
                          'Detect entry into or exit from user-defined geofence areas',
                          'Trigger location-based alerts, notifications, sound, or vibration',
                          'Enable location-based events even when the app is closed or not in use (where background location is required for the app’s core functionality)',
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'Location data is collected only with user permission and used strictly for functionality. We do not sell location data and do not use it for advertising or third-party tracking.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'If an application requires background location access, the app will provide clear disclosure and request user consent as required before collecting background location data.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'If a user denies location permission, the application will continue to work, except for features that specifically require location access.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kCamera,
                          title: '4. Camera, Storage, Files, and Media Access',
                        ),
                        Text(
                          'Some applications may request camera, storage, file, image, or media access depending on the required functionality.',
                        ),
                        const SizedBox(height: 10),
                        Text('These permissions may be used for:'),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'Uploading profile photos or documents',
                          'Capturing/uploading images required for official tasks',
                          'Attaching files, reports, or supporting documents',
                          'Generating, viewing, downloading, or sharing app-related files',
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'We access such files only when the user allows permission or actively uses the related feature.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(key: _kUse, title: '5. How We Use Data'),
                        Text('We may use collected or processed data to:'),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'Provide features and software services',
                          'Authenticate users and manage secure access',
                          'Maintain user accounts and role-based permissions',
                          'Process user-submitted information',
                          'Generate reports and dashboards',
                          'Manage appointments, schedules, attendance, leave, approval, prescription, patient, customer, employee, transaction, or operational records, depending on the application',
                          'Improve performance, usability, reliability',
                          'Provide support and troubleshooting',
                          'Monitor security and prevent unauthorized access',
                          'Communicate service-related notices, updates, or support information',
                          'Comply with applicable laws, regulations, contractual obligations, and client requirements',
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'We do not use personal data for unauthorized advertising or unrelated third-party marketing.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kSharing,
                          title: '6. Data Sharing and Disclosure',
                        ),
                        Text(
                          'Tech Terrain IT Ltd. does not sell or rent personal, sensitive, patient, employee, customer, financial, or location data.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'We may share limited data only in the following cases:',
                        ),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'With authorized users of the same organization (role-based)',
                          'With client organizations that own/manage the relevant data',
                          'With trusted hosting/infrastructure/maintenance/technical support providers',
                          'With legal or regulatory authorities if required by law',
                          'With service providers needed for operation (cloud, database, notifications, analytics, crash reporting, maps, payment gateway), where applicable',
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'Any such sharing is limited to what is necessary for operating, supporting, securing, or legally maintaining the services.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kThirdParty,
                          title: '7. Third-Party Services',
                        ),
                        Text(
                          'Some apps may use third-party services for hosting, analytics, crash reporting, notifications, maps, payments or other technical purposes.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'These third-party services may collect limited technical or transactional information as required for their functionality. Their data processing is governed by their respective privacy policies and service terms.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'We use third-party services only to support application operation, security, performance, and service delivery.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kSecurity,
                          title: '8. Data Security',
                        ),
                        Text(
                          'We take reasonable technical and organizational measures to protect user data from unauthorized access, misuse, loss, disclosure, alteration, or destruction.',
                        ),
                        const SizedBox(height: 10),
                        Text('Security measures may include:'),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'User authentication',
                          'Role-based access control',
                          'Server access restrictions',
                          'Secure database management',
                          'Data backup and monitoring',
                          'Controlled access for technical support',
                          'Application and server-level security practices',
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'However, no digital system, internet transmission, or electronic storage method can be guaranteed to be completely secure. Users are responsible for keeping their login credentials confidential and using the application in an authorized manner.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kRetention,
                          title: '9. Data Retention',
                        ),
                        Text(
                          'We retain data only as long as necessary to provide application services, fulfill contractual obligations, maintain records, support users, resolve disputes, ensure security, and comply with legal or regulatory requirements.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Data retention periods may vary depending on the type of application, client organization, legal requirement, and operational purpose.',
                        ),
                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kDelete,
                          title: '10. Data Correction and Deletion',
                        ),
                        Text(
                          'Authorized users or client organizations may request correction, update, or deletion of their data by contacting Tech Terrain IT Ltd. or the relevant organization administrator.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Data deletion requests will be handled subject to applicable laws, contractual obligations, security requirements, backup policies, and legitimate operational needs.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Some data may need to be retained for legal, audit, reporting, dispute resolution, or compliance purposes.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kRights,
                          title: '11. User Rights and Choices',
                        ),
                        Text(
                          'Depending on the application and applicable law, users may have the right to:',
                        ),
                        const SizedBox(height: 10),
                        _Bullets(const [
                          'Access personal data (where applicable)',
                          'Request correction of inaccurate data',
                          'Request deletion (where applicable)',
                          'Withdraw device permissions from settings',
                          'Contact us for privacy questions or concerns',
                        ]),
                        const SizedBox(height: 10),
                        Text(
                          'Users can manage app permissions such as location, camera, storage, notification, or other device permissions from their device settings.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kChildren,
                          title: '12. Children’s Privacy',
                        ),
                        Text(
                          'Our applications are generally intended for authorized organizational users, professionals, employees, administrators, clients, or service users.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'UOur applications are not intended to knowingly collect personal information directly from children without proper authorization, parental consent, institutional permission, or legal basis where applicable.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'If we become aware that data from a child has been collected without appropriate authorization, we will take reasonable steps to address the issue.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kCookies,
                          title: '13. Cookies and Web Technologies',
                        ),
                        Text(
                          'Our web apps may use cookies/sessions/browser storage to maintain sessions, improve experience, secure access, and support functionality. Disabling cookies may affect features.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kInternational,
                          title: '14. International Data Processing',
                        ),
                        Text(
                          'Depending on hosting, infrastructure, or service configuration, data may be stored or processed on servers located in Bangladesh or other countries. We take reasonable steps to ensure that data is handled securely and in accordance with this Privacy Policy.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(
                          key: _kChanges,
                          title: '15. Changes to This Privacy Policy',
                        ),
                        Text(
                          'Tech Terrain IT Ltd. may update this Privacy Policy from time to time to reflect changes in our applications, services, legal requirements, or operational practices.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'When we update this Privacy Policy, we will revise the effective date at the top of this page. Users are encouraged to review this page periodically.',
                        ),

                        const SizedBox(height: 22),
                        _SectionTitle(key: _kContact, title: '16. Contact Us'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x11000000)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tech Terrain IT Ltd.',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Banani, Dhaka, Bangladesh'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _ActionButton(
                                    icon: Icons.email_rounded,
                                    label: 'Email',
                                    onTap: () => _sendEmail(),
                                  ),
                                  _ActionButton(
                                    icon: Icons.public_rounded,
                                    label: 'Website',
                                    onTap:
                                        () => _launch(
                                          'https://techterrain-it.com',
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      toc,
                      const SizedBox(height: 16),
                      contentCard,
                      const SizedBox(height: 40),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 360, child: toc),
                    const SizedBox(width: 18),
                    Expanded(child: contentCard),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets(this.items);

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.beVietnamPro(
      fontSize: 15,
      height: 1.65,
      color: Colors.black.withValues(alpha: .82),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 11),
                  child: Icon(Icons.circle, size: 7, color: primary_color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(s, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

class _TocLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _TocLink(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: Text(
          text,
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w600,
            color: primary_color,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: primary_color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: .78),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0x22000000)),
        foregroundColor: primary_color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
      ),
    );
  }
}
